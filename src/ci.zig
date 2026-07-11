const std = @import("std");
const builtin = @import("builtin");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const tmp_alloc = consts.tmp_alloc;
const StringList = consts.StringList;
const Extention = consts.Extention;
const Runner = consts.Runner;
const Config = consts.Config;

const printErrExit = util.printErrExit;
const cliProgramExists = util.cliProgramExists;

pub fn processArgs(argsObj: std.process.Args) Config {
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const alloc = fba.allocator();
    var args = argsObj.iterateAllocator(alloc) catch |err| {
        printErrExit("allocating cli args fail. err: {}\n", .{err});
    };
    defer args.deinit();

    // Skip exe path
    _ = args.skip();

    var inputPath: []const u8 = undefined;

    if (args.next()) |firstArg| {
        handleHelpFlag(firstArg);
        if (firstArg[0] == '-') {
            printErrExit(
                \\first argument is input path, never flag!
                \\Arg passed: {s}
                \\run 'rune --help' for usage
                \\
            , .{firstArg});
        }
        inputPath = firstArg;
    } else {
        // TODO handle rune.json
        printErrExit(
            \\no entry specified!
            \\Run 'rune entry.exe'
            \\
        , .{});
    }

    var config: Config = .{
        .inputPath = inputPath,
        .outputPath = ".cache/rune/tmp",
        .extention = getExtention(inputPath),
        .opt = .debug,
        .target = consts.defaultTarget,
        .runner = .native,
        .runArgs = null,
    };

    var argsLeft = argsObj.vector.len - 2;

    if (args.next()) |outputPathOrFlag| {
        if (outputPathOrFlag[0] == '-') {
            handleArg(&config, outputPathOrFlag, argsLeft);
        } else {
            if (outputPathOrFlag[outputPathOrFlag.len - 1] == '/')
                printErrExit("output_path can't end with '/'\n", .{});
            if (std.mem.indexOfScalar(u8, outputPathOrFlag, '/') == null)
                printErrExit(
                    "output_path must starts with './' when doesn't containing '/'\ntry: './{s}'\n",
                    .{outputPathOrFlag},
                );
            config.outputPath = outputPathOrFlag;
            config.runner = .none;
            config.opt = .fast;
        }
        argsLeft -= 1;
    }

    while (args.next()) |arg| {
        handleArg(&config, arg, argsLeft);
    }

    return config;
}

fn handleArg(config: *Config, arg: []const u8, argsLeft: usize) void {
    if (handleTarget(config, arg)) return;
    if (handleOptimization(config, arg)) return;
    if (handleRunFlag(config, arg, argsLeft)) return;
    if (handleExeArgs(config, arg)) return;
    handleHelpFlag(arg);

    // Unhandled arg
    printErrExit(
        \\unknown flag: {s}
        \\run 'rune --help' for usage
        \\
    , .{arg});
}

fn handleTarget(config: *Config, arg: []const u8) bool {
    if (!std.mem.startsWith(u8, arg, "--target")) return false;

    if (std.mem.indexOfScalar(u8, arg, '=')) |pos| {
        const targetStr = arg[pos + 1 ..];

        if (getTarget(targetStr)) |target|
            config.target = target
        else
            printErrExit(
                \\bad target '{s}'!
                \\try: --target=[target]
                \\run 'rune --help' to see supported targets
                \\
            , .{targetStr});
    } else {
        printErrExit("bad --target flag! try: --target=[target]\n", .{});
    }

    return true;
}

fn getTarget(target: []const u8) ?consts.Target {
    if (std.mem.eql(u8, target, "linux-x86_64")) return .@"linux-x86_64";
    if (std.mem.eql(u8, target, "linux-x86_64-musl")) return .@"linux-x86_64-musl";
    if (std.mem.eql(u8, target, "linux-aarch64")) return .@"linux-aarch64";
    if (std.mem.eql(u8, target, "macos-x86_64")) return .@"macos-x86_64";
    if (std.mem.eql(u8, target, "macos-aarch64")) return .@"macos-aarch64";
    if (std.mem.eql(u8, target, "windows-x86_64")) return .@"windows-x86_64";
    if (std.mem.eql(u8, target, "windows-x86_64-gnu")) return .@"windows-x86_64-gnu";
    if (std.mem.eql(u8, target, "browser")) return .browser;
    return null;
}

fn handleOptimization(config: *Config, arg: []const u8) bool {
    if (getOptimization(arg)) |optimization| {
        config.opt = optimization;
        return true;
    }
    return false;
}

