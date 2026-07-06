const std = @import("std");
const builtin = @import("builtin");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const print = std.debug.print;

const Config = consts.Config;
const Extention = consts.Extention;

pub fn processArgs(argv: std.process.Args) Config {
    var args = std.process.Args.Iterator.init(argv);
    defer args.deinit();

    // Skip exe path
    _ = args.skip();

    var inputPath: []const u8 = undefined;
    var extention: Extention = .unknown;

    if (args.next()) |firstArg| {
        if (firstArg[0] == '-') {
            print("First argument is input path, never flag!\nArg passed: {s}\n", .{firstArg});
            std.process.exit(0);
        }
        inputPath = firstArg;
        extention = getExtention(firstArg);
    } else {
        // TODO handle rune.json
        print("No entry specified!\n\n", .{});
        printUsage();
        std.process.exit(0);
    }

    var config: Config = .{
        .inputPath = inputPath,
        .outputPath = ".cache/rune/tmp",
        .extention = extention,
        .opt = .debug,
        .os = switch (builtin.target.os.tag) {
            .linux => .linux,
            .windows => .windows,
            .macos => .macos,
            else => .linux,
        },
        .arch = switch (builtin.target.cpu.arch) {
            .x86_64 => .x86_64,
            .x86 => .x86,
            // .aarch64 => .aarch64,
            // .arm => .arm,
            else => .x86_64,
        },
        .abi = switch (builtin.target.abi) {
            .gnu => .gnu,
            .musl => .musl,
            .msvc => .msvc,
            else => .none,
        },
        .zigLibDir = "/opt/zig-0.16.0/lib",
        .run = true,
    };

    if (args.next()) |outputPathOrFlag| {
        if (outputPathOrFlag[0] == '-') {
            handleArg(&config, outputPathOrFlag);
        } else {
            config.outputPath = outputPathOrFlag;
            config.run = false;
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

    // Handle help
    if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
        printUsage();
        std.process.exit(0);
    }

    // Unhandled arg
    print("Unhandled arg: {s}\n\n", .{arg});
    printUsage();
    std.process.exit(1);
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
        var archString: []const u8 = undefined;
        var abiString: []const u8 = undefined;
        if (std.mem.indexOfScalar(u8, value, '-')) |pos2| {
            const osString = value[0..pos2];
            config.os = handleOs(osString);

            archString = value[pos2 + 1 ..];
            if (std.mem.indexOfScalar(u8, archString, '-')) |pos3| {
                abiString = archString[pos3 + 1 ..];
                archString = archString[0..pos3];
                config.abi = handleAbi(archString);
            } else {
                config.abi = switch (config.os) {
                    .linux => .gnu,
                    .macos => .none,
                    .windows => .msvc,
                };
            }

            config.arch = handleArch(archString);
        } else {
            print("You need specify arch in --target!\n", .{});
            std.process.exit(1);
        }
    } else {
        print("Bad --target flag!\nTry: --target=[system]-[arch]", .{});
        std.process.exit(1);
    }

    return true;
}

fn handleOs(osString: []const u8) consts.OsTags {
    if (std.mem.eql(u8, osString, "linux")) return .linux;
    if (std.mem.eql(u8, osString, "macos")) return .macos;
    if (std.mem.eql(u8, osString, "windows")) return .windows;
    print(
        \\unsupported os!
        \\try use --target-[os]-[arch]-[abi?]
        \\supported os's: linux, windows, macos
        \\
    , .{});
    std.process.exit(1);
}

fn handleArch(archString: []const u8) consts.Arch {
    if (std.mem.eql(u8, archString, "x86_64")) return .x86_64;
    if (std.mem.eql(u8, archString, "x86")) return .x86;
    print(
        \\unsupported arch!
        \\try use --target-[os]-[arch]-[abi?]
        \\supported arch's: x86_64, x86
        \\
    , .{});
    std.process.exit(1);
}

fn handleAbi(abiString: []const u8) consts.Abi {
    if (std.mem.eql(u8, abiString, "gnu")) return .gnu;
    if (std.mem.eql(u8, abiString, "musl")) return .musl;
    if (std.mem.eql(u8, abiString, "msvc")) return .msvc;
    return .none;
}

fn printUsage() void {
    print(
        \\Usage: rune [input_path] [output_path | flag] [flags]
        \\Flags:
        \\  --debug | --safe | --release | --size           Set optimization level (default: --debug)
        \\  --linux | --windows | --macos | --freebsd       Set target OS (default: current OS)
        \\
        \\  -h, --help                                      Show this help message
        \\
        \\Example usage:
        \\  rune src/main.c dist/main --release
        \\  rune src/server.ts
        \\  rune src/main.ts dist/main.js --size
        \\  rune src/index.html dist/index.html --size
        \\
        \\Supported extentions:
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
