const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Color = consts.Color;

const printErrExit = util.printErrExit;
const printCommand = util.printCommand;
const SpawnSyncError = util.SpawnSyncError;
const spawnSyncInherit = util.spawnSyncInherit;

pub fn runProgram(io: std.Io, run_args_items: []const []const u8) void {
    _ = spawnSyncInherit(io, run_args_items) catch |err|
        printRunErrExit(run_args_items, err);
}

pub fn printRunInfo(run_args_items: []const []const u8) void {
    std.debug.print(
        Color.green ++ Color.bold_on ++ "info" ++ Color.bright_black ++ ":" ++ Color.reset ++ " running",
        .{},
    );
    printCommand(run_args_items);
    std.debug.print("\n\n", .{});
}

fn printRunErrExit(run_args_items: []const []const u8, err: SpawnSyncError) noreturn {
    std.debug.print("when running ", .{});
    printCommand(run_args_items);
    printErrExit(". err: {}\n", .{err});
}
