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

            .link_libc = true,
            .link_libcpp = true,
        }),
        .use_llvm = true,
    });

    // imgui and dear_bindings
    exe.root_module.addIncludePath(b.path("dep/imgui"));
    exe.root_module.addIncludePath(b.path("dep/imgui/backends"));
    exe.root_module.addIncludePath(b.path("lib/zimgui"));
    exe.root_module.addCSourceFiles(.{
        .files = &.{
            // ImGui core
            "dep/imgui/imgui.cpp",
            "dep/imgui/imgui_widgets.cpp",
            "dep/imgui/imgui_tables.cpp",
            "dep/imgui/imgui_draw.cpp",
            "dep/imgui/imgui_demo.cpp",
            // Backends
            "dep/imgui/backends/imgui_impl_glfw.cpp",
            "dep/imgui/backends/imgui_impl_opengl3.cpp",

            // generated from dear_bindings
            "lib/zimgui/dcimgui.cpp",
            "lib/zimgui/dcimgui_internal.cpp",

            "lib/zimgui/dcimgui_impl_glfw.cpp",
            "lib/zimgui/dcimgui_impl_opengl3.cpp",
        },
    });

    // Choose the OpenGL API, version, profile and extensions you want to generate bindings for.
    const gl_bindings = @import("zigglgen").generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"4.6",
        .profile = .core,
        .extensions = &.{},
    });

    // Import the generated module.
    exe.root_module.addImport("gl", gl_bindings);

    // system libs
    exe.root_module.linkSystemLibrary("glfw", .{ .needed = true });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const test_step = b.step("test", "Run unit tests");
    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/loaders/bsa.zig"),
            .target = b.resolveTargetQuery(target.query),
        }),
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    test_step.dependOn(&run_unit_tests.step);
}
