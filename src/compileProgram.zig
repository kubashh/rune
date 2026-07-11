const std = @import("std");
const consts = @import("./lib/consts.zig");
const util = @import("./lib/util.zig");

const Config = consts.Config;

const printErrExit = util.printErrExit;
const spawnSync = util.spawnSync;
const cliProgramExists = util.cliProgramExists;
const fileExistsCwd = util.fileExistsCwd;

pub fn compileProgram(io: std.Io, config: *Config) void {
    var buf: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const alloc = fba.allocator();
    const outdir: ?[]const u8 = std.fs.path.dirname(config.outputPath);

    checkAllPrograms(io, config);

    processInputExistense(io, config.inputPath);

    const buildCommand: []const u8 = createBuildCommandAlloc(alloc, config) catch
        printErrExit("out of memory while allocating build command!\n", .{});
    defer alloc.free(buildCommand);

    std.log.info("build command: {s}\n", .{buildCommand});
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

fn checkAllPrograms(io: std.Io, config: *Config) void {
    checkCompilerExistence(io, config);
    checkRunnerExistence(io, config);
}

fn checkRunnerExistence(io: std.Io, config: *Config) void {
    switch (config.runner) {
        .wine => if (!cliProgramExists(io, "wine")) printErrExit(
            \\wine don't exists! to run windows bin's on posix wine is required!
            \\install wine
            \\
        , .{}),
        .native, .none => {},
    }
}

fn checkCompilerExistence(io: std.Io, config: *Config) void {
    switch (config.extention) {
        .zig, .c, .cpp => if (!cliProgramExists(io, "zig")) printErrExit(
            \\zig don't exists! to compile zig, c, cpp zig is required!
            \\install zig
            \\
        , .{}),
        .rs => if (!cliProgramExists(io, "rustc")) printErrExit(
            \\rustc don't exists! to compile rust rustc is required!
            \\install rustc
            \\
        , .{}),
        else => {},
    }
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

fn createBuildCommandAlloc(alloc: std.mem.Allocator, config: *Config) error{OutOfMemory}![]const u8 {
    switch (config.extention) {
        .zig => {
            return try std.fmt.allocPrint(
                alloc,
                "zig build-exe {s} -femit-bin={s} -Doptimize={s} -target {s} --cache-dir .cache/zig",
                .{
                    config.inputPath,
                    config.outputPath,
                    getOptimizeZig(config.opt),
                    getTargetZig(config.target),
                },
            );
        },
        .rs => return try std.fmt.allocPrint(
            alloc,
            "rustc {s} -o {s} {s} --target {s}",
            .{
                config.inputPath,
                config.outputPath,
                getOptimizeRs(config.opt),
                getTargetRs(config.target),
            },
        ),
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
        .browser => "wasm32-freestanding",
    };
}

fn getOptimizeRs(opt: consts.Optimization) []const u8 {
    return switch (opt) {
        .debug => "-C opt-level=0 -C overflow-checks=yes -C debug-assertions=yes -C debuginfo=2",
        .safe => "-C opt-level=3 -C overflow-checks=yes -C debug-assertions=no -C lto=thin -C panic=abort -C strip=symbols",
        .fast => "-C opt-level=3 -C overflow-checks=no -C debug-assertions=no -C lto=thin -C panic=abort -C strip=symbols",
        .size => "-C opt-level=z -C overflow-checks=no -C debug-assertions=no -C codegen-units=1 -C lto=thin -C panic=abort -C strip=symbols",
    };
}

fn getTargetRs(target: consts.Target) []const u8 {
    return switch (target) {
        .@"linux-x86_64" => "x86_64-unknown-linux-gnu",
        .@"linux-x86_64-musl" => "x86_64-unknown-linux-musl",
        .@"linux-aarch64" => "aarch64-unknown-linux-gnu",
        .@"macos-x86_64" => "aarch64-apple-darwin",
        .@"macos-aarch64" => "x86_64-apple-darwin",
        .@"windows-x86_64" => "x86_64-pc-windows-msvc",
        .@"windows-x86_64-gnu" => "x86_64-pc-windows-gnu",
        .browser => "wasm32-wasip1",
    };
}
