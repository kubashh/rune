const std = @import("std");

const allocator = std.heap.page_allocator;
const print = std.debug.print;

const Opt = enum { Safe, Realese, Tiny };

const Config = struct {
    inputPath: ?[]const u8,
    outputPath: ?[]const u8,
    opt: Opt,
};

var config: Config = .{
    .inputPath = null,
    .outputPath = null,
    .opt = .Safe,
};

pub fn main(init: std.process.Init) !void {
    // const rawArgs = init.minimal.args.vector;
    var args = std.process.Args.Iterator.init(init.minimal.args);
    defer _ = args.deinit();

    // Skip exe path
    _ = args.skip();

    if (args.next()) |firstArg| {
        config.inputPath = firstArg;
    }

    if (args.next()) |secondArg| {
        if (secondArg[0] == '-') {
            handleArg(secondArg);
        } else {
            config.outputPath = secondArg;
        }
    }

    while (args.next()) |arg| {
        handleArg(arg);
    }

    if (config.inputPath) |inputPath|
        print("Input path: {s}\n", .{inputPath});
    if (config.outputPath) |outputPath|
        print("Output path: {s}\n", .{outputPath});
    print("enum {}\n", .{config.opt});
}

fn handleArg(arg: []const u8) void {
    if (std.mem.eql(u8, arg, "--safe")) {
        config.opt = .Safe;
    } else if (std.mem.eql(u8, arg, "--release")) {
        config.opt = .Realese;
    } else if (std.mem.eql(u8, arg, "--tiny")) {
        config.opt = .Tiny;
    } else {
        print("Unhandled arg: {s}\n", .{arg});
    }
}
