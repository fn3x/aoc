const std = @import("std");
const data_structures = @import("ds.zig");
const RndGen = std.crypto.random;

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    try day1(alloc, "src/1_1");
    try day2Of1("src/2");
    try day2Of2(alloc, "src/2");
}

fn day2Of2(allocator: std.mem.Allocator, input_path: []const u8) !void {
    const file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var safe_reports: usize = 0;
    var buf: [1024]u8 = undefined;

    var container = std.ArrayList(usize).init(allocator);
    defer container.deinit();

    var is_report_safe: bool = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        is_report_safe = false;
        container.clearRetainingCapacity();

        var reports = std.mem.splitSequence(u8, line, " ");
        while (reports.next()) |report| {
            const num = try std.fmt.parseInt(usize, report, 10);
            try container.append(num);
        }

        var withoutSkipped = try allocator.alloc(usize, container.items.len - 1);
        defer allocator.free(withoutSkipped);

        inner: for (0..container.items.len) |skipIndex| {
            std.mem.copyForwards(usize, withoutSkipped[0..skipIndex], container.items[0..skipIndex]);
            std.mem.copyForwards(usize, withoutSkipped[skipIndex..], container.items[skipIndex + 1 ..]);

            var previous_report: usize = withoutSkipped[0];
            var current_report: usize = withoutSkipped[1];

            const increasing = current_report > previous_report;

            if (isReportDangerous(previous_report, current_report, increasing)) {
                continue :inner;
            }

            for (2..withoutSkipped.len) |i| {
                previous_report = current_report;
                current_report = withoutSkipped[i];

                if (isReportDangerous(previous_report, current_report, increasing)) {
                    continue :inner;
                }
            }

            is_report_safe = true;
            break :inner;
        }

        if (is_report_safe) {
            safe_reports += 1;
        }
    }

    std.log.info("d2p2:: safe reports: {d}", .{safe_reports});
}

fn day2Of1(input_path: []const u8) !void {
    const file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var safe_reports: usize = 0;
    var buf: [1024]u8 = undefined;
    outer: while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var reports = std.mem.splitSequence(u8, line, " ");

        var previous_report = try std.fmt.parseInt(usize, reports.next().?, 10);
        var current_report = try std.fmt.parseInt(usize, reports.next().?, 10);

        if (current_report == previous_report) {
            continue;
        }

        if (current_report > previous_report and current_report - previous_report > 3) {
            continue;
        }

        if (current_report < previous_report and previous_report - current_report > 3) {
            continue;
        }

        const increasing: bool = current_report > previous_report;

        while (reports.next()) |num| {
            previous_report = current_report;
            current_report = try std.fmt.parseInt(usize, num, 10);

            if (isReportDangerous(previous_report, current_report, increasing)) {
                continue :outer;
            }
        }
        safe_reports += 1;
    }

    std.log.info("d2p1:: safe reports: {d}", .{safe_reports});
}

fn isReportDangerous(previous_report: usize, current_report: usize, increasing: bool) bool {
    if (current_report == previous_report) {
        return true;
    }

    if (current_report < previous_report and increasing) {
        return true;
    }

    if (current_report > previous_report and !increasing) {
        return true;
    }

    if (current_report > previous_report and current_report - previous_report > 3) {
        return true;
    }

    if (current_report < previous_report and previous_report - current_report > 3) {
        return true;
    }

    return false;
}

fn day1(alloc: std.mem.Allocator, input_path: []const u8) !void {
    const file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var tree_left = data_structures.BinaryTree(usize){ .allocator = alloc };
    defer tree_left.deinit();

    var tree_right = data_structures.BinaryTree(usize){ .allocator = alloc };
    defer tree_right.deinit();
    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splits = std.mem.splitSequence(u8, line, "   ");
        var i: usize = 0;
        while (splits.next()) |num| : (i += 1) {
            const key = try std.fmt.parseInt(usize, num, 10);
            if (i == 0) {
                try tree_left.insert(key);
            } else {
                try tree_right.insert(key);
            }
        }
    }

    var left_sorted = std.ArrayList(usize).init(alloc);
    defer left_sorted.deinit();

    try tree_left.sortAsc(&left_sorted);

    var right_sorted = std.ArrayList(usize).init(alloc);
    defer right_sorted.deinit();

    try tree_right.sortAsc(&right_sorted);

    var result: usize = 0;

    for (left_sorted.items, right_sorted.items) |left, right| {
        const abs_diff = if (left > right) left - right else right - left;
        result += abs_diff;
    }

    std.log.info("d1p1:: total distance: {d}", .{result});

    var iterator = tree_left.newIterator();
    defer iterator.deinit();

    var similarity_score: usize = 0;

    while (try iterator.next()) |node| {
        similarity_score += node.key * tree_right.lookup(node.key);
    }

    std.log.info("d1p2:: similarity score: {d}", .{similarity_score});
}
