// utilities for whole project
const std = @import("std");
const builtin = @import("builtin");
const consts = @import("./consts.zig");

const Color = consts.Color;

pub fn printErrExit(comptime fmt: []const u8, options: anytype) noreturn {
    std.log.err(fmt, options);
    std.process.exit(1);
}

pub fn printCommand(args_items: []const []const u8) void {
    for (args_items) |arg|
        if (std.mem.indexOfScalar(u8, arg, ' ') != null)
            std.debug.print(" '{s}'", .{arg})
        else
            std.debug.print(" {s}", .{arg});
}

pub const SpawnSyncError = std.process.SpawnError || std.process.Child.WaitError;

pub fn spawnSync(io: std.Io, options: std.process.SpawnOptions) SpawnSyncError!u8 {
    var child = std.process.spawn(io, options) catch |err|
        if (err == error.FileNotFound) {
            // zig
            if (std.mem.eql(u8, options.argv[0], "zig")) {
                printErrExit(
                    \\zig don't exists! to compile zig, c, cpp zig is required!
                    \\install zig from https://ziglang.org/download/
                    \\
                , .{});

                return 1;
            }
            // rust
            if (std.mem.eql(u8, options.argv[0], "rustc")) printErrExit(
                \\rustc don't exists! to compile rust rustc is required!
                \\install rustc
                \\
            , .{});
            // bun
            if (std.mem.eql(u8, options.argv[0], "bun")) printErrExit(
                \\bun don't exists! to compile js/jsx/ts/tsx bunjs is required!
                \\install bun from https://bun.com/docs/installation
                \\or run: npm install -g bun # may requires sudo
                \\
            , .{});
            // wine
            if (std.mem.eql(u8, options.argv[0], "wine")) printErrExit(
                \\wine don't exists! to run windows bin's on posix wine is required!
                \\install wine
                \\
            , .{});
            return error.FileNotFound;
        } else return err;
    const result = try child.wait(io);
    return result.exited;
}

pub fn spawnSyncInherit(io: std.Io, argv: []const []const u8) SpawnSyncError!u8 {
    return try spawnSync(io, .{
        .argv = argv,
        .stdin = .inherit,
        .stdout = .inherit,
        .stderr = .inherit,
    });
}

// pub fn cliProgramExists(io: std.Io, comptime cli_name: []const u8) bool {
//     const exitCode = spawnSync(io, .{
//         .argv = switch (builtin.target.os.tag) {
//             // windows, not tested!!! (TODO test windows)
//             .windows => &[_][]const u8{
//                 "powershell",
//                 "-NoProfile",
//                 "-ExecutionPolicy",
//                 "Bypass",
//                 "-Command",
//                 "if (Get-Command " ++ cli_name ++ " -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }",
//             },
//             // posix
//             else => &[_][]const u8{ "sh", "-c", "command -v " ++ cli_name ++ " >/dev/null 2>&1" },
//         },
//         .stdin = .ignore,
//         .stdout = .ignore,
//         .stderr = .ignore,
//     }) catch {
//         return false;
//     };
//     return exitCode == 0;
// }

pub fn fileExistsCwd(io: std.Io, path: []const u8) bool {
    const cwd = std.Io.Dir.cwd();
    _ = cwd.statFile(io, path, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return true, // exists but e.g. permission; treat as "exists"
    };
    return true;
}

pub const Measure = struct {
    pub inline fn start(io: std.Io) i96 {
        return std.Io.Clock.Timestamp.now(io, .awake).raw.nanoseconds;
    }

    pub inline fn print(io: std.Io, startNs: i96, label: []const u8) void {
        const now = Measure.start(io);
        const nanos = now - startNs;
        switch (nanos) {
            0...999 => {
                std.debug.print("{s}: {} ns\n", .{ label, nanos });
            },
            1_000...999_999 => {
                std.debug.print("{s}: {d:.3} us\n", .{ label, @as(f64, @floatFromInt(nanos)) / 1_000.0 });
            },
            1_000_000...999_999_999 => {
                std.debug.print("{s}: {d:.3} ms\n", .{ label, @as(f64, @floatFromInt(nanos)) / 1_000_000.0 });
            },
            else => {
                std.debug.print("{s}: {d:.3} s\n", .{ label, @as(f64, @floatFromInt(nanos)) / 1_000_000_000.0 });
            },
        }
    }
};
