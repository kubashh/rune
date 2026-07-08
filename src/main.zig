const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");
const ci = @import("./ci.zig");

const Config = consts.Config;
const Extention = consts.Extention;
const Color = consts.Color;

const print = util.print;
const printErrExit = util.printErrExit;
const strcmp = util.strcmp;
const spawnSync = util.spawnSync;
const fileExistsCwd = util.fileExistsCwd;
const measureStart = util.measureStart;
const measurePrint = util.measurePrint;

pub fn main(init: std.process.Init) !void {
    var config: Config = ci.processArgs(init);

    try compileProgram(init.io, &config);

    // Run program
    if (config.run) {
        try runProgram(init.io, config.outputPath);
    }
}

fn compileProgram(io: std.Io, config: *Config) !void {
    var buf: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const alloc = fba.allocator();
    const outdir: []const u8 = std.fs.path.dirname(config.outputPath).?;

    processInputExistense(io, config.inputPath);

    const command: []const u8 = try createCommandAlloc(alloc, config);
    defer alloc.free(command);

    printConfig(config, command);
    try makeOutdir(io, outdir);

    // Real compilation
    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{ "sh", "-c", command },
        .stdin = .ignore,
        .stdout = .inherit,
        .stderr = .inherit,
    });
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
    if (!fileExistsCwd(io, inputPath)) {
        printErrExit("file '{s}' not exists!\n", .{inputPath});
    }
}

fn createCommandAlloc(alloc: std.mem.Allocator, config: *Config) ![]const u8 {
    switch (config.extention) {
        // zig build-exe src/main.zig -Doptimize=ReleaseSafe --name rune2 -femit-bin=dist/bin/rune4 --cache-dir .cache/zig --global-cache-dir /home/jakub/.cache/zig --zig-lib-dir /opt/zig-0.16.0/lib/ -target x86_64-macos
        .zig => return try std.fmt.allocPrint(
            alloc,
            "zig build-exe {s} -femit-bin={s} -Doptimize={s} -target {s} --cache-dir .cache/zig",
            .{
                config.inputPath,
                config.outputPath,
                getOptimizeZig(config.opt),
                getTargetZig(config.target),
            },
        ),
        .rs => printErrExit("rust not supported yet!\n", .{}),
        .c => return try std.fmt.allocPrint(
            alloc,
            "zig cc {s} -o {s} -Doptimize={s} -target {s}",
            .{
                config.inputPath,
                config.outputPath,
                getOptimizeZig(config.opt),
                getTargetZig(config.target),
            },
        ),
        .cpp => printErrExit("c++ not supported yet! Working on it\n", .{}),
        else => printErrExit(
            Color.red ++ "unknown file extetnion:" ++ Color.reset ++ " {}\n",
            .{config.extention},
        ),
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
        .@"linux-aarch64" => "aarch64-linux",
        .@"macos-x86_64" => "x86_64-macos",
        .@"macos-aarch64" => "aarch64-macos",
        .@"windows-x86_64" => "x86_64-windows",
        .@"windows-x86_64-gnu" => "x86_64-windows-gnu",
        .browser => "wasi-freestanding",
    };
}

fn makeOutdir(io: std.Io, outdir: []const u8) !void {
    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{ "mkdir", "-p", outdir },
        .stdin = .ignore,
        .stdout = .ignore,
        .stderr = .ignore,
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
