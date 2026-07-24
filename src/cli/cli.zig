const std = @import("std");
const builtin = @import("builtin");
const consts = @import("../lib/consts.zig");
const util = @import("../lib/util.zig");

const StringList = consts.StringList;
const Extention = consts.Extention;
const Runner = consts.Runner;
const Target = consts.Target;
const Config = consts.Config;

const printErrExit = util.printErrExit;
const cliProgramExists = util.cliProgramExists;

pub fn processArgs(Args: std.process.Args, allocator: std.mem.Allocator) Config {
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const alloc = fba.allocator();
    var args = Args.iterateAllocator(alloc) catch |err| {
        printErrExit("allocating cli args fail. err: {}\n", .{err});
    };
    defer args.deinit();

    // Skip exe path
    _ = args.skip();

    var input_path: []const u8 = undefined;

    if (args.next()) |first_arg| {
        handleHelpFlag(first_arg);
        if (first_arg[0] == '-') {
            printErrExit(
                \\first argument is input path, never flag!
                \\Arg passed: {s}
                \\run 'rune --help' for usage
                \\
            , .{first_arg});
        }
        input_path = first_arg;
    } else {
        // TODO handle rune.json
        printErrExit(
            \\no entry specified!
            \\Run 'rune entry.exe'
            \\
        , .{});
    }

    const extention = getExtention(input_path);

    var config: Config = .{
        .input_path = input_path,
        .output_path = ".cache/rune/tmp",
        .extention = extention,
        .opt = .debug,
        .target = getDefaultTarget(extention),
        .runner = getDefaultRunner(extention),
        .run_args = null,
        .types = false,
        .info = false,
    };

    var args_left = Args.vector.len - 2;

    if (args.next()) |output_path_or_flag| {
        if (output_path_or_flag[0] == '-') {
            handleArg(allocator, &config, output_path_or_flag, args_left);
        } else {
            if (output_path_or_flag[output_path_or_flag.len - 1] == '/')
                printErrExit("output_path can't end with '/'\n", .{});
            if (std.mem.indexOfScalar(u8, output_path_or_flag, '/') == null)
                printErrExit(
                    \\output_path must starts with './' when doesn't containing '/'
                    \\try: './{s}'
                    \\
                , .{output_path_or_flag});
            config.output_path = output_path_or_flag;
            config.runner = .none;
            config.opt = .fast;
        }
        args_left -= 1;
    }

    while (args.next()) |arg| {
        handleArg(allocator, &config, arg, args_left);
    }

    if (config.runner != .none and config.run_args == null) {
        handleArg(allocator, &config, "--run", 0);
    }

    return config;
}

fn getDefaultTarget(extention: Extention) Target {
    return switch (extention) {
        .html, .css, .js, .jsx, .ts, .tsx => .browser,
        else => consts.default_target,
    };
}

fn getDefaultRunner(extention: Extention) Runner {
    return switch (extention) {
        .html, .css, .js, .jsx, .ts, .tsx => .bun,
        else => .native,
    };
}

fn handleArg(allocator: std.mem.Allocator, config: *Config, arg: []const u8, args_left: usize) void {
    if (handleTarget(config, arg)) return;
    if (handleOptimization(config, arg)) return;
    if (handleRunFlag(allocator, config, arg, args_left)) return;
    if (handleExeArgs(allocator, config, arg)) return;
    if (handleInfoFlag(config, arg)) return;
    if (handleRawFlags(config, arg)) return;
    handleHelpFlag(arg);
    // TODO add/install targets/deps

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
        const target_str = arg[pos + 1 ..];

        if (getTarget(target_str)) |target|
            config.target = target
        else
            printErrExit(
                \\bad target '{s}'!
                \\try: --target=[target]
                \\run 'rune --help' to see supported targets
                \\
            , .{target_str});
    } else {
        printErrExit("bad --target flag! try: --target=[target]\n", .{});
    }

    return true;
}

