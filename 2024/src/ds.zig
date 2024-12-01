const std = @import("std");
pub const CharStack = struct {
    alloc: std.mem.Allocator,
    values: []usize = .{},

    fn deinit(self: *CharStack) void {
        self.alloc.free(self.values);
    }

    fn push(self: *CharStack, v: usize) void {
        var new_slice = try self.alloc.alloc(usize, self.values.len + 1);
        std.mem.copyForwards(usize, new_slice, self.values);
        new_slice[self.values.len] = v;
        self.alloc.free(self.values);
        self.values = new_slice;
    }

    fn pop(self: *CharStack) ?usize {
        if (self.values.len == 0) {
            return null;
        }

        const value = self.values[self.values.len - 1];
        self.values = self.values[0 .. self.values.len - 2];

        return value;
    }
};

const Node = struct {
    keys: []u32,
    children: []*Node,
    is_leaf: bool,
    max_keys: usize,

    pub fn init(allocator: *std.mem.Allocator, order: usize) !*Node {
        const node = try allocator.create(Node);
        node.keys = try allocator.alloc(u32, order * 2 - 1);
        node.children = try allocator.alloc(*Node, order * 2);
        node.is_leaf = true;
        node.max_keys = order * 2 - 1;
        return &node;
    }

    pub fn deinit(self: *Node, allocator: *std.mem.Allocator) void {
        allocator.free(self.keys);
        allocator.free(self.children);
        allocator.destroy(self);
    }
};

const BTree = struct {
    root: ?*Node,
    allocator: *std.mem.Allocator,
    order: usize,

    pub fn init(allocator: *std.mem.Allocator, order: usize) BTree {
        return BTree{
            .root = null,
            .allocator = allocator,
            .order = order,
        };
    }

    pub fn deinit(self: *BTree) void {
        if (self.root) |node| {
            node.deinit(self.allocator);
        }
    }
};

pub fn newBTree() void {}
