const std = @import("std");

pub const version = "18.0.0";

pub fn Main(comptime T: type) type {
    comptime std.debug.assert(@hasDecl(T, "source_file"));
    comptime std.debug.assert(@hasDecl(T, "dest_file"));
    comptime std.debug.assert(@hasDecl(T, "dest_header"));
    comptime std.debug.assert(@hasDecl(T, "dest_footer"));
    comptime std.debug.assert(@hasDecl(T, "exec"));
    return struct {
        pub fn do() !void {
            const source_url = "https://unicode.org/Public/" ++ version ++ "/ucd/" ++ T.source_file ++ ".txt";
            var io: std.Io.Threaded = .init(std.heap.page_allocator, .{});
            defer io.deinit();
            const response = try std.process.run(std.heap.page_allocator, io.io(), .{
                .argv = &.{ "curl", "-fsSL", source_url },
            });
            defer std.heap.page_allocator.free(response.stdout);
            defer std.heap.page_allocator.free(response.stderr);
            if (response.term != .exited or response.term.exited != 0) return error.DownloadFailed;

            const file = try std.Io.Dir.cwd().createFile(io.io(), T.dest_file, .{});
            defer file.close(io.io());
            var w = file.writer(io.io(), &.{});
            const writer = &w.interface;

            try writer.writeAll(
                \\// This file is part of the Unicode Character Database
                \\// For documentation, see http://www.unicode.org/reports/tr44/
                \\//
                \\
            );
            try writer.print(
                \\// Based on the source file: {s}
                \\//
                \\// zig fmt: off
                \\
                \\
            , .{source_url});
            try writer.writeAll(T.dest_header);

            var lines = std.mem.splitScalar(u8, response.stdout, '\n');
            while (lines.next()) |raw_line| {
                const line = std.mem.trim(u8, raw_line[0..(std.mem.indexOfScalar(u8, raw_line, '#') orelse raw_line.len)], " \t\r");
                if (line.len == 0) continue;
                try T.exec(std.heap.page_allocator, line, writer);
            }
            try writer.writeAll(T.dest_footer);
            if (@hasDecl(T, "after")) try T.after(std.heap.page_allocator, writer);
        }
    };
}

pub fn nullify(input: ?[]const u8) ?[]const u8 {
    if (input == null) return null;
    if (input.?.len == 0) return null;
    return input;
}

pub fn RangeEnum(comptime prop: []const u8) type {
    return struct {
        pub fn exec(alloc: std.mem.Allocator, line: []const u8, writer: anytype) !void {
            _ = alloc;
            var it = std.mem.tokenizeAny(u8, line, "; ");

            const first = it.next().?;
            const next = std.mem.trimEnd(u8, it.next().?, "#");

            if (std.mem.indexOf(u8, first, "..")) |index| {
                const start = first[0..index];
                const end = first[index + 2 ..];
                try writer.print("    .{{ .from = 0x{s}, .to = 0x{s}, .{s} = .{s} }},\n", .{ start, end, prop, next });
            } else {
                try writer.print("    .{{ .from = 0x{s}, .to = 0x{s}, .{s} = .{s} }},\n", .{ first, first, prop, next });
            }
        }
    };
}

pub fn printCodepoint(writer: anytype, input: []const u8) !void {
    try writer.print(" 0x{s},", .{input});
}

pub fn printSeq(writer: anytype, input: []const u8) !void {
    var jt = std.mem.tokenizeScalar(u8, input, ' ');
    try writer.writeAll(" &.{");
    while (jt.next()) |jtem| {
        try printCodepoint(writer, jtem);
    }
    try writer.writeAll(" },");
}
