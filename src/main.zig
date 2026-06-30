const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    std.debug.print("Args:\n", .{});
    while (args.next()) |arg| {
        // 'arg' is a null-terminated slice: [:0]const u8
        std.debug.print("  {s}\n", .{arg});
    }
}
