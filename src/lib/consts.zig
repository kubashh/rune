const std = @import("std");
const builtin = @import("builtin");

// types

pub const StringList = std.ArrayList([]const u8);

pub const Target = enum {
    @"linux-x86_64",
    @"linux-x86_64-musl",
    @"linux-aarch64",
    @"linux-aarch64-musl",
    @"macos-aarch64", // macOS ARM64 (Apple Silicon)
    @"macos-x86_64", // (Intel)
    @"windows-x86_64",
    @"windows-aarch64",
    browser, // wasm / html / css / js / ts
    // and runtime?
};
pub const Optimization = enum {
    debug,
    safe,
    fast,
    size,
};
pub const Runner = enum { native, wine, bun, none };
pub const Extention = enum {
    zig,
    rs,
    c,
    cpp,
    cs,
    java,
    html,
    css,
    js,
    jsx,
    ts,
    tsx,
    py,
};

pub const Config = struct {
    inputPath: []const u8,
    outputPath: []const u8,
    target: Target,
    opt: Optimization,
    runner: Runner,
    runArgs: ?StringList,
    extention: Extention,
    types: bool, // build ts/tsx only
    info: bool,
    rawCompilerArgs: ?[]const u8,
};

// values

pub const runeVersion = "0.2.0-dev";

//  OsTags
//      1.  linux, macos, windows
//      2.  freebsd, openbsd
//      3.  wasi
//      4.  freestanding, uefi, rtems,

//  Arch
//      1.  x86_64, x86, aarch64, arm,
//      2.  thumb (freestanding), iscv32 (freestanding)
//      3.  iscv64 (freestanding | rtems)
//      4.  powerpc (rtems), sparc (rtems)

//  Abi
//      1.  gnu (Linux | Windows)
//      1.  musl (Linux)
//      1.  msvc (Windows with Microsoft toolchain)
//      1.  none (macOS, freestanding, bare metal, many non-libc targets)
//      2.  android (Android targets)
//      3.  eabi (ARM embedded)
//      4.  eabihf (ARM embedded)
//      4.  gnueabihf (Linux ARM hard-float)

pub const defaultTarget: Target = switch (builtin.target.os.tag) {
    .linux => switch (builtin.target.cpu.arch) {
        .x86_64 => switch (builtin.target.abi) {
            .gnu => .@"linux-x86_64",
            .musl => .@"linux-x86_64-musl",
            else => .browser,
        },
        .aarch64 => .@"linux-aarch64",
        else => .browser,
    },
    .macos => switch (builtin.target.cpu.arch) {
        .aarch64 => .@"macos-aarch64",
        .x86_64 => .@"macos-x86_64",
        else => .browser,
    },
    .windows => switch (builtin.target.cpu.arch) {
        .x86_64 => switch (builtin.target.abi) {
            .msvc => .@"windows-x86_64",
            else => .browser,
        },
        else => .browser,
    },
    else => .browser,
};

pub const Color = struct {
    pub const reset = "\x1b[0m";
    pub const black = "\x1b[30m";
    pub const red = "\x1b[31m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
    pub const blue = "\x1b[34m";
    pub const magenta = "\x1b[35m";
    pub const cyan = "\x1b[36m";
    pub const white = "\x1b[37m";
    pub const bright_black = "\x1b[90m";
    pub const bright_red = "\x1b[91m";
    pub const bright_green = "\x1b[92m";
    pub const bright_yellow = "\x1b[93m";
    pub const bright_blue = "\x1b[94m";
    pub const bright_magenta = "\x1b[95m";
    pub const bright_cyan = "\x1b[96m";
    pub const bright_white = "\x1b[97m";

    pub const bold_on = "\x1b[1m";
    pub const bold_off = "\x1b[0m";
};
