const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Config = consts.Config;
const Extention = consts.Extention;
const Runner = consts.Runner;

const printErrExit = util.printErrExit;
const cliProgramExists = util.cliProgramExists;

pub fn checkAllPrograms(io: std.Io, config: *Config) void {
    checkCompilerExistence(io, config.extention);
    checkRunnerExistence(io, config.runner);
}

pub fn checkCompilerExistence(io: std.Io, extention: Extention) void {
    switch (extention) {
        .zig, .c, .cpp => if (!cliProgramExists(io, "zig")) printErrExit(
            \\zig don't exists! to compile zig, c, cpp zig is required!
            \\install zig
            \\
        , .{}),
        .rs => if (!cliProgramExists(io, "rustc")) printErrExit(
            \\rustc don't exists! to compile rust rustc is required!
            \\install rustc
            \\
        , .{}),
        else => {},
    }
}

pub fn checkRunnerExistence(io: std.Io, runner: Runner) void {
    switch (runner) {
        .wine => if (!cliProgramExists(io, "wine")) printErrExit(
            \\wine don't exists! to run windows bin's on posix wine is required!
            \\install wine
            \\
        , .{}),
        .native, .none => {},
    }
}
