const std = @import("std");

pub fn build(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Module {
    const mod = b.addModule("cimgui", .{
        .root_source_file = b.path("libs/cimgui/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    mod.addIncludePath(.{ .cwd_relative = "deps/imgui" });
    mod.addIncludePath(.{ .cwd_relative = "deps/imgui/backends" });
    mod.addIncludePath(.{ .cwd_relative = "libs/cimui" });
    mod.addCSourceFiles(.{
        .files = &.{
            // ImGui core
            "deps/imgui/imgui.cpp",
            "deps/imgui/imgui_widgets.cpp",
            "deps/imgui/imgui_tables.cpp",
            "deps/imgui/imgui_draw.cpp",
            "deps/imgui/imgui_demo.cpp",
            // Backends
            "deps/imgui/backends/imgui_impl_glfw.cpp",
            "deps/imgui/backends/imgui_impl_opengl3.cpp",

            // generated from dear_bindings
            "libs/cimgui/dcimgui.cpp",
            "libs/cimgui/dcimgui_internal.cpp",

            "libs/cimgui/dcimgui_impl_glfw.cpp",
            "libs/cimgui/dcimgui_impl_opengl3.cpp",
        },
    });

    return mod;
}
