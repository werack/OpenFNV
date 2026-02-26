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

    const cimgui = @import("libs/cimgui/build.zig").build(b, target, optimize);
    exe.root_module.addImport("cimgui", cimgui);

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
