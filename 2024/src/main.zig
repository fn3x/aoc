const std = @import("std");
const data_structures = @import("ds.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const day1_1_result = try day1Of1(alloc, "src/1_1");
    std.debug.print("day 1 result: {d}\n", .{day1_1_result});
}

pub fn day1Of1(alloc: std.mem.Allocator, input_path: []const u8) !i32 {
    const file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();

    const file_stat = try file.stat();
    const file_size = file_stat.size;

    const buffer: []u8 = try alloc.alloc(u8, file_size);
    defer alloc.free(buffer);

    _ = try file.readAll(buffer);

    var tree = data_structures.BinaryTree.init(alloc);
    defer tree.deinit();

    try tree.insert(1);
    try tree.insert(5);
    try tree.insert(2);
    try tree.insert(3);
    try tree.traverse();

    return 0;
}
