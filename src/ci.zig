const std = @import("std");
const builtin = @import("builtin");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Config = consts.Config;
const Extention = consts.Extention;

const print = util.print;
const printErrExit = util.printErrExit;

pub fn processArgs(init: std.process.Init) Config {
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const alloc = fba.allocator();
    var args = init.minimal.args.iterateAllocator(alloc) catch |err| {
        printErrExit("allocating cli args fail. err: {}\n", .{err});
    };
    defer args.deinit();

    // Skip exe path
    _ = args.skip();

    var inputPath: []const u8 = undefined;
    var extention: Extention = .unknown;

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
        extention = getExtention(firstArg);
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
        .extention = extention,
        .opt = .debug,
        .target = consts.defaultTarget,
        .runner = .native,
    };

    if (args.next()) |outputPathOrFlag| {
        if (outputPathOrFlag[0] == '-') {
            handleArg(&config, outputPathOrFlag);
        } else {
            if (outputPathOrFlag[outputPathOrFlag.len - 1] == '/')
                printErrExit("output_path can't end with '/'\n", .{});
            config.outputPath = outputPathOrFlag;
            config.runner = .none;
            config.opt = .release;
        }
    }

    while (args.next()) |arg| {
        handleArg(&config, arg);
    }

    return config;
}

fn handleArg(config: *Config, arg: []const u8) void {
    if (handleOptimalization(config, arg)) return;
    if (handleTarget(config, arg)) return;
    if (handleRunFlag(config, arg)) return;
    handleHelpFlag(arg);

    // Unhandled arg
    printErrExit(
        \\unknown flag: {s}
        \\run 'rune --help' for usage
        \\
    , .{arg});
}

fn handleOptimalization(config: *Config, arg: []const u8) bool {
    if (std.mem.eql(u8, arg, "--debug")) {
        config.opt = .debug;
    } else if (std.mem.eql(u8, arg, "--safe")) {
        config.opt = .safe;
    } else if (std.mem.eql(u8, arg, "--release")) {
        config.opt = .release;
    } else if (std.mem.eql(u8, arg, "--size")) {
        config.opt = .size;
    } else {
        return false;
    }
    return true;
}

fn handleTarget(config: *Config, arg: []const u8) bool {
    if (!std.mem.startsWith(u8, arg, "--target")) return false;

    if (std.mem.indexOfScalar(u8, arg, '=')) |pos| {
        const value = arg[pos + 1 ..];

        if (std.mem.eql(u8, value, "linux-x86_64")) {
            config.target = .@"linux-x86_64";
        } else if (std.mem.eql(u8, value, "linux-x86_64-musl")) {
            config.target = .@"linux-x86_64-musl";
        } else if (std.mem.eql(u8, value, "linux-aarch64")) {
            config.target = .@"linux-aarch64";
        } else if (std.mem.eql(u8, value, "macos-x86_64")) {
            config.target = .@"macos-x86_64";
        } else if (std.mem.eql(u8, value, "macos-aarch64")) {
            config.target = .@"macos-aarch64";
        } else if (std.mem.eql(u8, value, "windows-x86_64")) {
            config.target = .@"windows-x86_64";
        } else if (std.mem.eql(u8, value, "windows-x86_64-gnu")) {
            config.target = .@"windows-x86_64-gnu";
        } else if (std.mem.eql(u8, value, "browser")) {
            config.target = .browser;
        } else {
            printErrExit(
                \\bad --target flag! Try: --target=[target]
                \\run 'rune --help' for usage
                \\
            , .{});
        }
    } else {
        printErrExit("bad --target flag! Try: --target=[target]\n", .{});
    }

    return true;
}

fn handleRunFlag(config: *Config, arg: []const u8) bool {
    if (std.mem.eql(u8, arg, "--run")) {
        if (config.runner != .none)
            printErrExit(
                \\--run has no effect when no output path is provided
                \\remove --run flag from command
                \\
            , .{});
        if (config.target == consts.defaultTarget) {
            config.runner = .native;
            return true;
        }
        if ((builtin.target.os.tag == .linux or builtin.target.os.tag == .macos) and config.target == .@"windows-x86_64") {
            // TODO check is wine exists then run exe via wine
            // exec wine dist/bin/rune-windows-x64 $@
            // may break when wine don't exists
            // later change .wineUnchecked to .wine
            config.runner = .wineUnchecked;
            return true;
        }
        printErrExit(
            \\--run flag unsupported for target: {} on {}
            \\remove --run flag from command
            \\
        , .{ config.target, consts.defaultTarget });
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
    \\  --debug | --safe | --release | --size           Set optimization level (default: --debug)
    \\  --target=[os]-[arch]-[abi?]                     Set target OS (default: current OS)
    \\
    \\supported targets:
    \\    linux-x86_64, linux-x86_64-musl, linux-aarch64    Linux
    \\    macos-x86_64, macos-aarch64                       Darwin
    \\    windows-x86_64, windows-x86_64-gnu                Windows
    \\    browser                                           Wasm | HTML | JS | TS
    \\
    \\  --run                                           Run compiled program. Use only when output_path is provided
    \\  -h, --help                                      Show this help message
    \\
    \\example usage:
    \\  rune src/main.zig
    \\  rune src/main.c dist/main --release
    // \\  rune src/server.ts
    // \\  rune src/main.ts dist/main.js --size
    // \\  rune src/index.html dist/index.html --size
    \\
    \\supported extentions:
    \\  .zig, .c
    \\
;

fn printUsage() void {
    print(usageStr, .{comptime consts.runeVersion});
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
    return .unknown;
}
