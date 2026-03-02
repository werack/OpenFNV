const std = @import("std");

const glfw = @import("glfw_window.zig");
const gl = @import("gl");

pub const Key = enum { Q, W, E, R, T, Y, U, I, O, P, A, S, D, F, G, H, J, K, L, Z, X, C, V, B, N, M, SPACE, LEFT_SHIFT, RIGHT_SHIFT, LEFT_CTRL, RIGHT_CTRL };

// Currently a glfw wrapper
// In the future we will maybe use more backends like SDL or platform specific like WinAPI

pub const Window = struct {
    width: u32,
    height: u32,
    title: []const u8,

    handle: *anyopaque,
    ig_handle: *anyopaque,

    /// Creates a window using glfw
    pub fn init(
        width: u32,
        height: u32,
        title: []const u8,
    ) !Window {
        // init glfw (and imgui)
        const ret = try glfw.init(width, height, title);

        // init opengl
        gl.Enable(gl.DEPTH_TEST);

        gl.Enable(gl.DEBUG_OUTPUT);
        gl.Enable(gl.DEBUG_OUTPUT_SYNCHRONOUS);
        gl.DebugMessageCallback(message_callback, null);

        return ret;
    }

    pub fn beginDraw(_: *Window) void {
        gl.ClearColor(0.0, 0.0, 0.0, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        glfw.igDraw();
    }

    pub fn pressed(window: *Window, key: Key) bool {
        return glfw.getKey(window, glfw.toScanCode(key));
    }

    pub fn endDraw(self: *Window) void {
        glfw.swapBuffers(self);
        glfw.pollEvents(self);
    }

    pub fn shouldClose(self: *Window) bool {
        return glfw.shouldClose(self);
    }

    pub fn deinit(self: *Window) void {
        glfw.deinit(self);
    }

    pub fn getDelta(_: *Window) f64 {
        return glfw.getTime();
    }

    pub fn getMousePosition(window: *Window) [2]f64 {
        return glfw.getCursorPos(window);
    }
};

fn message_callback(source: u32, type_: u32, id: u32, severity: u32, length: i32, message: [*:0]const u8, _: ?*const anyopaque) callconv(.c) void {
    // Convert the message to a slice using the length
    const msg_slice = message[0..@intCast(length)];

    // Source string
    const src_str = switch (source) {
        gl.DEBUG_SOURCE_API => "API",
        gl.DEBUG_SOURCE_WINDOW_SYSTEM => "WINDOW SYSTEM",
        gl.DEBUG_SOURCE_SHADER_COMPILER => "SHADER COMPILER",
        gl.DEBUG_SOURCE_THIRD_PARTY => "THIRD PARTY",
        gl.DEBUG_SOURCE_APPLICATION => "APPLICATION",
        gl.DEBUG_SOURCE_OTHER => "OTHER",
        else => "UNKNOWN",
    };

    // Type string
    const type_str = switch (type_) {
        gl.DEBUG_TYPE_ERROR => "ERROR",
        gl.DEBUG_TYPE_DEPRECATED_BEHAVIOR => "DEPRECATED_BEHAVIOR",
        gl.DEBUG_TYPE_UNDEFINED_BEHAVIOR => "UNDEFINED_BEHAVIOR",
        gl.DEBUG_TYPE_PORTABILITY => "PORTABILITY",
        gl.DEBUG_TYPE_PERFORMANCE => "PERFORMANCE",
        gl.DEBUG_TYPE_MARKER => "MARKER",
        gl.DEBUG_TYPE_OTHER => "OTHER",
        else => "UNKNOWN",
    };

    // Severity string
    const severity_str = switch (severity) {
        gl.DEBUG_SEVERITY_NOTIFICATION => "NOTIFICATION",
        gl.DEBUG_SEVERITY_LOW => "LOW",
        gl.DEBUG_SEVERITY_MEDIUM => "MEDIUM",
        gl.DEBUG_SEVERITY_HIGH => "HIGH",
        else => "UNKNOWN",
    };

    std.debug.print(
        "{s}, {s}, {s}, {d}: {s}\n",
        .{ src_str, type_str, severity_str, id, msg_slice },
    );
}
