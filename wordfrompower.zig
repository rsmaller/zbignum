const std = @import("std");
const bignum = @import("bignum.zig");
const page_allocator = std.heap.page_allocator;
const c_allocator = std.heap.c_allocator;
var stdout : *std.Io.Writer = undefined;

pub fn main() !void {
    const io_bufsize = 1 << 21;
    var io_buf : [io_bufsize]u8 = .{0} ** io_bufsize;
    var writer = std.fs.File.stdout().writer(&io_buf);
    stdout = &writer.interface;
    const args = try std.process.argsAlloc(page_allocator);
    defer std.process.argsFree(page_allocator, args);
    const exponent = try std.fmt.parseInt(usize, args[1], 10);
    try bignum.preGenerateThousandsArr(bignum.thousandGroupings(exponent));
    defer {
        if (bignum.word_from_power_thousands_arr) |unbound_arr| {
            c_allocator.free(unbound_arr);
        }
    }
    var buf : [bignum.max_word_size]u8 = undefined;
    const filled = try bignum.wordFromPower(exponent, &buf);
    try stdout.print("{s}\n", .{buf[0..filled]});
    try stdout.flush();
}