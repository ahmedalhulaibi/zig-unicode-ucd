const std = @import("std");
const common = @import("./_common.zig");

pub const do = common.Main(struct {
    pub const source_file = "DerivedCoreProperties";

    pub const dest_file = "src/indic_conjunct_break.zig";

    pub const dest_header =
        \\pub const IndicConjunctBreak = struct {
        \\    from: u21,
        \\    to: u21,
        \\    property: Property,
        \\
        \\    pub const Property = enum(u2) {
        \\        None,
        \\        Consonant,
        \\        Extend,
        \\        Linker,
        \\    };
        \\};
        \\
        \\pub const data = [_]IndicConjunctBreak{
        \\
    ;

    pub const dest_footer =
        \\};
        \\
    ;

    pub fn exec(alloc: std.mem.Allocator, line: []const u8, writer: anytype) !void {
        _ = alloc;
        var fields = std.mem.splitScalar(u8, line, ';');
        const range = std.mem.trim(u8, fields.next().?, " \t");
        const property = std.mem.trim(u8, fields.next().?, " \t");
        if (!std.mem.eql(u8, property, "InCB")) return;
        const value = std.mem.trim(u8, fields.next().?, " \t");

        if (std.mem.indexOf(u8, range, "..")) |index| {
            try writer.print(
                "    .{{ .from = 0x{s}, .to = 0x{s}, .property = .{s} }},\n",
                .{ range[0..index], range[index + 2 ..], value },
            );
        } else {
            try writer.print(
                "    .{{ .from = 0x{s}, .to = 0x{s}, .property = .{s} }},\n",
                .{ range, range, value },
            );
        }
    }

    pub fn after(alloc: std.mem.Allocator, writer: anytype) !void {
        _ = alloc;
        try writer.writeAll(
            \\pub fn get(codepoint: u21) IndicConjunctBreak.Property {
            \\    for (data) |entry| {
            \\        if (entry.from <= codepoint and codepoint <= entry.to) return entry.property;
            \\    }
            \\    return .None;
            \\}
            \\
        );
    }
}).do;
