const std = @import("std"); // works with version 0.15.1+
const strutils = @import("strutils.zig");
const page_allocator = std.heap.page_allocator;
const c_allocator = std.heap.c_allocator;
var word_from_power_thousands_arr : ?[]u10 = null;
const io_bufsize = 1 << 21;
var io_buf : [io_bufsize]u8 = .{0} ** io_bufsize;
var writer = std.fs.File.stdout().writer(&io_buf);
const stdout = &writer.interface;

const bases = [_][]const u8 {
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
    "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen",
    "twenty", "twenty-one", "twenty-two", "twenty-three", "twenty-four", "twenty-five", "twenty-six", "twenty-seven", "twenty-eight", "twenty-nine",
    "thirty", "thirty-one", "thirty-two", "thirty-three", "thirty-four", "thirty-five", "thirty-six", "thirty-seven", "thirty-eight", "thirty-nine",
    "forty", "forty-one", "forty-two", "forty-three", "forty-four", "forty-five", "forty-six", "forty-seven", "forty-eight", "forty-nine",
    "fifty", "fifty-one", "fifty-two", "fifty-three", "fifty-four", "fifty-five", "fifty-six", "fifty-seven", "fifty-eight", "fifty-nine",
    "sixty", "sixty-one", "sixty-two", "sixty-three", "sixty-four", "sixty-five", "sixty-six", "sixty-seven", "sixty-eight", "sixty-nine",
    "seventy", "seventy-one", "seventy-two", "seventy-three", "seventy-four", "seventy-five", "seventy-six", "seventy-seven", "seventy-eight", "seventy-nine",
    "eighty", "eighty-one", "eighty-two", "eighty-three", "eighty-four", "eighty-five", "eighty-six", "eighty-seven", "eighty-eight", "eighty-nine",
    "ninety", "ninety-one", "ninety-two", "ninety-three", "ninety-four", "ninety-five", "ninety-six", "ninety-seven", "ninety-eight", "ninety-nine"
};

const single_digit_powers = [_][]const u8 {"thousand", "million", "billion", "trillion", "quadrillion", "quintillion", "sextillion",
    "septillion", "octillion", "nonillion"};

const double_digit_modifiers = [_][]const u8 {"", "un", "duo", "tre", "quattuor", "quin", "sex", "septen", "octo", "novem"};
const double_digit_powers = [_][]const u8 {"", "decillion", "vigintillion", "trigintillion", "quadragintillion", "quinquagintillion", "sexagintillion", "septuagintillion", "octogintillion", "nonagintillion"};

const triple_digit_powers = [_][]const u8 {"", "centillion", "ducentillion", "trecentillion", "quadringentillion", "quingentillion", "sescentillion", "septingentillion", "octingentillion", "nongentillion"};
const triple_double_digit_modifiers = [_][]const u8 {"", "deci", "viginti", "triginta", "quadraginta", "quinquaginta", "sexaginta", "septuaginta", "octoginta", "nonaginta"};
const triple_single_digit_modifiers = [_][]const u8 {"", "un", "duo", "tre", "quattuor", "quin", "sex", "septen", "octo", "novem"};

const quadruple_digit_powers = [_][]const u8 {"", "milli", "duomilli", "tremilli", "quattuormilli", "quinqumilli", "sexmilli", "septemmilli", "octomilli", "novemmilli"};
const quadruple_triple_digit_modifiers = [_][]const u8 {"", "centi", "ducenti", "trecenti", "quadringenti", "quingenti", "sescenti", "septingenti", "octingenti", "nongenti"};
const quadruple_double_digit_modifiers = [_][]const u8 {"", "deci", "viginti", "triginta", "quadraginta", "quinquaginta", "sexaginta", "septuaginta", "octoginta", "nonaginta"};
const quadruple_single_digit_modifiers = [_][]const u8 {"", "un", "duo", "tres", "quattuor", "quin", "sex", "septen", "octo", "novem"};

