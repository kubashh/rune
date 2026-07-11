const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Color = consts.Color;

const printErrExit = util.printErrExit;
const SpawnSyncError = util.SpawnSyncError;
const spawnSyncInherit = util.spawnSyncInherit;

pub fn runProgram(io: std.Io, runArgsItems: []const []const u8) void {
    printRunInfo(runArgsItems);

    _ = spawnSyncInherit(io, runArgsItems) catch |err|
        printRunErrExit(runArgsItems, err);
}

// for now is fast enought but in future consider make one buffer and print it ones.
// make struct PrintBuffer: init(buf_len), add(str), print()
fn printRunInfo(runArgsItems: []const []const u8) void {
    std.debug.print(
        Color.green ++ Color.bold_on ++ "info" ++ Color.bright_black ++ ":" ++ Color.reset ++ " running",
        .{},
    );
    printRunCommand(runArgsItems);
    std.debug.print("\n\n", .{});
}

fn printRunErrExit(runArgsItems: []const []const u8, err: SpawnSyncError) noreturn {
    std.debug.print("when running ", .{});
    printRunCommand(runArgsItems);
    printErrExit(". err: {}\n", .{err});
}

fn printRunCommand(runArgsItems: []const []const u8) void {
    for (runArgsItems) |arg|
        if (std.mem.indexOfScalar(u8, arg, ' ') != null)
            std.debug.print(" '{s}'", .{arg})
        else
            std.debug.print(" {s}", .{arg});
}
