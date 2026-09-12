const std = @import("std");
const common = @import("./_common.zig");

pub const do = common.Main(struct {
    pub const source_file = "auxiliary/GraphemeBreakProperty";

    pub const dest_file = "src/grapheme_break_property.zig";

    pub const dest_header =
        \\pub const GraphemeBreakProperty = struct {
        \\    from: u21,
        \\    to: u21,
        \\    property: Property,
        \\
        \\    pub const Property = enum(u4) {
        \\        Control,
        \\        CR,
        \\        Extend,
        \\        L,
        \\        LF,
        \\        LV,
        \\        LVT,
        \\        Prepend,
        \\        Regional_Indicator,
        \\        SpacingMark,
        \\        T,
        \\        V,
        \\        Other,
        \\        ZWJ,
        \\    };
        \\};
        \\
        \\pub const data = [_]GraphemeBreakProperty{
        \\
    ;

    pub const dest_footer =
        \\};
        \\
    ;

    pub const exec = common.RangeEnum("property").exec;

    pub fn after(alloc: std.mem.Allocator, writer: anytype) !void {
        _ = alloc;
        try writer.writeAll(
            \\pub fn get(codepoint: u21) GraphemeBreakProperty.Property {
            \\    for (data) |entry| {
            \\        if (entry.from <= codepoint and codepoint <= entry.to) return entry.property;
            \\    }
            \\    return .Other;
            \\}
            \\
        );
    }
}).do;
