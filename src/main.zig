const std = @import("std");
const Io = std.Io;

const BSA = @import("loaders/bsa.zig");

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);

    for (args, 0..) |arg, i| {
        std.log.debug("arg[{}]: {s}", .{ i, arg });
    }

    if (args.len >= 2) {
        if (std.mem.eql(u8, args[1], "bsa")) {
            if (args.len >= 3) {
                BSA.load(args[2], init.io) catch |err| {
                    std.log.err("{s}: {}", .{ args[2], err });
                };
            } else {
                std.log.err("usage: bsa path/to/bsa/file", .{});
            }
        } else {
            std.log.err("unknown command \"{s}\"", .{args[1]});
        }
    }
}
