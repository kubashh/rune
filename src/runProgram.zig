const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const tmp_alloc = consts.tmp_alloc;
const StringList = consts.StringList;
const Runner = consts.Runner;
const RunArgs = consts.RunArgs;
const Config = consts.Config;

const printErrExit = util.printErrExit;
const SpawnSyncError = util.SpawnSyncError;
const spawnSyncInherit = util.spawnSyncInherit;

pub fn runProgram(io: std.Io, config: Config) void {
    if (config.runner == .none) return;

    printRunInfo(config);

    var exeArgs = StringList.initCapacity(tmp_alloc, 8) catch
        printErrExit("out of memory when making run args ArrayList", .{});
    defer exeArgs.deinit(tmp_alloc);

    switch (config.runner) {
        .native => createCommandNative(&exeArgs, config),
        .wine => createCommandWine(&exeArgs, config),
        else => {}, // It will never happen
    }

    // cross-runner add args
    if (config.runArgs) |runArgs| {
        exeArgs.append(tmp_alloc, runArgs.getLast()) catch
            printErrExit("out of memory when allocating run arg", .{});
    }

    _ = spawnSyncInherit(io, exeArgs.items) catch |err|
        printRunErrExit(config, err);
}

fn createCommandNative(exeArgs: *StringList, config: Config) void {
    exeArgs.append(tmp_alloc, config.outputPath) catch
        printErrExit("out of memory when allocating run arg", .{});
}

fn createCommandWine(exeArgs: *StringList, config: Config) void {
    exeArgs.append(tmp_alloc, "wine") catch
        printErrExit("out of memory when allocating run arg", .{});
    exeArgs.append(tmp_alloc, config.outputPath) catch
        printErrExit("out of memory when allocating run arg", .{});
}

fn printRunInfo(config: Config) void {
    if (config.runArgs) |runArgs| {
        std.log.info(
            "running {s} {s} '{s}'\n",
            .{ getRunnerName(config.runner), config.outputPath, runArgs.getLast() },
        );
    } else {
        std.log.info("running {s} {s}\n", .{ getRunnerName(config.runner), config.outputPath });
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
        .wine => "wine",
        else => "",
    };
}
