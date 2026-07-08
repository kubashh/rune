const std = @import("std");
const consts = @import("./consts.zig");

const Color = consts.Color;

pub const print = std.debug.print;

pub fn printErrExit(comptime fmt: []const u8, options: anytype) noreturn {
    print(Color.red ++ "error:" ++ Color.reset ++ " " ++ fmt ++ "run 'rune --help' for usage\n", options);
    std.process.exit(1);
}

pub const SpawnSyncError = std.process.SpawnError || std.process.Child.WaitError;

pub fn spawnSync(io: std.Io, options: std.process.SpawnOptions) SpawnSyncError!u8 {
    var child = try std.process.spawn(io, options);
    const result = try child.wait(io);
    return result.exited;
}

pub fn spawnSyncInherit(io: std.Io, argv: []const []const u8) SpawnSyncError!u8 {
    return try spawnSync(io, .{
        .argv = argv,
        .stdin = .inherit,
        .stdout = .inherit,
        .stderr = .inherit,
    });
}

pub fn fileExistsCwd(io: std.Io, path: []const u8) bool {
    const cwd = std.Io.Dir.cwd();
    _ = cwd.statFile(io, path, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return true, // exists but e.g. permission; treat as "exists"
    };
    return true;
}

pub const CreateDirPathCwdError = std.Io.Dir.CreateDirPathError;

pub fn createDirPathCwd(io: std.Io, path: []const u8) CreateDirPathCwdError!void {
    const cwd = std.Io.Dir.cwd();
    try cwd.createDirPath(io, path);
}

pub inline fn measureStart(io: std.Io) i96 {
    return std.Io.Clock.Timestamp.now(io, .awake).raw.nanoseconds;
}

pub inline fn measurePrint(io: std.Io, start: i96, label: []const u8) void {
    const end = std.Io.Clock.Timestamp.now(io, .awake).raw.nanoseconds;
    const nanos = end - start;
    switch (nanos) {
        0...999 => {
            std.debug.print("{s}: {} ns\n", .{ label, nanos });
        },
        1_000...999_999 => {
            std.debug.print("{s}: {d:.3} us\n", .{ label, @as(f64, @floatFromInt(nanos)) / 1_000.0 });
        },
        1_000_000...999_999_999 => {
            std.debug.print("{s}: {d:.3} ms\n", .{ label, @as(f64, @floatFromInt(nanos)) / 1_000_000.0 });
        },
        else => {
            std.debug.print("{s}: {d:.3} s\n", .{ label, @as(f64, @floatFromInt(nanos)) / 1_000_000_000.0 });
        },
    }
}
