const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Config = consts.Config;

const print = util.print;
const SpawnSyncError = util.SpawnSyncError;
const spawnSync = util.spawnSync;
const spawnSyncInherit = util.spawnSyncInherit;

pub fn runProgram(io: std.Io, config: Config) SpawnSyncError!void {
    switch (config.runner) {
        .native => try runNative(io, config),
        .wine => try runWine(io, config),
        else => {},
    }
}

fn runNative(io: std.Io, config: Config) SpawnSyncError!void {
    print("running {s}...\n\n", .{config.outputPath});

    _ = try spawnSyncInherit(io, &[_][]const u8{
        config.outputPath,
    });
}

fn runWine(io: std.Io, config: Config) SpawnSyncError!void {
    print("running {s} with wine...\n\n", .{config.outputPath});

    _ = try spawnSyncInherit(io, &[_][]const u8{
        "wine",
        config.outputPath,
    });
}
