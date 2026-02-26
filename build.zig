const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "OpenFNV",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),

            .target = target,
            .optimize = optimize,

            .imports = &.{},

            .link_libc = true,
            .link_libcpp = true,
        }),
        .use_llvm = true, // temp to avoid linker errors about sframe
    });

    b.installArtifact(exe);

    // cimgui module
    //const cimgui_mod = b.addModule("cimgui", .{
    //    .root_source_file = b.path("libs/cimgui/src/root.zig"),
    //    .target = target,
    //    .optimize = optimize,
    //});

    exe.root_module.addIncludePath(b.path("deps/imgui"));
    exe.root_module.addIncludePath(b.path("deps/imgui/backends"));
    exe.root_module.addIncludePath(b.path("libs/cimgui"));
    exe.root_module.addCSourceFiles(.{
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

    exe.root_module.addIncludePath(b.path("libs/cimgui/"));

    // OpenGL bindings library https://github.com/castholm/zigglgen
    const gl_bindings = @import("zigglgen").generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"4.6",
        .profile = .core,
        .extensions = &.{},
    });
    exe.root_module.addImport("gl", gl_bindings);

    // link to system libraries
    exe.root_module.linkSystemLibrary("glfw", .{ .needed = true });

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
