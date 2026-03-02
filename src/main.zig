const std = @import("std");

const Window = @import("platform/window.zig").Window;

const BSA = @import("loaders/bsa.zig");

const Tree = @import("tree/tree.zig");

const c = @import("lib/lib.zig").zimgui;

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var window = try Window.init(640, 480, "OpenFNV");
    defer window.deinit();

    var paths = try BSA.load("assets/Fallout - Meshes.bsa", init.io, allocator);
    defer paths.?.deinit(allocator);

    var root: *Tree.Node = try .root(allocator);
    defer root.destroy();

    for (paths.?.path.items) |path| {
        try root.addPath(@ptrCast(path.name.items));
    }

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

        render(root);

        c.ImGui_End();

        window.endDraw();
    }
}

pub fn render(parent: *Tree.Node) void {
    const label = @as([*:0]const u8, @ptrCast(parent.name.items.ptr));

    if (c.ImGui_TreeNode(label)) {
        for (parent.children.items) |child| {
            render(child);
        }

        c.ImGui_TreePop();
    }
}
