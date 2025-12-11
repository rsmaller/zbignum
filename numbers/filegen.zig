const std = @import("std");
const c_allocator = std.heap.c_allocator;

const FileGenError = error {
    ArgLengthError,
};

const numbers = [_][]const u8{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};

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
    var writer : std.fs.File.Writer = file.writer(&buf);
    defer file.close();
    for (0..file_size) |_| {
        _ = try writer.file.write(numbers[std.Random.intRangeAtMost(rand, usize, 0, 9)]);
    }
}