const std = @import("std");
const consts = @import("./lib/consts.zig");
const cli = @import("./cli/cli.zig");
const compileProgram = @import("./build/compileProgram.zig");
const runProgram = @import("./run/runProgram.zig");

const Config = consts.Config;

pub fn main(init: std.process.Init) void {
    const allocator = init.arena.allocator();
    var config: Config = cli.processArgs(init.minimal.args, allocator);

    compileProgram.compileProgram(init.io, &config);

    if (config.runner != .none or config.run_args != null) {
        // it may look strage, but it is safe
        // TODO make run command (run_args) in runProgram.zig and name it run_command
        if (config.info) runProgram.printRunInfo(config.run_args.?.items);
        runProgram.runProgram(init.io, config);
        config.run_args.?.deinit(allocator);
    }
}
