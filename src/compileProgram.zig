const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Config = consts.Config;
const Color = consts.Color;

const print = util.print;
const printErrExit = util.printErrExit;
const SpawnSyncError = util.SpawnSyncError;
const spawnSync = util.spawnSync;
const fileExistsCwd = util.fileExistsCwd;
const CreateDirPathCwdError = util.CreateDirPathCwdError;
const createDirPathCwd = util.createDirPathCwd;
const measureStart = util.measureStart;
const measurePrint = util.measurePrint;

pub const CompileProgramError = error{OutOfMemory} || SpawnSyncError || CreateDirPathCwdError;

pub fn compileProgram(io: std.Io, config: *Config) CompileProgramError!void {
    var buf: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const alloc = fba.allocator();
    const outdir: []const u8 = std.fs.path.dirname(config.outputPath).?;

    processInputExistense(io, config.inputPath);

    const buildCommand: []const u8 = try createBuildCommandAlloc(alloc, config);
    defer alloc.free(buildCommand);

    printConfig(config, buildCommand);
    try createDirPathCwd(io, outdir);

    // Real compilation
    _ = try spawnSync(io, .{
        .argv = &[_][]const u8{ "sh", "-c", buildCommand },
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
        \\build command:  {s}
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

fn createBuildCommandAlloc(alloc: std.mem.Allocator, config: *Config) error{OutOfMemory}![]const u8 {
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
