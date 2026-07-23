const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    printHello();

    const args = try init.minimal.args.toSlice(allocator);
    if (args.len > 1) {
        std.debug.print("args passed through exe:\n", .{});
        for (args[1..]) |arg| {
            std.debug.print("  {s}\n", .{arg});
        }
    } else {
        std.debug.print("no args passed\n", .{});
    }
}

fn printHello() void {
    std.debug.print("Hello Zig!\n", .{});
}
