const std = @import("std");

const Window = @import("platform/window.zig").Window;

const BSA = @import("loaders/bsa.zig");

const c = @import("lib/lib.zig").zimgui;

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var window = try Window.init(640, 480, "OpenFNV");
    defer window.deinit();

    var paths = try BSA.load("assets/Fallout - Meshes.bsa", init.io, allocator);
    defer paths.?.deinit(allocator);

    while (window.shouldClose() == false) {
        window.beginDraw();

        _ = c.ImGui_Begin("BSA Explorer", @constCast(&true), c.ImGuiWindowFlags_MenuBar);
        if (c.ImGui_BeginMenuBar()) {
            if (c.ImGui_BeginMenu("File")) {
                // menu bar
                if (c.ImGui_MenuItem("Open")) {}
                if (c.ImGui_MenuItem("Close")) {}

                c.ImGui_EndMenu();
            }
            c.ImGui_EndMenuBar();
        }

        if (c.ImGui_TreeNode("test")) {
            c.ImGui_TreePop();
        }

        c.ImGui_End();

        window.endDraw();
    }
}
