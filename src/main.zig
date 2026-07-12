const std = @import("std");
const consts = @import("./lib/consts.zig");
const ci = @import("./ci.zig");
const checkAllPrograms = @import("./checkAllPrograms.zig");
const compileProgram = @import("./compileProgram.zig");
const runProgram = @import("./runProgram.zig");

const Config = consts.Config;

pub fn main(init: std.process.Init) void {
    var config: Config = ci.processArgs(init.minimal.args);

    checkAllPrograms.checkAllPrograms(init.io, &config);

    compileProgram.compileProgram(init.io, &config);

    if (config.runArgs) |*runArgs| {
        if (config.info) runProgram.printRunInfo(runArgs.items);
        runProgram.runProgram(init.io, runArgs.items);
        runArgs.deinit(consts.tmp_alloc);
    }
}