fn getOptimization(arg: []const u8) ?consts.Optimization {
    if (std.mem.eql(u8, arg, "--debug")) return .debug;
    if (std.mem.eql(u8, arg, "--safe")) return .safe;
    if (std.mem.eql(u8, arg, "--fast")) return .fast;
    if (std.mem.eql(u8, arg, "--size")) return .size;
    return null;
}

fn handleRunFlag(config: *Config, arg: []const u8, argsLeft: usize) bool {
    if (!std.mem.startsWith(u8, arg, "--run")) return false;

    var arrayLen = argsLeft;

    const isTargetWindows = config.target == .@"windows-x86_64" or config.target == .@"windows-x86_64-gnu";

    if (config.target == consts.defaultTarget) {
        config.runner = .native;
    } else if ((builtin.target.os.tag != .windows) and isTargetWindows) {
        config.runner = .wine;
        arrayLen += 1;
    } else {
        std.log.warn(
            \\--run flag unsupported for target: {} on {}
            \\remove --run flag from command
            \\
        , .{ config.target, consts.defaultTarget });
    }

    var runArgs = StringList.initCapacity(tmp_alloc, arrayLen) catch
        printErrExit("out of memory when making run args ArrayList", .{});
    runArgsAddRunner(&runArgs, config.runner);

    // add exe
    runArgs.append(tmp_alloc, config.outputPath) catch
        printErrExit("out of memory when allocating run arg", .{});

    config.runArgs = runArgs;

    return true;
}

fn runArgsAddRunner(runArgs: *StringList, runner: Runner) void {
    switch (runner) {
        .wine => runArgs.append(tmp_alloc, "wine") catch
            printErrExit("out of memory when allocating run arg", .{}),
        .native, .none => {},
    }
}

fn handleExeArgs(config: *Config, arg: []const u8) bool {
    if (config.runArgs) |*runArgs| {
        runArgs.append(tmp_alloc, arg) catch
            printErrExit("out of memory when allocating run arg", .{});
        return true;
    }

    return false;
}

fn handleHelpFlag(arg: []const u8) void {
    if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
        printUsage();
        std.process.exit(0);
    }
}

const usageStr =
    \\usage (rune {s}): rune [input_path] [output_path | flag] [flags]
    \\flags:
    \\  --debug | --safe | --fast | --size              Set optimization level (default: --debug, when output_path provided: --fast)
    \\  --target=[os]-[arch]-[abi?]                     Set target OS (default: current OS)
    \\
    \\supported targets:
    \\    linux-x86_64, linux-x86_64-musl, linux-aarch64    Linux
    \\    macos-x86_64, macos-aarch64                       Darwin
    \\    windows-x86_64, windows-x86_64-gnu                Windows
    \\    browser                                           Wasm | HTML | JS | TS
    \\
    \\  --run                   Run compiled program. evry arg passed after --run will be pass into running exe
    \\  -h, --help              Show this help message
    \\
    \\example usage:
    \\  rune src/main.zig --run="my arg"
    \\  rune src/main.rs
    \\  rune src/main.c dist/main --fast
    \\  rune src/main.cpp dist/main --debug
    // \\  rune src/server.ts
    // \\  rune src/main.ts dist/main.js --size
    // \\  rune src/index.html dist/index.html --size
    \\
    \\supported extentions:
    \\  .zig, .rs (native), .c, .cpp
    \\
;

fn printUsage() void {
    std.debug.print(usageStr, .{comptime consts.runeVersion});
}

fn getExtention(path: []const u8) Extention {
    if (std.mem.endsWith(u8, path, ".zig")) return .zig;
    if (std.mem.endsWith(u8, path, ".rs")) return .rs;
    if (std.mem.endsWith(u8, path, ".c")) return .c;
    if (std.mem.endsWith(u8, path, ".cpp")) return .cpp;
    if (std.mem.endsWith(u8, path, ".cs")) return .cs;
    if (std.mem.endsWith(u8, path, ".java")) return .java;
    if (std.mem.endsWith(u8, path, ".html")) return .html;
    if (std.mem.endsWith(u8, path, ".css")) return .css;
    if (std.mem.endsWith(u8, path, ".js")) return .js;
    if (std.mem.endsWith(u8, path, ".jsx")) return .jsx;
    if (std.mem.endsWith(u8, path, ".ts")) return .ts;
    if (std.mem.endsWith(u8, path, ".tsx")) return .tsx;
    if (std.mem.endsWith(u8, path, ".py")) return .py;
    printErrExit(
        \\unknown extetnion for file '{s}'
        \\see supported file extentions running 'run -h'
        \\
    , .{path});
}
