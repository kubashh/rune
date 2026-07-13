const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Color = consts.Color;

const printErrExit = util.printErrExit;
const printCommand = util.printCommand;
const SpawnSyncError = util.SpawnSyncError;
const spawnSyncInherit = util.spawnSyncInherit;

pub fn runProgram(io: std.Io, runArgsItems: []const []const u8) void {
    _ = spawnSyncInherit(io, runArgsItems) catch |err|
        printRunErrExit(runArgsItems, err);
}

pub fn printRunInfo(runArgsItems: []const []const u8) void {
    std.debug.print(
        Color.green ++ Color.bold_on ++ "info" ++ Color.bright_black ++ ":" ++ Color.reset ++ " running",
        .{},
    );
    printCommand(runArgsItems);
    std.debug.print("\n\n", .{});
}

fn printRunErrExit(runArgsItems: []const []const u8, err: SpawnSyncError) noreturn {
    std.debug.print("when running ", .{});
    printCommand(runArgsItems);
    printErrExit(". err: {}\n", .{err});
}
