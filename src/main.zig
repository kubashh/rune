const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");
const ci = @import("./ci.zig");

const allocator = consts.allocator;
const Config = consts.Config;
const Extention = consts.Extention;
const Color = consts.Color;

const print = util.print;
const printErrExit = util.printErrExit;
const strcmp = util.strcmp;
const spawnSync = util.spawnSync;
const fileExists = util.fileExists;
const measureStart = util.measureStart;
const measurePrint = util.measurePrint;

pub fn main(init: std.process.Init) !void {
    var config: Config = ci.processArgs(init.minimal.args);

    try run(init.io, &config);
}

fn run(io: std.Io, config: *Config) !void {
    // Later should use FixedBufferAllocator => increase performance
    // var fixed_buf: [128]u8 = undefined;
    // // FixedBufferAllocator allocates out of a caller-provided slice.
    // var fba = std.heap.FixedBufferAllocator.init(&fixed_buf);
    // const fixed_allocator = fba.allocator();
    const outdir: []const u8 = std.fs.path.dirname(config.outputPath).?;

    processInputExistense(io, config.inputPath);

    const command: []const u8 = try createCommandAlloc(config);

    printConfig(config, command);
    try makeOutdir(io, outdir);
    try compileProgram(io, command);

    // Run program
    if (config.run) {
        try runProgram(io, config.outputPath);
    }

    allocator.free(command);
}

fn createCommandAlloc(config: *Config) ![]const u8 {
    switch (config.extention) {
        // zig build-exe src/main.zig -Doptimize=ReleaseSafe --name rune2 -femit-bin=dist/bin/rune4 --cache-dir .cache/zig --global-cache-dir /home/jakub/.cache/zig --zig-lib-dir /opt/zig-0.16.0/lib/ -target x86_64-macos
        .zig => {
            printErrExit("zig not supported yet!\n", .{});
        },
        .rs => {
            printErrExit("rust not supported yet!\n", .{});
        },
        .c => return try std.fmt.allocPrint(
            allocator,
            "ZIG_LIB_DIR={s} && zig cc {s} -o {s} -Doptimize={s} -target {s}",
            .{
                config.zigLibDir,
                config.inputPath,
                config.outputPath,
                getOptimizeZig(config.opt),
                getTargetZig(config.target),
            },
        ),
        else => {
            printErrExit(Color.red ++ "unknown file extetnion:" ++ Color.reset ++ " {}\n", .{config.extention});
        },
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

fn getTargetZig(target: consts.Target) []const u8 {
    return switch (target) {
        .@"linux-x86_64" => "x86_64-linux",
        .@"linux-x86_64-musl" => "x86_64-linux-musl",
        .@"linux-x86" => "x86-linux",
        .@"macos-x86_64" => "x86_64-macos",
        .@"macos-aarch64" => "aarch64-macos",
        .@"windows-x86_64" => "x86_64-windows",
        .@"windows-x86_64-gnu" => "x86_64-windows-gnu",
        .browser => "wasi-freestanding",
    };
}

fn printConfig(config: *Config, command: []const u8) void {
    print(
        \\input path:   {s}
        \\output path:  {s}
        \\optimization: {}
        \\target:       {}
        \\exe command:  {s}
        \\
        \\
    , .{
        config.inputPath,
        config.outputPath,
        config.opt,
        config.target,
        command,
    });
}

fn processInputExistense(io: std.Io, inputPath: []const u8) void {
    if (!fileExists(io, inputPath)) {
        printErrExit("file '{s}' not exists!\n", .{inputPath});
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
    print("running {s}...\n\n", .{outputPath});

    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{outputPath},
        .stdin = .inherit,
        .stdout = .inherit,
        .stderr = .inherit,
    });
}
