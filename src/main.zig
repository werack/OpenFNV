const std = @import("std");
const Io = std.Io;

const c = @cImport({
    @cInclude("dcimgui.h");
    @cInclude("dcimgui_impl_glfw.h");
    @cInclude("dcimgui_impl_opengl3.h");
});

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);
    for (args, 0..) |arg, i| {
        std.log.info("arg[{}]: {s}", .{ i, arg });
    }

    const context = c.ImGui_CreateContext(null);
    if (context == null) {
        @panic("Failed to create ImGui context!");
    }
    defer _ = c.ImGui_CreateContext(null);
}
