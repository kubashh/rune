const std = @import("std");
const consts = @import("../lib/consts.zig");
const util = @import("../lib/util.zig");
// this file need be build from ./buildHtml.js before building this project
const build_html_js_minified = @embedFile("./buildHtmlMinified.js");

const StringList = consts.StringList;
const Optimization = consts.Optimization;
const Target = consts.Target;
const Config = consts.Config;
const Color = consts.Color;

const printErrExit = util.printErrExit;
const printCommand = util.printCommand;
const spawnSync = util.spawnSync;
const fileExistsCwd = util.fileExistsCwd;

pub fn compileProgram(io: std.Io, config: *Config) void {
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const alloc = fba.allocator();
    const outdir: ?[]const u8 = std.fs.path.dirname(config.output_path);

    var build_args = StringList.initCapacity(alloc, 10) catch
        printErrExit("out of memory when init build_args in compileProgram\n", .{});
    defer build_args.deinit(alloc);

    processInputExistense(io, config.input_path);
    createBuildCommand(alloc, &build_args, config) catch
        printErrExit("out of memory when allocating new build_arg in compileProgram\n", .{});

    if (config.info) printBuildInfo(build_args.items);
    if (outdir) |valid_outdir| {
        const cwd = std.Io.Dir.cwd();
        cwd.createDirPath(io, valid_outdir) catch |err|
            std.log.warn(
                \\can't create dir for output. err: {}
                \\App still running but may break any time!
                \\
            , .{err});
    }

    // Real compilation
    if (build_args.items.len == 0) return;

    const exit_code = spawnSync(io, .{
        .argv = build_args.items,
        .stdin = .ignore,
        .stdout = if (config.info) .inherit else .ignore,
        .stderr = .inherit,
    }) catch |err| {
        std.log.err("spawning build command faild. Err: {}\nbuild command:", .{err});
        std.debug.print(" ", .{});
        printCommand(build_args.items);
        std.debug.print("\n\n", .{});
        std.process.exit(1);
    };

    if (exit_code != 0)
        std.process.exit(exit_code);
}

fn processInputExistense(io: std.Io, input_path: []const u8) void {
    if (!fileExistsCwd(io, input_path)) {
        printErrExit(
            \\file '{s}' not exists!
            \\first argument is always source code path
            \\try: rune src/main.c
            \\
        , .{input_path});
    }
}

fn createBuildCommand(alloc: std.mem.Allocator, build_args: *StringList, config: *Config) error{OutOfMemory}!void {
    switch (config.extention) {
        .zig => {
            try build_args.append(alloc, "zig");
            try build_args.append(alloc, "build-exe");
            try build_args.append(alloc, config.input_path);
            // femibin will be auto unallocated when FixedBufferAllocator buffer will be dropped (via stack pointer)
            const femitbin = try std.fmt.allocPrint(alloc, "-femit-bin={s}", .{config.output_path});
            try build_args.append(alloc, femitbin);
            try build_args.append(alloc, getOptimizeZig(config.opt));
            try build_args.append(alloc, "-target");
            try build_args.append(alloc, getTargetZig(config.target));
            try build_args.append(alloc, "--cache-dir");
            try build_args.append(alloc, ".cache/zig");
        },
        .rs => {
            try build_args.append(alloc, "rustc");
            try build_args.append(alloc, config.input_path);
            try build_args.append(alloc, "-o");
            try build_args.append(alloc, config.output_path);
            try addOptimizeRs(alloc, build_args, config.opt);
            try build_args.append(alloc, "--target");
            try build_args.append(alloc, getTargetRs(config.target));
        },
        .c => {
            try build_args.append(alloc, "zig");
            try build_args.append(alloc, "cc");
            try build_args.append(alloc, config.input_path);
            try build_args.append(alloc, "-o");
            try build_args.append(alloc, config.output_path);
            try build_args.append(alloc, getOptimizeZig(config.opt));
            try build_args.append(alloc, "-target");
            try build_args.append(alloc, getTargetZig(config.target));
        },
        .cpp => {
            try build_args.append(alloc, "zig");
            try build_args.append(alloc, "c++");
            try build_args.append(alloc, config.input_path);
            try build_args.append(alloc, "-o");
            try build_args.append(alloc, config.output_path);
            try build_args.append(alloc, getOptimizeZig(config.opt));
            try build_args.append(alloc, "-target");
            try build_args.append(alloc, getTargetZig(config.target));
        },
        .cs => printErrExit(
            \\C# not supported yet (in development)!
            \\see supported file extentions running 'rune -h'
            \\
        , .{}),
        .java => printErrExit(
            \\java not supported yet (in development)!
            \\see supported file extentions running 'rune -h'
            \\
        , .{}),
        .html => {
            // if run args exists we don't need to compile program
            if (config.run_args != null) return;

            try build_args.append(alloc, "bun");
            try build_args.append(alloc, "-e");
            try build_args.append(alloc, build_html_js_minified);
            try build_args.append(alloc, config.input_path);
            try build_args.append(alloc, config.output_path);
            if (config.opt == .size or config.opt == .fast)
                try build_args.append(alloc, "--minify");
            if (config.html_no_bundle)
                try build_args.append(alloc, "--no-bundle");
            if (config.html_crossorigin)
                try build_args.append(alloc, "--crossorigin");
        },
        .css, .js, .jsx, .ts, .tsx => {
            // if run args exists we don't need to compile program
            if (config.run_args != null) return;

            const outjs = std.mem.endsWith(u8, config.output_path, ".js") or std.mem.endsWith(u8, config.output_path, ".ts");
            try build_args.append(alloc, "bun");
            try build_args.append(alloc, "build");
            try build_args.append(alloc, config.input_path);
            try build_args.append(alloc, "--outfile");
            try build_args.append(alloc, config.output_path);
            if (outjs) {
                try build_args.append(alloc, "--target=node");
            } else try build_args.append(alloc, switch (config.target) {
                .@"linux-x86_64" => "--target=bun-linux-x64",
                .@"linux-x86_64-musl" => "--target=bun-linux-x64-musl",
                .@"linux-aarch64" => "--target=bun-linux-arm64",
                .@"linux-aarch64-musl" => "--target=bun-linux-arm64-musl",
                .@"macos-aarch64" => "--target=bun-darwin-arm64",
                .@"macos-x86_64" => "--target=bun-darwin-x64",
                .@"windows-x86_64" => "--target=bun-windows-x64",
                .@"windows-aarch64" => "--target=bun-windows-arm64",
                .browser => "--target=browser",
                else => printErrExit(
                    "can't build {} files for {}",
                    .{ config.extention, config.target },
                ),
            });
            if (config.opt == .size or config.opt == .fast)
                try build_args.append(alloc, "--minify");
            if (config.extention != .css and !outjs)
                try build_args.append(alloc, "--compile");
        },
        .py => printErrExit(
            \\python not supported yet (in development)!
            \\see supported file extentions running 'rune -h'
            \\
        , .{}),
    }
}

