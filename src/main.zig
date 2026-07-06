const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const print = std.debug.print;

const allocator = consts.allocator;
const Config = consts.Config;
const Extention = consts.Extention;

const spawnSync = util.spawnSync;

pub fn main(init: std.process.Init) !void {
    // const rawArgs = init.minimal.args.vector;
    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer args.deinit();

    // Skip exe path
    _ = args.skip();

    var inputPath: []const u8 = undefined;
    var extention: Extention = .Unknown;

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
        .opt = .Debug,
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

    // Print the configuration
    print(
        \\Input path: {s}; Extention: {}
        \\Output path: {s}
        \\Optimization: {}
        \\
    , .{ inputPath, config.extention, config.outputPath, config.opt });

    // Run
    try run(init.io, &config);
}

fn handleArg(config: *Config, arg: []const u8) void {
    // Handle optimization flags
    if (std.mem.eql(u8, arg, "--debug")) {
        config.opt = .Debug;
    } else if (std.mem.eql(u8, arg, "--safe")) {
        config.opt = .Safe;
    } else if (std.mem.eql(u8, arg, "--release")) {
        config.opt = .Release;
    } else if (std.mem.eql(u8, arg, "--size")) {
        config.opt = .Size;
    } else if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) { // Handle help
        printUsage();
        std.process.exit(0);
    } else { // Unhandled arg
        print("Unhandled arg: {s}\n\n", .{arg});
        printUsage();
        std.process.exit(0);
    }
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
    if (std.mem.endsWith(u8, path, ".c")) return .C;
    if (std.mem.endsWith(u8, path, ".cpp")) return .Cpp;
    if (std.mem.endsWith(u8, path, ".cs")) return .Cs;
    if (std.mem.endsWith(u8, path, ".java")) return .Java;
    if (std.mem.endsWith(u8, path, ".zig")) return .Zig;
    if (std.mem.endsWith(u8, path, ".rs")) return .Rust;
    if (std.mem.endsWith(u8, path, ".py")) return .Py;
    if (std.mem.endsWith(u8, path, ".html")) return .Html;
    if (std.mem.endsWith(u8, path, ".css")) return .Css;
    if (std.mem.endsWith(u8, path, ".js")) return .Js;
    if (std.mem.endsWith(u8, path, ".jsx")) return .Jsx;
    if (std.mem.endsWith(u8, path, ".ts")) return .Ts;
    if (std.mem.endsWith(u8, path, ".tsx")) return .Tsx;
    if (std.mem.endsWith(u8, path, ".json")) return .Json;
    return .Unknown;
}

fn run(io: std.Io, config: *Config) !void {
    var command: []u8 = undefined;
    const outdir: []const u8 = std.fs.path.dirname(config.outputPath).?;

    switch (config.extention) {
        .C => {
            command = try std.fmt.allocPrint(
                allocator,
                "export ZIG_LIB_DIR={s} && zig cc {s} -o {s}",
                .{ config.zigLibDir, config.inputPath, config.outputPath },
            );
        },
        else => {
            print("Unknown file extetnion: {}\n", .{config.extention});
        },
    }

    print("Exe command:\n  {s}\n\n", .{command});

    // Make out dir
    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{ "mkdir", "-p", outdir },
        .stdin = .ignore,
        .stdout = .ignore,
        .stderr = .ignore,
    });

    // Compile Program
    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{ "sh", "-c", command },
        .stdin = .ignore,
        .stdout = .inherit,
        .stderr = .inherit,
    });

    // Run program
    if (config.run) {
        print("Running...\n", .{});
    }
}
