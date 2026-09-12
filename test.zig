const std = @import("std");
const ucd = @import("unicode-ucd");

test {
    _ = &ucd.arabic_shaping.data;
    _ = &ucd.bidi_brackets.data;
    _ = &ucd.bidi_mirroring.data;
    _ = &ucd.blocks.data;
    _ = &ucd.cjk_radicals.data;
    _ = &ucd.case_folding.data;
    _ = &ucd.composition_exclusions.data;
    _ = &ucd.derived_age.data;
    _ = &ucd.derived_core_properties.data;
    inline for (@typeInfo(ucd.derived_normalization_props).@"struct".decls) |d| {
        const f = @field(ucd.derived_normalization_props, d.name);
        if (@typeInfo(f).@"struct".decls.len == 0) _ = &f;
        if (@typeInfo(f).@"struct".decls.len > 0) _ = &f.data;
        if (@typeInfo(f).@"struct".decls.len > 0) _ = &f.data_range;
    }
    _ = &ucd.east_asian_width.data;
    _ = &ucd.emoji_sources.data;
    _ = &ucd.equivalent_unified_ideograph.data;
    _ = &ucd.hangul_syllable_type.data;
    _ = &ucd.indic_positional_category.data;
    _ = &ucd.indic_syllabic_category.data;
    _ = &ucd.jamo.data;
    _ = &ucd.line_break.data;
    _ = &ucd.name_aliases.data;
    _ = &ucd.named_sequences.data;
    _ = &ucd.named_sequences_prov.data;
    _ = &ucd.prop_list.data;
    _ = &ucd.scripts.data;
    _ = &ucd.vertical_orientation.data;
    _ = &ucd.emoji.data;
    _ = &ucd.grapheme_break_property.data;
    _ = &ucd.script_extensions.data;
    _ = &ucd.property_aliases.data;
    _ = &ucd.property_value_aliases.data;
    _ = &ucd.unicode_data.data_code;
    _ = &ucd.special_casing.data;
}

test "grapheme cluster break lookup" {
    const gcb = ucd.grapheme_break_property;
    try std.testing.expectEqual(@as(u16, 4), @bitSizeOf(gcb.GraphemeBreakProperty.Property));
    const cases = [_]struct { codepoint: u21, property: gcb.GraphemeBreakProperty.Property }{
        .{ .codepoint = 0x0000, .property = .Control },
        .{ .codepoint = 0x000D, .property = .CR },
        .{ .codepoint = 0x000A, .property = .LF },
        .{ .codepoint = 0x0300, .property = .Extend },
        .{ .codepoint = 0x200D, .property = .ZWJ },
        .{ .codepoint = 0x1F1E6, .property = .Regional_Indicator },
        .{ .codepoint = 0x1100, .property = .L },
        .{ .codepoint = 0x1160, .property = .V },
        .{ .codepoint = 0x11A8, .property = .T },
        .{ .codepoint = 0xAC00, .property = .LV },
        .{ .codepoint = 0xAC01, .property = .LVT },
        .{ .codepoint = 0x0041, .property = .Other },
    };

    for (cases) |case| try std.testing.expectEqual(case.property, gcb.get(case.codepoint));
}
