const std = @import("std");
const Io = std.Io;

const c = @cImport({
    @cInclude("dcimgui.h");
    @cInclude("dcimgui_impl_glfw.h");
    @cInclude("dcimgui_impl_opengl3.h");
});

const Window = @import("platform/window.zig").Window;

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);
    for (args, 0..) |arg, i| {
        std.log.info("arg[{}]: {s}", .{ i, arg });
    }

    var window: Window = try .init(640, 480, "OpenFNV");
    defer window.deinit();

    const ctx = c.ImGui_CreateContext(null);
    defer c.ImGui_DestroyContext(ctx);
    if (ctx == null) @panic("Failed to create ImGui context");

    _ = c.cImGui_ImplGlfw_InitForOpenGL(@ptrCast(window.handle), true);
    defer c.cImGui_ImplGlfw_Shutdown();
    _ = c.cImGui_ImplOpenGL3_Init();
    defer c.cImGui_ImplOpenGL3_Shutdown();

    c.ImGui_StyleColorsDark(c.ImGui_GetStyle());

    while (window.shouldClose() == false) {
        window.beginDraw();
        c.cImGui_ImplOpenGL3_NewFrame();
        c.cImGui_ImplGlfw_NewFrame();
        c.ImGui_NewFrame();

        c.ImGui_ShowDemoWindow(@constCast(&true));

        c.ImGui_Render();

        window.endDraw();
        c.cImGui_ImplOpenGL3_RenderDrawData(c.ImGui_GetDrawData());
        window.swapBuffers();
    }
}
