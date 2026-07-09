const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Config = consts.Config;
const Color = consts.Color;

const print = util.print;
const printErrExit = util.printErrExit;
const spawnSync = util.spawnSync;
const fileExistsCwd = util.fileExistsCwd;
const createDirPathCwd = util.createDirPathCwd;
const measureStart = util.measureStart;
const measurePrint = util.measurePrint;

pub fn compileProgram(io: std.Io, config: *Config) void {
    var buf: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const alloc = fba.allocator();
    const outdir: ?[]const u8 = std.fs.path.dirname(config.outputPath);

    processInputExistense(io, config.inputPath);

    const buildCommand: []const u8 = createBuildCommandAlloc(alloc, config) catch
        printErrExit("out of memory while allocating build command!\n", .{});
    defer alloc.free(buildCommand);

    print("build command: {s}\n\n", .{buildCommand});
    if (outdir) |validOutdir|
        createDirPathCwd(io, validOutdir) catch |err|
            std.log.warn(
                \\can't create dir for output. err: {}
                \\App still running but may break any time!
                \\
            , .{err});

    // Real compilation
    const term = spawnSync(io, .{
        .argv = &[_][]const u8{ "sh", "-c", buildCommand },
        .stdin = .ignore,
        .stdout = .inherit,
        .stderr = .inherit,
    }) catch |err|
        printErrExit(
            "spawning build command faild. err: {}\nbuild command: {s}\n",
            .{ err, buildCommand },
        );

    if (term != 0)
        config.runner = .none;
}

fn processInputExistense(io: std.Io, inputPath: []const u8) void {
    if (!fileExistsCwd(io, inputPath)) {
        printErrExit(
            \\file '{s}' not exists!
            \\first argument is always source code path
            \\example: src/main.c
            \\
        , .{inputPath});
    }
}

fn createBuildCommandAlloc(alloc: std.mem.Allocator, config: *Config) error{OutOfMemory}![]const u8 {
    switch (config.extention) {
        .zig => return try std.fmt.allocPrint(
            alloc,
            "zig build-exe {s} -femit-bin={s} -Doptimize={s} -target {s} --cache-dir .cache/zig",
            .{
                config.inputPath,
                config.outputPath,
                getOptimizeZig(config.opt),
                getTargetZig(config.target),
            },
        ),
        // ReleaseDebug
        // rustc example/main.rs -o dist/bin/main-debug -C opt-level=0 -C overflow-checks=yes -C debug-assertions=yes -C debuginfo=2

        // ReleaseSafe
        // rustc example/main.rs -o dist/bin/main-safe -C opt-level=3 -C overflow-checks=yes -C debug-assertions=no -C lto=thin -C panic=abort -C strip=symbols

        // ReleaseSmall
        // rustc example/main.rs -o dist/bin/main-small -C opt-level=z -C overflow-checks=no -C debug-assertions=no -C codegen-units=1 -C lto=thin -C panic=abort -C strip=symbols

        // ReleaseFast
        // rustc example/main.rs -o dist/bin/main-fast -C opt-level=3 -C overflow-checks=no \
        // -C debug-assertions=no -C lto=thin -C panic=abort -C strip=symbols
        .rs => printErrExit(
            \\rust not supported yet (in development)!
            \\see supported file extentions running 'run -h'
            \\
        , .{}),
        .c => return try std.fmt.allocPrint(
            alloc,
            "zig cc {s} -o {s} -Doptimize={s} -target {s}",
            .{
                config.inputPath,
                config.outputPath,
                getOptimizeZig(config.opt),
                getTargetZig(config.target),
            },
        ),
        .cpp => return try std.fmt.allocPrint(
            alloc,
            "zig c++ {s} -o {s} -Doptimize={s} -target {s}",
            .{
                config.inputPath,
                config.outputPath,
                getOptimizeZig(config.opt),
                getTargetZig(config.target),
            },
        ),
        .cs => printErrExit(
            \\C# not supported yet (in development)!
            \\see supported file extentions running 'run -h'
            \\
        , .{}),
        .java => printErrExit(
            \\java not supported yet (in development)!
            \\see supported file extentions running 'run -h'
            \\
        , .{}),
        .html => printErrExit(
            \\html not supported yet (in development)!
            \\see supported file extentions running 'run -h'
            \\
        , .{}),
        .css => printErrExit(
            \\css not supported yet (in development)!
            \\see supported file extentions running 'run -h'
            \\
        , .{}),
        .js, .jsx, .ts, .tsx => printErrExit(
            \\js/jsx/ts/tsx not supported yet (in development)!
            \\see supported file extentions running 'run -h'
            \\
        , .{}),
        .py => printErrExit(
            \\python not supported yet (in development)!
            \\see supported file extentions running 'run -h'
            \\
        , .{}),
        else => printErrExit(
            \\unknown file extetnion: {}
            \\see supported file extentions running 'run -h'
            \\
        , .{config.extention}),
    }
}

fn getOptimizeZig(opt: consts.Optimization) []const u8 {
    return switch (opt) {
        .debug => "Debug",
        .safe => "ReleaseSafe",
        .fast => "ReleaseFast",
        .size => "ReleaseSize",
    };
}

fn getTargetZig(target: consts.Target) []const u8 {
    return switch (target) {
        .@"linux-x86_64" => "x86_64-linux",
        .@"linux-x86_64-musl" => "x86_64-linux-musl",
        .@"linux-aarch64" => "aarch64-linux",
        .@"macos-x86_64" => "x86_64-macos",
        .@"macos-aarch64" => "aarch64-macos",
        .@"windows-x86_64" => "x86_64-windows",
        .@"windows-x86_64-gnu" => "x86_64-windows-gnu",
        .browser => "wasi-freestanding",
    };
}
