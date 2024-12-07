const std = @import("std");
pub const Error = error{ OutOfMemory, NoSpaceLeft, AllocatorError };

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

pub fn BinaryTree(comptime T: type) type {
    return struct {
        const Node = struct {
            key: T,
            num_of_duplicates: u32 = 0,
            height: u32 = 1,
            left: ?*Node,
            right: ?*Node,

            pub fn init(allocator: std.mem.Allocator, key: T) Error!*Node {
                const node = try allocator.create(Node);
                node.left = null;
                node.right = null;
                node.height = 1;
                node.num_of_duplicates = 0;
                node.key = key;
                return node;
            }

            pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
                if (self.left) |left| {
                    left.deinit(allocator);
                }

                if (self.right) |right| {
                    right.deinit(allocator);
                }

                allocator.destroy(self);
            }

            pub fn isLeaf(self: *@This()) bool {
                return self.left == null and self.right == null;
            }

            pub fn lookup(self: *Node, key: T) bool {
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
                    self.num_of_duplicates += 1;
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

            pub fn sortAsc(self: *Node, result: *std.ArrayList(T)) Error!void {
                if (self.left) |left| {
                    try left.sortAsc(result);
                }

                try result.append(self.key);
                for (0..self.num_of_duplicates) |_| {
                    try result.append(self.key);
                }

                if (self.right) |right| {
                    try right.sortAsc(result);
                }
            }

            pub fn countChildren(self: *Node) u32 {
                var num_children: u32 = 0;
                if (self.left) |left| {
                    num_children += left.countChildren();
                }

                if (self.right) |right| {
                    num_children += right.countChildren();
                }

                return num_children + 1;
            }
        };

        root: ?*Node = null,
        allocator: std.mem.Allocator,

        pub fn deinit(self: *@This()) void {
            if (self.root) |node| {
                node.deinit(self.allocator);
            }
        }

        pub fn lookup(self: *@This(), key: T) bool {
            if (self.root) |root| {
                return root.lookup(key);
            }

            return false;
        }

        pub fn sortAsc(self: *@This(), sorted: *std.ArrayList(T)) !void {
            if (self.root) |root| {
                try root.sortAsc(sorted);
            }
        }

        pub fn count(self: *@This()) u32 {
            if (self.root) |root| {
                return root.countChildren();
            } else {
                return 0;
            }
        }

        pub fn insert(self: *@This(), key: T) !void {
            const node = try Node.init(self.allocator, key);
            if (self.root) |root| {
                root.insert(node);
            } else {
                self.root = node;
            }
        }
    };
}
