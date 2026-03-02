const std = @import("std");

pub const Node = struct {
    name: std.ArrayList(u8),
    children: std.ArrayList(*Node),

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*Node {
        const ret = try allocator.create(Node);

        ret.name = .empty;
        ret.children = .empty;
        ret.allocator = allocator;

        return ret;
    }

    pub fn destroy(self: *Node) void {
        self.deinit();
        self.allocator.destroy(self);
    }

    fn deinit(self: *Node) void {
        for (self.children.items) |child| {
            child.deinit();
            self.allocator.destroy(child);
        }

        self.children.deinit(self.allocator);
        self.name.deinit(self.allocator);
    }

    pub fn root(allocator: std.mem.Allocator) !*Node {
        var ret: *Node = try .init(allocator);

        try ret.name.appendSlice(allocator, "root");

        return ret;
    }

    pub fn addNode(self: *Node, name: [:0]const u8) !*Node {
        for (self.children.items) |child| {
            if (std.mem.eql(u8, child.name.items, name)) {
                //std.log.warn("Folder \"{s}\" already exits", .{name});
                return child;
            }
        }

        var node: *Node = try .init(self.allocator);
        try node.name.appendSlice(self.allocator, name);

        try self.children.append(self.allocator, node);

        return node;
    }

    pub fn addPath(self: *Node, path: [:0]const u8) !void {
        var parent = self;

        var it = std.mem.splitAny(u8, path, "\\\x00");
        while (it.next()) |part| {
            if (part.len == 0) {
                break;
            }
            //std.log.debug("Added {s}", .{part});
            parent = try parent.addNode(@ptrCast(part));
        }
    }
};
