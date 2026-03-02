const std = @import("std");
const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

const lib = @import("../lib/lib.zig").zimgui;

const Window = @import("window.zig").Window;
const Key = @import("window.zig").Key;

const gl = @import("gl");

var procs: gl.ProcTable = undefined;

/// Initializes glfw window
pub fn init(
    width: u32,
    height: u32,
    title: []const u8,
) !Window {
    _ = c.glfwSetErrorCallback(error_callback);

    // GLFW window creation
    if (c.glfwInit() == 0)
        return error.GlfwInitFailed;

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 6);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GLFW_TRUE);

    const handle = c.glfwCreateWindow(
        @intCast(width),
        @intCast(height),
        title.ptr,
        null,
        null,
    ) orelse return error.WindowCreationFailed;

    c.glfwMakeContextCurrent(handle);
    _ = c.glfwSetFramebufferSizeCallback(handle, framebuffer_size_callback);

    // load OpenGL functions
    if (!procs.init(c.glfwGetProcAddress)) {
        return error.GL_InitFailed;
    }

    gl.makeProcTableCurrent(&procs);

    // setup viewport on startup
    var _width: c_int = 0;
    var _height: c_int = 0;
    c.glfwGetFramebufferSize(handle, &_width, &_height);
    gl.Viewport(0, 0, _width, _height);

    // init imgui
    const ctx = lib.ImGui_CreateContext(null);
    if (ctx == null) @panic("Failed to create ImGui context");

    _ = lib.cImGui_ImplGlfw_InitForOpenGL(@ptrCast(handle), true);
    _ = lib.cImGui_ImplOpenGL3_Init();
    lib.ImGui_StyleColorsDark(lib.ImGui_GetStyle());

    return .{
        .width = width,
        .height = height,
        .title = title,

        .handle = handle,
        .ig_handle = @ptrCast(ctx),
    };
}

pub fn igDraw() void {
    lib.cImGui_ImplOpenGL3_NewFrame();
    lib.cImGui_ImplGlfw_NewFrame();
    lib.ImGui_NewFrame();
}

pub fn swapBuffers(window: *Window) void {
    lib.ImGui_Render();

    const handle: *c.GLFWwindow = @ptrCast(@alignCast(window.handle));

    lib.cImGui_ImplOpenGL3_RenderDrawData(lib.ImGui_GetDrawData());
    c.glfwSwapBuffers(handle);
}

pub fn pollEvents(_: *Window) void {
    c.glfwPollEvents();
}

pub fn shouldClose(window: *Window) bool {
    const handle: *c.GLFWwindow = @ptrCast(@alignCast(window.handle));
    return c.glfwWindowShouldClose(handle) != 0;
}

pub fn deinit(window: *Window) void {
    // deinit imgui
    lib.cImGui_ImplOpenGL3_Shutdown();
    lib.cImGui_ImplGlfw_Shutdown();
    lib.ImGui_DestroyContext(@ptrCast(window.ig_handle));

    gl.makeProcTableCurrent(null);

    const handle: *c.GLFWwindow = @ptrCast(@alignCast(window.handle));
    c.glfwDestroyWindow(handle);
    c.glfwTerminate();
}

pub fn getTime() f64 {
    return c.glfwGetTime();
}

pub fn getKey(window: *Window, key: c_int) bool {
    const handle: *c.GLFWwindow = @ptrCast(@alignCast(window.handle));
    return c.glfwGetKey(handle, key) == c.GLFW_PRESS;
}

pub fn getCursorPos(window: *Window) [2]f64 {
    const handle: *c.GLFWwindow = @ptrCast(@alignCast(window.handle));
    var xpos: f64 = 0;
    var ypos: f64 = 0;
    c.glfwGetCursorPos(handle, &xpos, &ypos);

    return .{ xpos, ypos };
}

pub fn toScanCode(key: Key) c_int {
    return switch (key) {
        Key.A => c.GLFW_KEY_A,
        Key.B => c.GLFW_KEY_B,
        Key.C => c.GLFW_KEY_C,
        Key.D => c.GLFW_KEY_D,
        Key.E => c.GLFW_KEY_E,
        Key.F => c.GLFW_KEY_F,
        Key.G => c.GLFW_KEY_G,
        Key.H => c.GLFW_KEY_H,
        Key.I => c.GLFW_KEY_I,
        Key.J => c.GLFW_KEY_J,
        Key.K => c.GLFW_KEY_K,
        Key.L => c.GLFW_KEY_L,
        Key.M => c.GLFW_KEY_M,
        Key.N => c.GLFW_KEY_N,
        Key.O => c.GLFW_KEY_O,
        Key.P => c.GLFW_KEY_P,
        Key.Q => c.GLFW_KEY_Q,
        Key.R => c.GLFW_KEY_R,
        Key.S => c.GLFW_KEY_S,
        Key.T => c.GLFW_KEY_T,
        Key.U => c.GLFW_KEY_U,
        Key.V => c.GLFW_KEY_V,
        Key.W => c.GLFW_KEY_W,
        Key.X => c.GLFW_KEY_X,
        Key.Y => c.GLFW_KEY_Y,
        Key.Z => c.GLFW_KEY_Z,

        Key.LEFT_SHIFT => c.GLFW_KEY_LEFT_SHIFT,
        Key.RIGHT_SHIFT => c.GLFW_KEY_RIGHT_SHIFT,
        Key.LEFT_CTRL => c.GLFW_KEY_LEFT_CONTROL,
        Key.RIGHT_CTRL => c.GLFW_KEY_RIGHT_CONTROL,

        Key.SPACE => c.GLFW_KEY_SPACE,
    };
}

fn framebuffer_size_callback(_: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
    gl.Viewport(0, 0, width, height);
}

fn error_callback(error_code: c_int, description: [*c]const u8) callconv(.c) void {
    std.log.scoped(.glfw).debug("({}) {s}", .{ error_code, description });
}
