const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Config = consts.Config;

const printErrExit = util.printErrExit;
const spawnSyncInherit = util.spawnSyncInherit;

pub fn runProgram(io: std.Io, config: Config) void {
    switch (config.runner) {
        .native => runNative(io, config),
        .wineUnchecked => runWine(io, config),
        else => {},
    }
}

fn runNative(io: std.Io, config: Config) void {
    std.log.info("running {s}...\n", .{config.outputPath});

    _ = spawnSyncInherit(io, &[_][]const u8{
        config.outputPath,
    }) catch |err|
        printErrExit("running on native system. err: {}\n", .{err});
}

fn runWine(io: std.Io, config: Config) void {
    std.log.info("running {s} with wine...\n", .{config.outputPath});

    _ = spawnSyncInherit(io, &[_][]const u8{
        "wine",
        config.outputPath,
    }) catch |err|
        printErrExit("running on native system. err: {}\n", .{err});
}
