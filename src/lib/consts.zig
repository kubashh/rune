const std = @import("std");

pub const allocator = std.heap.page_allocator;
pub const print = std.debug.print;

const Opt = enum { Safe, Release, Tiny };
pub const Extention = enum { C, Zig, Rust, Js, Jsx, Ts, Tsx, Html, Css, Unknown };

const Entry = struct {
    path: []const u8,
    extention: Extention,
};

pub const Config = struct {
    input: ?Entry,
    output: ?Entry,
    opt: Opt,
};
