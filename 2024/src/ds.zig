const std = @import("std");
pub const Error = error{ OutOfMemory, NoSpaceLeft };

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
    key: u32,
    height: u32 = 1,
    left: ?*Node,
    right: ?*Node,

    pub fn init(allocator: std.mem.Allocator) Error!*Node {
        const node = try allocator.create(Node);
        node.left = null;
        node.right = null;
        node.height = 1;
        node.key = 0;
        return node;
    }

    pub fn deinit(self: *Node, allocator: std.mem.Allocator) void {
        if (self.left) |left| {
            left.deinit(allocator);
        }

        if (self.right) |right| {
            right.deinit(allocator);
        }

        allocator.destroy(self);
    }

    pub fn isLeaf(self: *Node) bool {
        return self.left == null and self.right == null;
    }

    pub fn lookup(self: *Node, key: u32) bool {
        if (self.key == key) {
            return true;
        }

        if (key < self.key) {
            if (self.left) |left| {
                return left.lookup(key);
            }

            return false;
        }

        if (key > self.key) {
            if (self.right) |right| {
                return right.lookup(key);
            }

            return false;
        }

        return false;
    }

    pub fn insert(self: *Node, node: *Node) void {
        if (self.key == node.key) {
            return;
        }

        if (node.key < self.key) {
            if (self.left) |left| {
                left.insert(node);
            } else {
                node.height = self.height + 1;
                self.left = node;
            }
        } else {
            if (self.right) |right| {
                right.insert(node);
            } else {
                node.height = self.height + 1;
                self.right = node;
            }
        }
    }

    pub fn min(self: *Node) u32 {
        if (self.left) |left| {
            return left.min();
        } else {
            return self.key;
        }
    }
};

pub const BinaryTree = struct {
    root: ?*Node = null,

    pub fn init() BinaryTree {
        return BinaryTree{
            .root = null,
        };
    }

    pub fn deinit(self: *BinaryTree, allocator: std.mem.Allocator) void {
        if (self.root) |node| {
            node.deinit(allocator);
        }
    }

    pub fn lookup(self: *BinaryTree, key: u32) bool {
        if (self.root) |root| {
            return root.lookup(key);
        }

        return false;
    }

    pub fn min(self: *BinaryTree) u32 {
        if (self.root) |root| {
            return root.min();
        }

        return 0;
    }

    pub fn insert(self: *BinaryTree, allocator: std.mem.Allocator, key: u32) !void {
        const node = try Node.init(allocator);
        node.key = key;
        if (self.root) |root| {
            root.insert(node);
        } else {
            node.key = key;
            self.root = node;
        }
    }
};