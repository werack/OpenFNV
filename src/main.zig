const std = @import("std");

const Window = @import("platform/window.zig").Window;

const BSA = @import("loaders/bsa.zig");

pub fn main(init: std.process.Init) !void {
    var window = try Window.init(640, 480, "OpenFNV");
    defer window.deinit();

    while (window.shouldClose() == false) {
        window.beginDraw();

        window.endDraw();
    }

    _ = init;
}
