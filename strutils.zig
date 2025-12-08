const std = @import("std");

pub fn strPushFormat(buffer: [] u8, filled: usize, comptime format: []const u8, items: anytype) !usize {
    const count = std.fmt.count(format, items);
    if (filled + count >= buffer.len) {
        return error.BufferFullError;
    }
    @memmove(buffer[count..], buffer[0..buffer.len-count]);
    _ = try std.fmt.bufPrint(buffer[0..count], format, items);
    return count;
}

pub fn strConcatFormat(buffer: []u8, filled: usize, comptime format : []const u8, items: anytype) !usize {
    const count = std.fmt.count(format, items);
    if (filled + count >= buffer.len) {
        return error.BufferFullError;
    }
    _ = try std.fmt.bufPrint(buffer[filled..filled+count], format, items);
    return count;
}

pub inline fn strConcatLowOverhead(buffer: []u8, filled : usize, item: []const u8) usize {
    @memcpy(buffer[filled..filled+item.len], item);
    return item.len;
}