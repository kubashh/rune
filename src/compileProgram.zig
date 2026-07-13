const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

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
    const outdir: ?[]const u8 = std.fs.path.dirname(config.outputPath);

    var buildArgs = StringList.initCapacity(alloc, 10) catch
        printErrExit("out of memory when init buildArgs in compileProgram\n", .{});
    defer buildArgs.deinit(alloc);

    processInputExistense(io, config.inputPath);
    createBuildCommand(alloc, &buildArgs, config) catch
        printErrExit("out of memory when allocating new buildArg in compileProgram\n", .{});

    if (config.info) printBuildInfo(buildArgs.items);
    if (outdir) |validOutdir| {
        const cwd = std.Io.Dir.cwd();
        cwd.createDirPath(io, validOutdir) catch |err|
            std.log.warn(
                \\can't create dir for output. err: {}
                \\App still running but may break any time!
                \\
            , .{err});
    }

    // Real compilation
    if (buildArgs.items.len == 0) return;

    const exitCode = spawnSync(io, .{
        .argv = buildArgs.items,
        .stdin = .ignore,
        .stdout = if (config.info) .inherit else .ignore,
        .stderr = .inherit,
    }) catch |err| {
        std.log.err("spawning build command faild. Err: {}\nbuild command:", .{err});
        std.debug.print(" ", .{});
        printCommand(buildArgs.items);
        std.debug.print("\n\n", .{});
        std.process.exit(1);
    };

    if (exitCode != 0)
        std.process.exit(exitCode);
}

fn processInputExistense(io: std.Io, inputPath: []const u8) void {
    if (!fileExistsCwd(io, inputPath)) {
        printErrExit(
            \\file '{s}' not exists!
            \\first argument is always source code path
            \\try: rune src/main.c
            \\
        , .{inputPath});
    }
}

fn createBuildCommand(alloc: std.mem.Allocator, buildArgs: *StringList, config: *Config) error{OutOfMemory}!void {
    switch (config.extention) {
        .zig => {
            try buildArgs.append(alloc, "zig");
            try buildArgs.append(alloc, "build-exe");
            try buildArgs.append(alloc, config.inputPath);
            // femibin will be auto unallocated when FixedBufferAllocator buffer will be dropped (via stack pointer)
            const femitbin = try std.fmt.allocPrint(alloc, "-femit-bin={s}", .{config.outputPath});
            try buildArgs.append(alloc, femitbin);
            try buildArgs.append(alloc, getOptimizeZig(config.opt));
            try buildArgs.append(alloc, "-target");
            try buildArgs.append(alloc, getTargetZig(config.target));
            try buildArgs.append(alloc, "--cache-dir");
            try buildArgs.append(alloc, ".cache/zig");
        },
        .rs => {
            try buildArgs.append(alloc, "rustc");
            try buildArgs.append(alloc, config.inputPath);
            try buildArgs.append(alloc, "-o");
            try buildArgs.append(alloc, config.outputPath);
            try addOptimizeRs(alloc, buildArgs, config.opt);
            try buildArgs.append(alloc, "--target");
            try buildArgs.append(alloc, getTargetRs(config.target));
        },
        .c => {
            try buildArgs.append(alloc, "zig");
            try buildArgs.append(alloc, "cc");
            try buildArgs.append(alloc, config.inputPath);
            try buildArgs.append(alloc, "-o");
            try buildArgs.append(alloc, config.outputPath);
            try buildArgs.append(alloc, getOptimizeZig(config.opt));
            try buildArgs.append(alloc, "-target");
            try buildArgs.append(alloc, getTargetZig(config.target));
        },
        .cpp => {
            try buildArgs.append(alloc, "zig");
            try buildArgs.append(alloc, "c++");
            try buildArgs.append(alloc, config.inputPath);
            try buildArgs.append(alloc, "-o");
            try buildArgs.append(alloc, config.outputPath);
            try buildArgs.append(alloc, getOptimizeZig(config.opt));
            try buildArgs.append(alloc, "-target");
            try buildArgs.append(alloc, getTargetZig(config.target));
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
        .html, .css, .js, .jsx, .ts, .tsx => {
            if (config.runArgs != null) return;

            try buildArgs.append(alloc, "bun");
            try buildArgs.append(alloc, "build");
            try buildArgs.append(alloc, config.inputPath);
            try buildArgs.append(alloc, "--outfile");
            try buildArgs.append(alloc, config.outputPath);
            try buildArgs.append(alloc, switch (config.target) {
                .@"linux-x86_64" => "--target=bun-linux-x64",
                .@"linux-x86_64-musl" => "--target=bun-linux-x64-musl",
                .@"linux-aarch64" => "--target=bun-linux-arm64",
                .@"linux-aarch64-musl" => "--target=bun-linux-arm64-musl",
                .@"macos-aarch64" => "--target=bun-darwin-arm64",
                .@"macos-x86_64" => "--target=bun-darwin-x64",
                .@"windows-x86_64" => "--target=bun-windows-x64",
                .@"windows-aarch64" => "--target=bun-windows-arm64",
                .browser => "--target=browser",
            });
            if (config.opt == .size or config.opt == .fast)
                try buildArgs.append(alloc, "--minify");
            if (config.extention != .css)
                try buildArgs.append(alloc, "--compile");
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
        .browser => "wasm32-freestanding",
    };
}

fn addOptimizeRs(alloc: std.mem.Allocator, buildArgs: *StringList, opt: Optimization) error{OutOfMemory}!void {
    try buildArgs.append(alloc, "-C");
    try buildArgs.append(alloc, switch (opt) {
        .debug => "opt-level=0",
        .safe, .fast => "opt-level=3",
        .size => "opt-level=z",
    });
    try buildArgs.append(alloc, "-C");
    try buildArgs.append(alloc, switch (opt) {
        .debug, .safe => "overflow-checks=yes",
        .fast, .size => "overflow-checks=no",
    });
    try buildArgs.append(alloc, "-C");
    try buildArgs.append(alloc, switch (opt) {
        .debug,
        => "debug-assertions=yes",
        .safe, .fast, .size => "debug-assertions=no",
    });
    if (opt == .debug) {
        try buildArgs.append(alloc, "-C");
        try buildArgs.append(alloc, "debuginfo=2");
    } else {
        try buildArgs.append(alloc, "-C");
        try buildArgs.append(alloc, "lto=thin");
        try buildArgs.append(alloc, "-C");
        try buildArgs.append(alloc, "panic=abort");
        try buildArgs.append(alloc, "-C");
        try buildArgs.append(alloc, "strip=symbols");

        if (opt == .size) {
            try buildArgs.append(alloc, "-C");
            try buildArgs.append(alloc, "codegen-units=1");
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