fn getOptimizeZig(opt: Optimization) []const u8 {
    return switch (opt) {
        .debug => "-Doptimize=Debug",
        .safe => "-Doptimize=ReleaseSafe",
        .fast => "-Doptimize=ReleaseFast",
        .size => "-Doptimize=ReleaseSize",
    };
}

fn getTargetZig(target: Target) []const u8 {
    return switch (target) {
        .@"linux-x86_64" => "x86_64-linux",
        .@"linux-x86_64-musl" => "x86_64-linux-musl",
        .@"linux-aarch64" => "aarch64-linux",
        .@"linux-aarch64-musl" => "aarch64-linux-musl",
        .@"macos-x86_64" => "x86_64-macos",
        .@"macos-aarch64" => "aarch64-macos",
        .@"windows-x86_64" => "x86_64-windows",
        .@"windows-aarch64" => "aarch64-windows",
        .@"android-aarch64" => "aarch64-linux-android",
        .@"android-x86_64" => "x86_64-linux-android",
        .browser => "wasm32-freestanding",
    };
}

fn addOptimizeRs(alloc: std.mem.Allocator, build_args: *StringList, opt: Optimization) error{OutOfMemory}!void {
    try build_args.append(alloc, "-C");
    try build_args.append(alloc, switch (opt) {
        .debug => "opt-level=0",
        .safe, .fast => "opt-level=3",
        .size => "opt-level=z",
    });
    try build_args.append(alloc, "-C");
    try build_args.append(alloc, switch (opt) {
        .debug, .safe => "overflow-checks=yes",
        .fast, .size => "overflow-checks=no",
    });
    try build_args.append(alloc, "-C");
    try build_args.append(alloc, switch (opt) {
        .debug => "debug-assertions=yes",
        .safe, .fast, .size => "debug-assertions=no",
    });
    if (opt == .debug) {
        try build_args.append(alloc, "-C");
        try build_args.append(alloc, "debuginfo=2");
    } else {
        try build_args.append(alloc, "-C");
        try build_args.append(alloc, "lto=thin");
        try build_args.append(alloc, "-C");
        try build_args.append(alloc, "panic=abort");
        try build_args.append(alloc, "-C");
        try build_args.append(alloc, "strip=symbols");

        if (opt == .size) {
            try build_args.append(alloc, "-C");
            try build_args.append(alloc, "codegen-units=1");
        }
    }
}

fn getTargetRs(target: Target) []const u8 {
    return switch (target) {
        .@"linux-x86_64" => "x86_64-unknown-linux-gnu",
        .@"linux-x86_64-musl" => "x86_64-unknown-linux-musl",
        .@"linux-aarch64" => "aarch64-unknown-linux-gnu",
        .@"linux-aarch64-musl" => "aarch64-unknown-linux-musl",
        .@"macos-x86_64" => "aarch64-apple-darwin",
        .@"macos-aarch64" => "x86_64-apple-darwin",
        .@"windows-x86_64" => "x86_64-pc-windows-msvc",
        .@"windows-aarch64" => "aarch64-pc-windows-msvc",
        .browser => "wasm32-wasip1",
        else => printErrExit("target: {} non supported for .rs files\n", .{target}),
    };
}

fn getOptimizeBun(optimize: Optimization) []const u8 {
    return switch (optimize) {};
}

fn printBuildInfo(runArgsItems: []const []const u8) void {
    std.debug.print(
        Color.green ++ Color.bold_on ++ "info" ++ Color.bright_black ++ ":" ++ Color.reset ++ " build command:",
        .{},
    );
    printCommand(runArgsItems);
    std.debug.print("\n\n", .{});
}
