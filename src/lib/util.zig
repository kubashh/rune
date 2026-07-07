const std = @import("std");
const consts = @import("./consts.zig");

const Color = consts.Color;

const SpwanSyncError = std.process.SpawnError || std.process.Child.WaitError;

pub const print = std.debug.print;

pub fn printErrExit(comptime fmt: []const u8, options: anytype) noreturn {
    std.debug.print(Color.red ++ "error:" ++ Color.reset ++ " " ++ fmt ++ "run 'rune --help' for usage\n", options);
    std.process.exit(1);
}

pub fn spawnSync(io: std.Io, options: std.process.SpawnOptions) SpwanSyncError!std.process.Child.Term {
    var child = try std.process.spawn(io, options);
    return try child.wait(io);
}

// TODO use zig 0.16.0 file api's because of performance. Function for now works
pub fn fileExistsCwd(io: std.Io, path: []const u8) bool {
    const cwd = std.Io.Dir.cwd();
    _ = cwd.statFile(io, path, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return true, // exists but e.g. permission; treat as "exists"
    };
    return true;
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