const quintuple_digit_powers = [_][]const u8 {"", "decem", "viginti", "triginta", "quadraginta", "quinquaginta", "sexaginta", "septuaginta", "octoginta", "nonaginta"};
const quintuple_digit_modifiers = [_][]const u8 {"", "un", "duo", "tres", "quattuor", "quin", "sex", "septen", "octo", "novem"};
const quintuple_triple_digit_modifiers = [_][]const u8 {"", "centi", "ducenti", "trecenti", "quadringenti", "quingenti", "sescenti", "septingenti", "octingenti", "nongenti"};
const quintuple_double_digit_modifiers = [_][]const u8 {"", "deci", "viginti", "triginta", "quadraginta", "quinquaginta", "sexaginta", "septuaginta", "octoginta", "nonaginta"};
const quintuple_single_digit_modifiers = [_][]const u8 {"", "un", "duo", "tres", "quattuor", "quin", "sex", "septen", "octo", "novem"};

const BigNumError = error {
    SizeError,
    BufferFullError,
    ArgLengthError,
    MemoryLeakError,
    InvalidAllocationAccessError,
};

const max_word_size : usize = 255;

pub fn injectUnderThousandNum(buffer: []u8, filled: usize, num: u10) !usize {
    var current_filled : usize = filled;
    if (num >= 100) {
        if (num % 100 != 0) {
            current_filled += strutils.strConcatLowOverhead(buffer, current_filled, bases[num / 100]);
            current_filled += strutils.strConcatLowOverhead(buffer, current_filled, " hundred ");
            current_filled += strutils.strConcatLowOverhead(buffer, current_filled, bases[num % 100]);
            current_filled += strutils.strConcatLowOverhead(buffer, current_filled, " ");
            return current_filled - filled;

        } else {
            current_filled += strutils.strConcatLowOverhead(buffer, current_filled, " ");
            current_filled += strutils.strConcatLowOverhead(buffer, current_filled, bases[num % 100]);
            current_filled += strutils.strConcatLowOverhead(buffer, current_filled, " ");
            return current_filled - filled;
        }
    } else {
        current_filled += strutils.strConcatLowOverhead(buffer, current_filled, bases[num]);
        current_filled += strutils.strConcatLowOverhead(buffer, current_filled, " ");
        return current_filled - filled;
    }
}

pub inline fn thousandGroupings(num: anytype) @TypeOf(num) {
    if (num == 0) return 1;
    var divloop = num;
    var res : @TypeOf(num) = 0;
    while (divloop > 0) : (divloop /= 1000) {
        res += 1;
    }
    return res;
}

