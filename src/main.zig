const std = @import("std");
const consts = @import("./lib/consts.zig");
const cli = @import("./cli/cli.zig");
const compileProgram = @import("./build/compileProgram.zig");
const runProgram = @import("./runProgram.zig");

const Config = consts.Config;

pub fn main(init: std.process.Init) void {
    const allocator = init.arena.allocator();
    var config: Config = cli.processArgs(init.minimal.args, allocator);

    compileProgram.compileProgram(init.io, &config);

    if (config.run_args) |*run_args| {
        if (config.info) runProgram.printRunInfo(run_args.items);
        runProgram.runProgram(init.io, run_args.items);
        run_args.deinit(allocator);
    }
}
