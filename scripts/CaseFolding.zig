const std = @import("std");
const common = @import("./_common.zig");

pub const do = common.Main(struct {
    pub const source_file = "CaseFolding";

    pub const dest_file = "src/case_folding.zig";

    pub const dest_header =
        \\pub const CaseFolding = struct {
        \\    code: u21,
        \\    status: Status,
        \\    mapping: Mapping,
        \\
        \\    pub const Status = enum {
        \\        C,
        \\        F,
        \\        S,
        \\        T,
        \\    };
        \\
        \\    pub const Mapping = union(Status) {
        \\        C: u21,
        \\        F: []const u21,
        \\        S: u21,
        \\        T: u21,
        \\    };
        \\};
        \\
        \\pub const data = [_]CaseFolding{
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
        const status = std.mem.trim(u8, it.next().?, " \t");
        const mapping = std.mem.trim(u8, it.next().?, " \t");
        try writer.print("    .{{ .code = 0x{s}, .status = .{s}, .mapping = .{{ .{s} =", .{ code, status, status });

        switch (std.meta.stringToEnum(enum { C, F, S, T }, status) orelse @panic(status)) {
            .C, .S, .T => {
                try writer.print(" 0x{s}", .{mapping});
            },
            .F => {
                var jt = std.mem.splitScalar(u8, mapping, ' ');
                try writer.writeAll(" &[_]u21{");
                while (jt.next()) |jtem| {
                    try writer.print("0x{s},", .{jtem});
                }
                try writer.writeAll("}");
            },
        }
        try writer.writeAll(" } },\n");
    }
}).do;