pub fn wordFromPower(num: usize, result: []u8) !usize {
    if (num < 3) return 0;
    const exp_num = num / 3 - 1;
    var filled : usize = 0;
    if (exp_num >= 100000) {
        var exp_calc = exp_num;
        var thousands_index = thousandGroupings(exp_num) - 1;
        var word_from_power_thousands_arr_unbound : []u10 = undefined;
        if (word_from_power_thousands_arr) |word_from_power_thousands_arr_binding| {
            word_from_power_thousands_arr_unbound = word_from_power_thousands_arr_binding;
        } else {
            return error.InvalidAllocationAccessError;
        }
        while (thousands_index >= 0) : (thousands_index -= 1) {
            const current = @as(u10, @truncate(exp_calc % 1000));
            exp_calc /= 1000;
            word_from_power_thousands_arr_unbound[thousands_index] = current;
            if (thousands_index == 0) break;
        }
        for (word_from_power_thousands_arr_unbound, 0..) |item, milli_count_subtractor| {
            if (!(item == 1 and milli_count_subtractor == 0)) {
                filled += strutils.strConcatLowOverhead(result, filled, quadruple_triple_digit_modifiers[item / 100 % 10]);
                filled += strutils.strConcatLowOverhead(result, filled, triple_double_digit_modifiers[item / 10 % 10]);
                filled += strutils.strConcatLowOverhead(result, filled, triple_single_digit_modifiers[item % 10]);
            }
            if (item != 0) {
                const milli_count = word_from_power_thousands_arr_unbound.len - milli_count_subtractor - 1;
                for (0..milli_count) |_| {
                    filled += strutils.strConcatLowOverhead(result, filled, "milli");
                }
            }
        }
        if (filled >= 5 and std.mem.startsWith(u8, result[filled-5..], "milli"[0..])) {
            filled += strutils.strConcatLowOverhead(result, filled, "n");
        }
        filled += strutils.strConcatLowOverhead(result, filled, "illion");
    } else if (exp_num >= 10000) {
        filled += strutils.strConcatLowOverhead(result, filled, quintuple_digit_modifiers[exp_num / 1000 % quintuple_digit_powers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, quintuple_digit_powers[exp_num / 10000 % quintuple_digit_powers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, "milli");
        filled += strutils.strConcatLowOverhead(result, filled, quintuple_triple_digit_modifiers[exp_num / 100 % quintuple_triple_digit_modifiers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, quintuple_double_digit_modifiers[exp_num / 10 % quintuple_double_digit_modifiers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, quintuple_single_digit_modifiers[exp_num % 10]);
        if (filled >= 5 and std.mem.startsWith(u8, result[filled-5..], "milli"[0..])) {
            filled += strutils.strConcatLowOverhead(result, filled, "n");
        }
        filled += strutils.strConcatLowOverhead(result, filled, "illion");
    } else if (exp_num >= 1000) {
        filled += strutils.strConcatLowOverhead(result, filled, quadruple_digit_powers[exp_num / 1000 % quadruple_digit_powers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, quadruple_triple_digit_modifiers[exp_num / 100 % quadruple_triple_digit_modifiers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, quadruple_double_digit_modifiers[exp_num / 10 % quadruple_double_digit_modifiers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, quadruple_single_digit_modifiers[exp_num % 10]);
        if (filled >= 5 and std.mem.startsWith(u8, result[filled-5..], "milli"[0..])) {
            filled += strutils.strConcatLowOverhead(result, filled, "n");
        }
        filled += strutils.strConcatLowOverhead(result, filled, "illion");
    } else if (exp_num >= 100) {
        filled += strutils.strConcatLowOverhead(result, filled, triple_single_digit_modifiers[exp_num % 10]);
        filled += strutils.strConcatLowOverhead(result, filled, triple_double_digit_modifiers[exp_num / 10 % triple_double_digit_modifiers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, triple_digit_powers[exp_num / 100 % triple_digit_powers.len]);
    } else if (exp_num >= 10) {
        filled += strutils.strConcatLowOverhead(result, filled, double_digit_modifiers[exp_num % double_digit_modifiers.len]);
        filled += strutils.strConcatLowOverhead(result, filled, double_digit_powers[exp_num / 10 % double_digit_powers.len]);
    } else {
        filled += strutils.strConcatLowOverhead(result, filled, single_digit_powers[exp_num % single_digit_powers.len]);
    }
    return filled;
}

pub inline fn threeDigitStrToSmallInt(num : []const u8) !u10 {
    switch(num.len) {
        0 => { return error.SizeError; },
        1 => { return (num[0] - '0'); },
        2 => { return (num[0] - '0') * 10 + (num[1] - '0'); },
        else => {
            return (@as(u10, num[0]) - '0') * 100 + (@as(u10, num[1]) - '0') * 10 + (@as(u10, num[2]) - '0');
        }
    }
}

pub inline fn preGenerateThousandsArr(size: usize) !void {
    if (word_from_power_thousands_arr) |word_from_power_thousands_arr_binding| {
        if (word_from_power_thousands_arr_binding.len < size) {
            word_from_power_thousands_arr = try c_allocator.realloc(word_from_power_thousands_arr_binding, size);
        }
    } else {
        word_from_power_thousands_arr = try c_allocator.alloc(u10, size);
    }
}

pub fn printOutNum(num : []const u8) ![]u8 {
    var result : []u8 = undefined;
    const num_len = num.len;
    const thousands_arr_len = (num_len + 2) / 3;
    var thousands_arr = try page_allocator.alloc(u10, thousands_arr_len);
    defer page_allocator.free(thousands_arr);
    var i : usize = 0;
    var current_slice_len : usize = undefined;
    var string_is_zero : bool = true;
    var loop_counter : usize = 0;
    try preGenerateThousandsArr(thousandGroupings(thousands_arr_len - 1));
    while (loop_counter < thousands_arr_len) : (loop_counter += 1) {
        current_slice_len = 3;
        if (i == 0 and num_len % 3 != 0) {
            current_slice_len = num_len % 3;
        }
        const current_slice = num[i..i+current_slice_len];
        const current_thousand = try threeDigitStrToSmallInt(current_slice);
        thousands_arr[loop_counter] = current_thousand;
        string_is_zero = string_is_zero and (current_thousand == 0);
        i += current_slice_len;
    }
    if (string_is_zero == true) {
        result = try page_allocator.alloc(u8, bases[0].len);
        @memcpy(result[0..bases[0].len], bases[0]);
        return result;
    } else {
        result = try page_allocator.alloc(u8, thousands_arr_len * (max_word_size + 2));
    }
    var filled : usize = 0;
    var item_index : usize = 0;
    while (item_index < thousands_arr_len) : (item_index += 1) {
        const item = thousands_arr[item_index];
        if (item == 0) continue;
        filled += try injectUnderThousandNum(result, filled, item);
        filled += try wordFromPower(@as(u64, @truncate((thousands_arr_len - item_index - 1) * 3)), result[filled..filled+max_word_size]);
        if (item_index != thousands_arr_len - 1) {
            filled += strutils.strConcatLowOverhead(result, filled, ", ");
        } else {
            break;
        }
    }
    return result[0..filled];
}

pub inline fn secondsFromNanoseconds(nanoseconds: u64) f64 {
    return @as(f64, @floatFromInt(nanoseconds)) / 1000000000.0;
}

pub fn main() !void {
    const args = try std.process.argsAlloc(page_allocator);
    defer std.process.argsFree(page_allocator, args);
    const cwd = std.fs.cwd();
    if (args.len < 2) {
        return error.ArgLengthError;
    }
    const file = try cwd.readFileAlloc(page_allocator, args[1], std.math.maxInt(usize));
    defer page_allocator.free(file);
    var timer = try std.time.Timer.start();
    var start = timer.read();
    const buf = try printOutNum(file);
    defer page_allocator.free(buf);
    defer if (word_from_power_thousands_arr) |unwrap| {
            c_allocator.free(unwrap);
    };
    var end = timer.read();
    const num_len = file.len;
    const num_bits = std.math.ceil(std.math.log2(@as(f64, 10.0)) * @as(f64, @floatFromInt(num_len)));
    const highest_power = num_len - 1;
    const highest_word_power = highest_power - (highest_power % 3);
    const highest_cardinal = if (highest_word_power >= 3) (highest_word_power - 3) / 3 else 0;
    try stdout.print("Value of item is 10^{d} and a number of this length needs roughly {d} bits to represent (largest number word is 10^{d} or the cardinal sequence {d}, generated in {d} seconds)\n", .{highest_power, num_bits, highest_word_power, highest_cardinal, secondsFromNanoseconds(end - start)});
    try stdout.flush();
    start = timer.read();
    try stdout.writeAll(buf);
    try stdout.flush();
    end = timer.read();
    try stdout.print("\nPrinting the number took {d} seconds\n", .{secondsFromNanoseconds(end - start)});
    try stdout.flush();
}
