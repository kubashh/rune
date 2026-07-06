const std = @import("std");

const SpwanSyncError = std.process.SpawnError || std.process.Child.WaitError;

pub fn spawnSync(io: std.Io, options: std.process.SpawnOptions) SpwanSyncError!std.process.Child {
    var child = try std.process.spawn(io, options);

    _ = try child.wait(io);

    return child;
}
