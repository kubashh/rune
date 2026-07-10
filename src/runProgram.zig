const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const tmp_alloc = consts.tmp_alloc;
const StringList = consts.StringList;
const Color = consts.Color;
const Runner = consts.Runner;
const RunArgs = consts.RunArgs;
const Config = consts.Config;

const printErrExit = util.printErrExit;
const SpawnSyncError = util.SpawnSyncError;
const spawnSyncInherit = util.spawnSyncInherit;

pub fn runProgram(io: std.Io, config: *Config) void {
    if (config.runArgs) |*runArgs| {
        printRunInfo(runArgs);

        _ = spawnSyncInherit(io, runArgs.items) catch |err|
            printRunErrExit(config, err);
    }
}

fn printRunInfo(exeArgs: *StringList) void {
    std.debug.print(
        Color.green ++ Color.bold_on ++ "info" ++ Color.bright_black ++ ":" ++ Color.reset ++ " running",
        .{},
    );
    for (exeArgs.items) |arg|
        if (std.mem.indexOfScalar(u8, arg, ' ') != null)
            std.debug.print(" '{s}'", .{arg})
        else
            std.debug.print(" {s}", .{arg});

    std.debug.print("\n\n", .{});
}

fn printRunErrExit(config: *Config, err: SpawnSyncError) noreturn {
    if (config.runArgs) |runArgs| {
        printErrExit(
            "running with {s} with args: '{s}'. err: {}\n",
            .{ getRunnerName(config.runner), runArgs.getLast(), err },
        );
    }

    printErrExit("running on native system. err: {}\n", .{err});
}

fn getRunnerName(runner: Runner) []const u8 {
    return switch (runner) {
        .native => "native system",
        .wine => "wine",
        .none => printErrExit("runner can't be empty! rune error it is not your mistake\n", .{}),
    };
}
