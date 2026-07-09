const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Runner = consts.Runner;
const RunArgs = consts.RunArgs;
const Config = consts.Config;

const printErrExit = util.printErrExit;
const SpawnSyncError = util.SpawnSyncError;
const spawnSyncInherit = util.spawnSyncInherit;

const ExeArgs = [3][]const u8;

pub fn runProgram(io: std.Io, config: Config) void {
    if (config.runner == .none) return;

    printRunInfo(config);

    // TODO fix runProgram with "" (empty string)
    var exeArgs: ExeArgs = .{ undefined, undefined, undefined };

    switch (config.runner) {
        .native => createCommandNative(&exeArgs, config),
        .wineUnchecked => createCommandWine(&exeArgs, config),
        else => {}, // It will never happen
    }

    _ = spawnSyncInherit(io, &exeArgs) catch |err|
        printRunErrExit(config, err);
}

fn createCommandNative(exeArgs: *ExeArgs, config: Config) void {
    exeArgs[0] = config.outputPath;
    exeArgs[1] = "";
    if (config.runArgs) |runArgs| {
        exeArgs[2] = runArgs.getLast();
    } else {
        exeArgs[2] = "";
    }
}

fn createCommandWine(exeArgs: *ExeArgs, config: Config) void {
    exeArgs[0] = "wine";
    exeArgs[1] = config.outputPath;
    if (config.runArgs) |runArgs| {
        exeArgs[2] = runArgs.getLast();
    } else {
        exeArgs[2] = "";
    }
}

fn printRunInfo(config: Config) void {
    if (config.runArgs) |runArgs| {
        std.log.info(
            "running {s} with {s} with args: '{s}'...\n",
            .{ config.outputPath, getRunnerName(config.runner), runArgs.getLast() },
        );
    } else {
        std.log.info("running {s} with {s}...\n", .{ config.outputPath, getRunnerName(config.runner) });
    }
}

fn printRunErrExit(config: Config, err: SpawnSyncError) noreturn {
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
        .wineUnchecked => "wine",
        else => "",
    };
}
