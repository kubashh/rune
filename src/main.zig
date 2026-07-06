const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");
const ci = @import("./ci.zig");

const print = std.debug.print;
const Timestamp = std.Io.Timestamp;

const allocator = consts.allocator;
const Config = consts.Config;
const Extention = consts.Extention;
const Color = consts.Color;

const spawnSync = util.spawnSync;
const fileExists = util.fileExists;
const measureStart = util.measureStart;
const measurePrint = util.measurePrint;

pub fn main(init: std.process.Init) !void {
    // const rawArgs = init.minimal.args.vector;
    var config: Config = ci.processArgs(init.minimal.args);

    // Run
    try run(init.io, &config);
}

fn run(io: std.Io, config: *Config) !void {
    const outdir: []const u8 = std.fs.path.dirname(config.outputPath).?;

    // const start = measureStart(io);
    processInputExistense(io, config.inputPath); // ~1ms
    // measurePrint(io, start);

    const command: []const u8 = try createCommand(config);

    printConfig(config, command);
    try makeOutdir(io, outdir);
    try compileProgram(io, command);

    // Run program
    if (config.run) {
        try runProgram(io, config.outputPath);
    }
}

fn getOptimizeZig(opt: consts.Optimization) []const u8 {
    return switch (opt) {
        .debug => "Debug",
        .safe => "ReleaseSafe",
        .release => "ReleaseFast",
        .size => "ReleaseSize",
    };
}

fn getTargetZig(config: *Config) []const u8 {
    return switch (config.os) {
        .linux => switch (config.arch) {
            .x86_64 => switch (config.abi) {
                .gnu => "x86_64-linux-gnu",
                .musl => "x86_64-linux-musl",
                else => {
                    print("linux can't have other abi than gnu | musl!\n", .{});
                    std.process.exit(1);
                },
            },
            .x86 => "x86_64-linux",
        },
        .macos => switch (config.arch) {
            .x86_64 => "x86_64-macos",
            .x86 => "x86_64-macos",
        },
        .windows => switch (config.arch) {
            .x86_64 => "x86_64-windows",
            .x86 => "x86_64-windows",
        },
    };
}

fn createCommand(config: *Config) ![]const u8 {
    switch (config.extention) {
        .c => {
            // zig build-exe src/main.zig -Doptimize=ReleaseSafe --name rune2 -femit-bin=dist/bin/rune4 --cache-dir .cache/zig --global-cache-dir /home/jakub/.cache/zig --zig-lib-dir /opt/zig-0.16.0/lib/ -target x86_64-macos
            const command = try std.fmt.allocPrint(
                allocator,
                "export ZIG_LIB_DIR={s} && zig cc {s} -o {s} -Doptimize={s} -target {s}",
                .{
                    config.zigLibDir,
                    config.inputPath,
                    config.outputPath,
                    getOptimizeZig(config.opt),
                    getTargetZig(config),
                },
            );
            return command;
        },
        else => {
            print(Color.red ++ "Unknown file extetnion:" ++ Color.reset ++ " {s}\n", .{config.inputPath});
            std.process.exit(1);
        },
    }
}

fn printConfig(config: *Config, command: []const u8) void {
    print(
        \\Input path:   {s}; Extention: {}
        \\Output path:  {s}
        \\Optimization: {}
        \\os: {}; arch: {}; abi: {}
        \\Exe command:  {s}
        \\
        \\
    , .{
        config.inputPath,
        config.extention,
        config.outputPath,
        config.opt,
        config.os,
        config.arch,
        config.abi,
        command,
    });
}

fn processInputExistense(io: std.Io, inputPath: []const u8) void {
    if (!fileExists(io, inputPath)) {
        print("File '{s}' not exists!\n", .{inputPath});
        std.process.exit(1);
    }
}

fn makeOutdir(io: std.Io, outdir: []const u8) !void {
    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{ "mkdir", "-p", outdir },
        .stdin = .ignore,
        .stdout = .ignore,
        .stderr = .ignore,
    });
}

fn compileProgram(io: std.Io, command: []const u8) !void {
    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{ "sh", "-c", command },
        .stdin = .ignore,
        .stdout = .inherit,
        .stderr = .inherit,
    });
}

fn runProgram(io: std.Io, outputPath: []const u8) !void {
    print("Running {s}...\n\n", .{outputPath});

    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{outputPath},
        .stdin = .inherit,
        .stdout = .inherit,
        .stderr = .inherit,
    });
}
