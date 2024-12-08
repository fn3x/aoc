const std = @import("std");
const data_structures = @import("ds.zig");
const RndGen = std.crypto.random;

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    try day1Of1(alloc, "src/1_1");
}

pub fn day1Of1(alloc: std.mem.Allocator, input_path: []const u8) !void {
    const file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var tree_left = data_structures.BinaryTree(isize){ .allocator = alloc };
    defer tree_left.deinit();

    var tree_right = data_structures.BinaryTree(isize){ .allocator = alloc };
    defer tree_right.deinit();
    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splits = std.mem.splitSequence(u8, line, "   ");
        var i: usize = 0;
        while (splits.next()) |num| : (i += 1) {
            const key = try std.fmt.parseInt(isize, num, 10);
            if (i == 0) {
                try tree_left.insert(key);
            } else {
                try tree_right.insert(key);
            }
        }
    }

    var left_sorted = std.ArrayList(isize).init(alloc);
    defer left_sorted.deinit();

    try tree_left.sortAsc(&left_sorted);

    var right_sorted = std.ArrayList(isize).init(alloc);
    defer right_sorted.deinit();

    try tree_right.sortAsc(&right_sorted);

    var result: isize = 0;

    for (left_sorted.items, right_sorted.items) |left, right| {
        result += @intCast(@abs(left - right));
    }
    
    std.log.info("day 1 of 1: {d}", .{result});
}
