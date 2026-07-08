const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");
const ci = @import("./ci.zig");
const compileProgram = @import("./compileProgram.zig");
const runProgram = @import("./runProgram.zig");

const Config = consts.Config;

const measureStart = util.measureStart;
const measurePrint = util.measurePrint;

const CompileProgramError = compileProgram.CompileProgramError;

pub fn main(init: std.process.Init) CompileProgramError!void {
    var config: Config = ci.processArgs(init);

    try compileProgram.compileProgram(init.io, &config);

    try runProgram.runProgram(init.io, config);
}
