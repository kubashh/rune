const std = @import("std");
const consts = @import("./lib/consts.zig");

const allocator = consts.allocator;
const print = consts.print;
const Config = consts.Config;

pub fn main(init: std.process.Init) !void {
    // const rawArgs = init.minimal.args.vector;
    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer args.deinit();

    var config: Config = .{
        .input = null,
        .output = null,
        .opt = .Safe,
    };

    // Skip exe path
    _ = args.skip();

    if (args.next()) |inputPath| {
        config.input = .{ .path = inputPath, .extention = getExtention(inputPath) };
    }

    if (args.next()) |outputPathOrFlag| {
        if (outputPathOrFlag[0] == '-') {
            handleArg(&config, outputPathOrFlag);
        } else {
            config.output = .{ .path = outputPathOrFlag, .extention = getExtention(outputPathOrFlag) };
        }
    }

    while (args.next()) |arg| {
        handleArg(&config, arg);
    }

    // Print the configuration
    if (config.input) |input| {
        print("Input path: {s}\n", .{input.path});
    } else {
        print("Input path: null\n", .{});
    }
    if (config.output) |output| {
        print("Output path: {s}\n", .{output.path});
    } else {
        print("Output path: null\n", .{});
    }
    print("Optimization level: {}\n", .{config.opt});

    // Run
    run(&config);
}

fn handleArg(config: *Config, arg: []const u8) void {
    // Handle optimization flags
    if (std.mem.eql(u8, arg, "--safe")) {
        config.opt = .Safe;
    } else if (std.mem.eql(u8, arg, "--release")) {
        config.opt = .Release;
    } else if (std.mem.eql(u8, arg, "--tiny")) {
        config.opt = .Tiny;
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
        \\Usage: rune [input_path] [output_path] [flags]
        \\Flags:
        \\  --safe | --release | --tiny                     Set optimization level (default: --safe)
        \\  --linux | --windows | --macos | --freebsd       Set target OS (default: current OS)
        \\
        \\  -h, --help:                                     Show this help message
        \\
        \\Example usage:
        \\  rune src/main.c dist/main --release
        \\  rune src/main.ts dist/main.js --tiny
        \\  rune src/index.html dist/index.html --tiny
        \\
        \\Supported extentions:
        \\  TODO: .c, .zig
        \\
    , .{});
}

fn getExtention(path: []const u8) consts.Extention {
    if (std.mem.endsWith(u8, path, ".c")) {
        return .C;
    } else if (std.mem.endsWith(u8, path, ".zig")) {
        return .Zig;
    } else if (std.mem.endsWith(u8, path, ".rs")) {
        return .Rust;
    } else if (std.mem.endsWith(u8, path, ".js")) {
        return .Js;
    } else if (std.mem.endsWith(u8, path, ".jsx")) {
        return .Jsx;
    } else if (std.mem.endsWith(u8, path, ".ts")) {
        return .Ts;
    } else if (std.mem.endsWith(u8, path, ".tsx")) {
        return .Tsx;
    } else if (std.mem.endsWith(u8, path, ".html")) {
        return .Html;
    } else if (std.mem.endsWith(u8, path, ".css")) {
        return .Css;
    } else {
        return .Unknown;
    }
}

fn run(config: *Config) void {
    print("Running with config: {any}\n", .{config});
}
