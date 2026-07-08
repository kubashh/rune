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
        printErrExit("when allocating cli args {}\n", .{err});
    };
    defer args.deinit();

    // Skip exe path
    _ = args.skip();

    var inputPath: []const u8 = undefined;
    var extention: Extention = .unknown;

    if (args.next()) |firstArg| {
        if (firstArg[0] == '-') {
            printErrExit("first argument is input path, never flag!\nArg passed: {s}\n", .{firstArg});
        }
        inputPath = firstArg;
        extention = getExtention(firstArg);
    } else {
        // TODO handle rune.json
        printUsage();
        printErrExit("no entry specified!\nRun 'rune entry.exe'\n", .{});
    }

    var config: Config = .{
        .inputPath = inputPath,
        .outputPath = ".cache/rune/tmp",
        .extention = extention,
        .opt = .debug,
        .target = consts.defaultTarget,
        .run = true,
    };

    if (args.next()) |outputPathOrFlag| {
        if (outputPathOrFlag[0] == '-') {
            handleArg(&config, outputPathOrFlag);
        } else {
            config.outputPath = outputPathOrFlag;
            config.run = false;
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

    // Handle help
    if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
        printUsage();
        std.process.exit(0);
    }

    // Unhandled arg
    printErrExit("unknown flag: {s}\n\n", .{arg});
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
            printErrExit("bad --target flag! Try: --target=[target]\n", .{});
        }
    } else {
        printErrExit("bad --target flag! Try: --target=[target]\n", .{});
    }

    return true;
}

fn handleRunFlag(config: *Config, arg: []const u8) bool {
    if (std.mem.eql(u8, arg, "--run")) {
        if (config.run)
            printErrExit("--run has no effect when no output path is provided\n", .{});
        if (config.target == consts.defaultTarget) {
            config.run = true;
            return true;
        }
        if (builtin.target.os.tag == .linux and config.target == .@"windows-x86_64") {
            // TODO check is wine exists then run exe via wine
            printErrExit("wine unsopported on linux yet\n", .{});
            // config.run = true;
            // return;
        }
        printErrExit("--run flag unsupported for target: {} on {}\n", .{ config.target, consts.defaultTarget });
    }

    return false;
}

fn printUsage() void {
    print(
        \\usage: rune [input_path] [output_path | flag] [flags]
        \\flags:
        \\  --debug | --safe | --release | --size           Set optimization level (default: --debug)
        \\  --target=[os]-[arch]-[abi?]                     Set target OS (default: current OS)
        \\  supported targets:
        \\    linux-x86_64, linux-x86_64-musl, linux-aarch64    Linux
        \\    macos-x86_64, macos-aarch64                       Darwin
        \\    windows-x86_64, windows-x86_64-gnu                Windows
        \\    browser                                           Wasm | HTML | JS | TS
        \\
        \\  --run                                           Run compiled program. Use only when output_path is provided
        \\  -h, --help                                      Show this help message
        \\
        \\example usage:
        \\  rune src/main.c
        \\  rune src/main.c dist/main --release
        // \\  rune src/server.ts
        // \\  rune src/main.ts dist/main.js --size
        // \\  rune src/index.html dist/index.html --size
        \\
        \\supported extentions:
        \\  .c
        \\
    , .{});
}

fn getExtention(path: []const u8) Extention {
    if (std.mem.endsWith(u8, path, ".c")) return .c;
    if (std.mem.endsWith(u8, path, ".cpp")) return .cpp;
    if (std.mem.endsWith(u8, path, ".cs")) return .cs;
    if (std.mem.endsWith(u8, path, ".java")) return .java;
    if (std.mem.endsWith(u8, path, ".zig")) return .zig;
    if (std.mem.endsWith(u8, path, ".rs")) return .rs;
    if (std.mem.endsWith(u8, path, ".py")) return .py;
    if (std.mem.endsWith(u8, path, ".html")) return .html;
    if (std.mem.endsWith(u8, path, ".css")) return .css;
    if (std.mem.endsWith(u8, path, ".js")) return .js;
    if (std.mem.endsWith(u8, path, ".jsx")) return .jsx;
    if (std.mem.endsWith(u8, path, ".ts")) return .ts;
    if (std.mem.endsWith(u8, path, ".tsx")) return .tsx;
    if (std.mem.endsWith(u8, path, ".json")) return .json;
    return .unknown;
}