fn getTarget(target: []const u8) ?Target {
    if (std.mem.eql(u8, target, "linux-x86_64")) return .@"linux-x86_64";
    if (std.mem.eql(u8, target, "linux-x86_64-musl")) return .@"linux-x86_64-musl";
    if (std.mem.eql(u8, target, "linux-aarch64")) return .@"linux-aarch64";
    if (std.mem.eql(u8, target, "linux-aarch64-musl")) return .@"linux-aarch64-musl";
    if (std.mem.eql(u8, target, "macos-x86_64")) return .@"macos-x86_64";
    if (std.mem.eql(u8, target, "macos-aarch64")) return .@"macos-aarch64";
    if (std.mem.eql(u8, target, "windows-x86_64")) return .@"windows-x86_64";
    if (std.mem.eql(u8, target, "windows-aarch64")) return .@"windows-aarch64";
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

fn handleRunFlag(allocator: std.mem.Allocator, config: *Config, arg: []const u8, args_left: usize) bool {
    if (!std.mem.eql(u8, arg, "--run")) return false;

    var array_len = args_left;

    const is_target_windows = config.target == .@"windows-x86_64" or config.target == .@"windows-aarch64";

    if (config.target == consts.default_target) {
        config.runner = .native;
    } else if ((builtin.target.os.tag != .windows) and is_target_windows) {
        config.runner = .wine;
        array_len += 1;
    } else if (config.extention == .js) {
        config.runner = .bun;
        array_len += 1;
    } else {
        std.log.warn(
            \\--run flag unsupported for target: {} on {}
            \\remove --run flag from command
            \\
        , .{ config.target, consts.default_target });
    }

    var run_args = StringList.initCapacity(allocator, array_len) catch
        printErrExit("out of memory when making run args ArrayList", .{});
    runArgsAddRunner(allocator, &run_args, config.runner);

    // add exe
    if (config.runner != .bun or std.mem.startsWith(u8, config.output_path, "./cache"))
        run_args.append(allocator, config.output_path) catch
            printErrExit("out of memory when allocating run arg", .{})
    else
        run_args.append(allocator, config.input_path) catch
            printErrExit("out of memory when allocating run arg", .{});

    config.run_args = run_args;

    return true;
}

fn handleInfoFlag(config: *Config, arg: []const u8) bool {
    if (!std.mem.eql(u8, arg, "--info")) return false;
    config.info = true;
    return true;
}

fn runArgsAddRunner(allocator: std.mem.Allocator, run_args: *StringList, runner: Runner) void {
    switch (runner) {
        .wine => run_args.append(allocator, "wine") catch
            printErrExit("out of memory when allocating run arg", .{}),
        .bun => run_args.append(allocator, "bun") catch
            printErrExit("out of memory when allocating run arg", .{}),
        .native, .none => {},
    }
}

fn handleExeArgs(allocator: std.mem.Allocator, config: *Config, arg: []const u8) bool {
    if (config.run_args) |*run_args| {
        run_args.append(allocator, arg) catch
            printErrExit("out of memory when allocating run arg", .{});
        return true;
    }

    return false;
}

fn handleRawFlags(config: *Config, arg: []const u8) bool {
    if (!std.mem.startsWith(u8, arg, "--raw")) return false;

    if (std.mem.indexOfScalar(u8, arg, '=')) |pos| {
        _ = config;
        _ = pos;
        printErrExit("raw compiler args is not supported yet\n", .{});
        // config.rawCompilerArgs = arg[pos + 1 ..];
    } else {
        printErrExit("bad --raw flag! try: --target=[target]\n", .{});
    }

    return true;
}

fn handleHelpFlag(arg: []const u8) void {
    if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
        printUsage();
        std.process.exit(0);
    }
}

const usage_str =
    \\usage (rune {s}): rune [input_path] [output_path | flag] [flags]
    \\flags:
    \\  --debug | --safe | --fast | --size              Set optimization level (default: --debug, when output_path provided: --fast)
    \\  --target=[os]-[arch]-[abi?]                     Set target OS (default: current OS)
    \\
    \\supported targets:
    \\    linux-x86_64, linux-x86_64-musl, linux-aarch64, linux-aarch64-musl    Linux
    \\    macos-x86_64, macos-aarch64                                           Darwin
    \\    windows-x86_64, windows-aarch64                                       Windows
    \\    browser                                           Wasm | HTML | CSS | JS | TS
    \\
    \\  --run                   Run compiled program. evry arg passed after --run will be pass into running exe
    \\  --info                  Print build/run info (useful for debugging)
    \\  -h, --help              Show this help message
    \\
    \\example usage:
    \\  rune src/main.zig --run="my arg"
    \\  rune src/main.rs
    \\  rune src/main.c dist/main --fast
    \\  rune src/main.cpp dist/main --debug
    \\  rune src/server.js
    \\  rune src/main.ts dist/main.js --size
    \\  rune ./styles.css dist/styles.css --size
    \\  rune src/index.html dist/index.html --size
    \\
    \\supported extentions:
    \\  .zig, .rs (native), .c, .cpp, .html, .css, .js, .ts, .jsx (node_modules), .tsx (node_modules)
    \\
;

fn printUsage() void {
    std.debug.print(usage_str, .{comptime consts.rune_version});
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
        \\see supported file extentions running 'rune -h'
        \\
    , .{path});
}
