const std = @import("std");
const consts = @import("./lib/consts.zig");
const cli = @import("./cli/cli.zig");
const compileProgram = @import("./compileProgram.zig");
const runProgram = @import("./runProgram.zig");

const Config = consts.Config;

pub fn main(init: std.process.Init) void {
    const allocator = init.arena.allocator();
    var config: Config = cli.processArgs(init.minimal.args, allocator);

    compileProgram.compileProgram(init.io, &config);

    if (config.runArgs) |*runArgs| {
        if (config.info) runProgram.printRunInfo(runArgs.items);
        runProgram.runProgram(init.io, runArgs.items);
        runArgs.deinit(allocator);
    }
}
