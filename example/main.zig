const std = @import("std");

pub fn main() void {
    printHello();
}

fn printHello() void {
    std.debug.print("Hello Zig!\n", .{});
}
