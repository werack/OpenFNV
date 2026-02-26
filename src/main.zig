const std = @import("std");
const Io = std.Io;

const OpenFNV = @import("OpenFNV");

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);
    for (args, 0..) |arg, i| {
        std.log.info("arg[{}]: {s}", .{ i, arg });
    }
}
