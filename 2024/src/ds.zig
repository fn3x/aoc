const std = @import("std");
pub const Error = error{ OutOfMemory, NoSpaceLeft, AllocatorError };

pub const CharStack = struct {
    alloc: std.mem.Allocator,
    values: []usize = undefined,

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

            const NodeIterator = struct {
                stack: std.ArrayList(*Node) = undefined,

                pub fn init(allocator: std.mem.Allocator) NodeIterator {
                    return NodeIterator{ .stack = std.ArrayList(*Node).init(allocator) };
                }

                pub fn deinit(self: *NodeIterator) void {
                    self.stack.deinit();
                }

                pub fn pushLeft(self: *NodeIterator, node: *Node) Error!void {
                    var current_node: ?*Node = node;
                    while (current_node) |current| {
                        try self.stack.append(current);
                        current_node = current.left;
                    }
                }

                pub fn countOccurrences(self: *NodeIterator, key: T) usize {
                    while (try self.next()) |node| {
                        if (node.key == key) {
                            return @intCast(1 + node.num_of_duplicates);
                        }
                    }

                    return 0;
                }

                pub fn next(self: *NodeIterator) Error!?*Node {
                    if (self.stack.items.len == 0) {
                        return null;
                    }

                    const node = self.stack.pop();
                    if (node.right) |right| {
                        try self.pushLeft(right);
                    }

                    return node;
                }
            };

            pub fn isLeaf(self: *Node) bool {
                return self.left == null and self.right == null;
            }

            // @returns number of times the key appears
            pub fn lookup(self: *Node, key: T) usize {
                if (self.key == key) {
                    return self.num_of_duplicates + 1;
                }

                if (key < self.key) {
                    if (self.left) |left| {
                        return left.lookup(key);
                    }

                    return 0;
                }

                if (key > self.key) {
                    if (self.right) |right| {
                        return right.lookup(key);
                    }

                    return 0;
                }

                return 0;
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
        };

        root: ?*Node = null,
        allocator: std.mem.Allocator,

        pub fn deinit(self: *@This()) void {
            if (self.root) |node| {
                node.deinit(self.allocator);
            }
        }

        pub fn lookup(self: *@This(), key: T) usize {
            if (self.root) |root| {
                return root.lookup(key);
            }

            return 0;
        }

        pub fn sortAsc(self: *@This(), sorted: *std.ArrayList(T)) !void {
            if (self.root) |root| {
                try root.sortAsc(sorted);
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

        pub fn newIterator(self: *@This()) Node.NodeIterator {
            var iterator: Node.NodeIterator = Node.NodeIterator.init(self.allocator);
            iterator.pushLeft(self.root.?) catch unreachable;
            return iterator;
        }

        pub fn compare(self: *@This(), other: *@This()) usize {
            var sum: usize = 0;

            if (self.root) |root| {
                sum += 1;
                if (other.root) |otherRoot| {
                    _ = otherRoot;
                    _ = root;
                }
            }

            return sum;
        }
    };
}
