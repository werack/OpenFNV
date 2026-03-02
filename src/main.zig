const std = @import("std");

const Window = @import("platform/window.zig").Window;

const BSA = @import("loaders/bsa.zig");

const c = @import("lib/lib.zig").zimgui;

pub fn main(init: std.process.Init) !void {
    var window = try Window.init(640, 480, "OpenFNV");
    defer window.deinit();

    while (window.shouldClose() == false) {
        window.beginDraw();

        // var open: bool = true;
        //_ = c.ImGui_Begin("BSA Explorer", @ptrCast(&open), c.ImGuiWindowFlags_MenuBar);
        //if (c.ImGui_BeginMenuBar()) {
        //    if (c.ImGui_BeginMenu("File")) {
        //        if (c.ImGui_MenuItem("Open")) {}
        //
        //        c.ImGui_EndMenu();
        //    }
        //    c.ImGui_EndMenuBar();
        //}
        //
        //c.ImGui_End();
        c.ImGui_ShowDemoWindow(@constCast(&true));

        window.endDraw();
    }

    _ = init;
}
