const std = @import("std");
const data_structures = @import("ds.zig");
const RndGen = std.crypto.random;

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const day1_1_result = try day1Of1(alloc, "src/1_1");
    std.debug.print("day 1 result: {d}\n", .{day1_1_result});
}

pub fn day1Of1(alloc: std.mem.Allocator, input_path: []const u8) !i32 {
    const file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var tree_left = data_structures.BinaryTree(u32){ .allocator = alloc };
    defer tree_left.deinit();

    var tree_right = data_structures.BinaryTree(u32){ .allocator = alloc };
    defer tree_right.deinit();

    var line = std.ArrayList(u8).init(alloc);
    defer line.deinit();

    const line_writer = line.writer();

    while (reader.streamUntilDelimiter(line_writer, '\n')) {
        defer line.clearRetainingCapacity();
        var splits = std.mem.splitSequence(u8, line.items, " ");
        var i: usize = 0;
        while (splits.next()) |num|: (i += 1) {
            _ = num;
            if (i == 0) {
                tree_left.insert();
            }
        }
    }

    var sorted = std.ArrayList(u32).init(alloc);
    defer sorted.deinit();

    std.log.info("sorted: {any}", .{ sorted.items });
    return 0;
}
