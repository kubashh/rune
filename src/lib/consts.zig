const std = @import("std");

pub const allocator = std.heap.page_allocator;

pub const Extention = enum { C, Cpp, Cs, Java, Zig, Rust, Py, Html, Css, Js, Jsx, Ts, Tsx, Json, Unknown };
const Optimization = enum { Debug, Safe, Release, Size };

pub const Config = struct {
    inputPath: []const u8,
    outputPath: []const u8,
    extention: Extention,
    opt: Optimization,
    zigLibDir: []const u8,
    run: bool,
};
