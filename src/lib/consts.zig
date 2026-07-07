const std = @import("std");

pub const allocator = std.heap.page_allocator;

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
};

pub const Extention = enum {
    c,
    cpp,
    cs,
    java,
    zig,
    rs,
    py,
    html,
    css,
    js,
    jsx,
    ts,
    tsx,
    json,
    unknown,
};
pub const Optimization = enum {
    debug,
    safe,
    release,
    size,
};
pub const Target = enum {
    @"linux-x86_64",
    @"linux-x86_64-musl",
    @"linux-x86",
    @"macos-aarch64", // macOS ARM64 (Apple Silicon)
    @"macos-x86_64", // (Intel)
    @"windows-x86_64",
    @"windows-x86_64-gnu",
    // @"windows-x86",
    browser, // wasm / js / ts
};
// const OsTags = enum {
//     linux,
//     macos,
//     windows,

//     // freebsd,
//     // openbsd,

//     // wasi,

//     // freestanding,
//     // uefi,
//     // rtems,
// };
// const Arch = enum {
//     x86_64,
//     x86,
//     // aarch64,
//     // arm,

//     // thumb, // freestanding
//     // riscv32, // freestanding

//     // riscv64, // freestanding | rtems

//     // powerpc, // rtems
//     // sparc, // rtems
// };
// const Abi = enum {
//     gnu, // Linux | Windows
//     musl, // Linux
//     msvc, // Windows with Microsoft toolchain
//     none, // macOS, freestanding, bare metal, many non-libc targets
//     // android, // Android targets
//     // eabi, // ARM embedded
//     // eabihf, // ARM embedded
//     // gnueabihf, // Linux ARM hard-float
// };

pub const Config = struct {
    inputPath: []const u8,
    outputPath: []const u8,
    extention: Extention,
    target: Target,
    opt: Optimization,
    // zigLibDir: []const u8,
    run: bool,
};
