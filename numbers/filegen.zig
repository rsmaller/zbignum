const std = @import("std");
const io_bufsize = 256;
var io_buf : [io_bufsize]u8 = .{0} ** io_bufsize;
var stdout_writer = std.fs.File.stdout().writer(&io_buf);
const stdout = &stdout_writer.interface;
const c_allocator = std.heap.c_allocator;

const FileGenError = error {
    ArgLengthError,
};

const numbers = [_][]const u8{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};

pub inline fn secondsFromNanoseconds(nanoseconds: u64) f64 {
    return @as(f64, @floatFromInt(nanoseconds)) / 1000000000.0;
}

pub fn main() !void {
    const args = try std.process.argsAlloc(c_allocator);
    defer c_allocator.free(args);
    const rand = std.crypto.random;
    const cwd = std.fs.cwd();
    if (args.len < 2) {
        return error.ArgLengthError;
    }
    const file_size = try std.fmt.parseInt(usize, args[1], 10);
    const file = try cwd.createFile("num.txt", .{});
    var buf : [1<<20]u8 = undefined;
    var file_writer = file.writer(&buf);
    var file_writer_int = &file_writer.interface;
    defer file.close();
    var timer = try std.time.Timer.start();
    const start = timer.read();
    for (0..file_size) |_| {
        _ = try file_writer_int.writeAll(numbers[std.Random.intRangeAtMost(rand, usize, 0, 9)]);
    }
    const end = timer.read();
    try file_writer_int.flush();
    try stdout.print("Time to write: {d} seconds\n", .{secondsFromNanoseconds(end - start)});
    try stdout.flush();
}