const std = @import("std");
const common = @import("./_common.zig");

pub const do = common.Main(struct {
    pub const source_file = "SpecialCasing";

    pub const dest_file = "src/special_casing.zig";

    pub const dest_header =
        \\pub const SpecialCasing = struct {
        \\    code: u21,
        \\    lower: []const u21,
        \\    title: []const u21,
        \\    upper: []const u21,
        \\    condition: []const u8,
        \\};
        \\
        \\pub const data = [_]SpecialCasing{
        \\
    ;

    pub const dest_footer =
        \\};
        \\
    ;

    pub fn exec(alloc: std.mem.Allocator, line: []const u8, writer: anytype) !void {
        _ = alloc;
        var it = std.mem.splitScalar(u8, line, ';');

        const code = std.mem.trim(u8, it.next().?, " \t");
        const lower = std.mem.trim(u8, it.next().?, " \t");
        const title = std.mem.trim(u8, it.next().?, " \t");
        const upper = std.mem.trim(u8, it.next().?, " \t");
        const condition = std.mem.trim(u8, it.next() orelse "", " \t");

        try writer.writeAll("    .{");
        try writer.writeAll(" .code =");
        try common.printCodepoint(writer, code);
        try writer.writeAll(" .lower =");
        try common.printSeq(writer, lower);
        try writer.writeAll(" .title =");
        try common.printSeq(writer, title);
        try writer.writeAll(" .upper =");
        try common.printSeq(writer, upper);
        try writer.print(" .condition = \"{f}\"", .{std.zig.fmtString(condition)});
        try writer.writeAll(" },\n");
    }
}).do;
