const std = @import("std"); // works with version 0.15.1+
const bignum = @import("bignum");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const arena_allocator = std.heap.ArenaAllocator.init(allocator);

const bases = [_][]const u8 {
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
    "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
    "seventeen", "eighteen", "nineteen", "twenty", "twenty-one", "twenty-two", "twenty-three",
    "twenty-four", "twenty-five", "twenty-six", "twenty-seven", "twenty-eight", "twenty-nine",
    "thirty", "thirty-one", "thirty-two", "thirty-three", "thirty-four", "thirty-five",
    "thirty-six", "thirty-seven", "thirty-eight", "thirty-nine", "forty", "forty-one",
    "forty-two", "forty-three", "forty-four", "forty-five", "forty-six", "forty-seven",
    "forty-eight", "forty-nine", "fifty", "fifty-one", "fifty-two", "fifty-three",
    "fifty-four", "fifty-five", "fifty-six", "fifty-seven", "fifty-eight", "fifty-nine",
    "sixty", "sixty-one", "sixty-two", "sixty-three", "sixty-four", "sixty-five",
    "sixty-six", "sixty-seven", "sixty-eight", "sixty-nine", "seventy", "seventy-one",
    "seventy-two", "seventy-three", "seventy-four", "seventy-five", "seventy-six",
    "seventy-seven", "seventy-eight", "seventy-nine", "eighty", "eighty-one",
    "eighty-two", "eighty-three", "eighty-four", "eighty-five", "eighty-six",
    "eighty-seven", "eighty-eight", "eighty-nine", "ninety", "ninety-one",
    "ninety-two", "ninety-three", "ninety-four", "ninety-five", "ninety-six",
    "ninety-seven", "ninety-eight", "ninety-nine"
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

const SizeError = error {
    SizeError,
};

const BufferFullError = error {
    BufferFullError,
};

pub fn maxIn2DCharArr(comptime arr: anytype) usize {
    var result : usize = 0;
    for (arr) |item| {
        if (item.len > result) {
            result = item.len;
        }
    }
    return result;
}

const max_word_size : usize = 2048;

// pub fn strPushFormat(buffer: [] u8, filled: usize, comptime format: []const u8, items: anytype) !usize {
//     const count = std.fmt.count(format, items);
//     if (filled + count >= buffer.len) {
//         return error.BufferFullError;
//     }
//     @memmove(buffer[count..], buffer[0..buffer.len-count]);
//     _ = try std.fmt.bufPrint(buffer[0..count], format, items);
//     return count;
// }

pub fn injectUnderThousandNum(buffer: []u8, filled: usize, num: u10) !usize {
    if (num >= 100) {
        if (num % 100 != 0) {
            return try strConcatFormat(buffer, filled, "{s} hundred {s} ", .{bases[num / 100], bases[num % 100]});
        } else {
            return try strConcatFormat(buffer, filled, " {s} ", .{bases[num % 100]});
        }
    } else {
        return try strConcatFormat(buffer, filled, "{s} ", .{bases[num]});
    }
}

pub fn strConcatFormat(buffer: []u8, filled: usize, comptime format : []const u8, items: anytype) !usize {
    const count = std.fmt.count(format, items);
    if (filled + count >= buffer.len) {
        return error.BufferFullError;
    }
    _ = try std.fmt.bufPrint(buffer[filled..filled+count], format, items);
    return count;
}

pub fn thousandGroupings(num: anytype) @TypeOf(num) {
    return @as(@TypeOf(num), @intFromFloat(std.math.ceil(std.math.log10(@as(f128, @floatFromInt(num)))))) / 3 + 1;
}

pub fn wordFromPower(num: u64) ![]u8 {
    if (num < 3) {
        const result = try allocator.alloc(u8, 0);
        return result;
    }
    const exp_num = num / 3 - 1;
    var result = try allocator.alloc(u8, max_word_size);
    @memset(result, 0);
    var filled : usize = 0;
    if (exp_num >= 100000) {
        var exp_calc = exp_num;
        var thousands_list = try std.ArrayList(u10).initCapacity(allocator, thousandGroupings(exp_num));
        defer thousands_list.deinit(allocator);
        while (exp_calc > 0) {
            const current = @as(u10, @truncate(exp_calc % 1000));
            exp_calc /= 1000;
            try thousands_list.append(allocator, current);
        }
        _ = try reverseArrayList(&thousands_list);
        for (thousands_list.items, 0..) |item, milli_count_subtractor| {
            filled += try strConcatFormat(result, filled, "{s}", .{quadruple_triple_digit_modifiers[item / 100 % 10]});
            filled += try strConcatFormat(result, filled, "{s}", .{triple_double_digit_modifiers[item / 10 % 10]});
            filled += try strConcatFormat(result, filled, "{s}", .{triple_single_digit_modifiers[item % 10]});
            const milli_count = thousands_list.items.len - milli_count_subtractor - 1;
            for (0..milli_count) |_| {
                filled += try strConcatFormat(result, filled, "{s}", .{"milli"});
            }
        }
        if (filled >= 5 and std.mem.startsWith(u8, result[filled-5..], "milli"[0..])) {
            filled += try strConcatFormat(result, filled, "{s}", .{"n"});
        }
        if (filled >= 1 and !std.mem.startsWith(u8, result[filled-1..], "i"[0..])) {
            filled += try strConcatFormat(result, filled, "{s}", .{"i"});
        }
        filled += try strConcatFormat(result, filled, "{s}", .{"llion"});
    } else if (exp_num >= 10000) {
        filled += try strConcatFormat(result, filled, "{s}", .{quintuple_digit_modifiers[exp_num / 1000 % quintuple_digit_powers.len]});
        filled += try strConcatFormat(result, filled, "{s}", .{quintuple_digit_powers[exp_num / 10000 % quintuple_digit_powers.len]});
        filled += try strConcatFormat(result, filled, "{s}", .{"milli"});
        filled += try strConcatFormat(result, filled, "{s}", .{quintuple_triple_digit_modifiers[exp_num / 100 % quintuple_triple_digit_modifiers.len]});
        filled += try strConcatFormat(result, filled, "{s}", .{quintuple_double_digit_modifiers[exp_num / 10 % quintuple_double_digit_modifiers.len]});
        filled += try strConcatFormat(result, filled, "{s}", .{quintuple_single_digit_modifiers[exp_num % 10]});
        if (filled >= 5) {
            if (std.mem.startsWith(u8, result[filled-5..], "milli"[0..])) {
                filled += try strConcatFormat(result, filled, "{s}", .{"n"});
            }
        }
        filled += try strConcatFormat(result, filled, "{s}", .{"illion"});
    } else if (exp_num >= 1000) {
        filled += try strConcatFormat(result, filled, "{s}", .{quadruple_digit_powers[exp_num / 1000 % quadruple_digit_powers.len]});
        filled += try strConcatFormat(result, filled, "{s}", .{quadruple_triple_digit_modifiers[exp_num / 100 % quadruple_triple_digit_modifiers.len]});
        filled += try strConcatFormat(result, filled, "{s}", .{quadruple_double_digit_modifiers[exp_num / 10 % quadruple_double_digit_modifiers.len]});
        filled += try strConcatFormat(result, filled, "{s}", .{quadruple_single_digit_modifiers[exp_num % 10]});
        if (filled >= 5) {
            if (std.mem.startsWith(u8, result[filled-5..], "milli"[0..])) {
                filled += try strConcatFormat(result, filled, "{s}", .{"n"});
            }
        }
        filled += try strConcatFormat(result, filled, "{s}", .{"illion"});
    } else if (exp_num >= 100) {
        filled += try strConcatFormat(result, filled, "{s}", .{triple_single_digit_modifiers[exp_num % 10]});
        filled += try strConcatFormat(result, filled, "{s}", .{triple_double_digit_modifiers[exp_num / 10 % triple_double_digit_modifiers.len]});
        filled += try strConcatFormat(result, filled, "{s}", .{triple_digit_powers[exp_num / 100 % triple_digit_powers.len]});
    } else if (exp_num >= 10) {
        filled += try strConcatFormat(result, filled, "{s}{s}", .{double_digit_modifiers[exp_num % double_digit_modifiers.len], double_digit_powers[exp_num / 10 % double_digit_powers.len]});
    } else {
        filled += try strConcatFormat(result, filled, "{s}", .{single_digit_powers[exp_num % single_digit_powers.len]});
    }
    result = try allocator.realloc(result, filled);
    return result;
}

pub fn reverseArrayList(list: *std.ArrayList(u10)) !void {
    for (0..list.items.len / 2) |i| {
        const swap = list.items[i];
        list.items[i] = list.items[list.items.len - i - 1];
        list.items[list.items.len - i - 1] = swap;
    }
}

pub fn printOutNum(num : std.math.big.int.Managed) ![]u8 {
    var thousands_list : std.ArrayList(u10) = undefined;
    var result : []u8 = undefined;
    var res : std.math.big.int.Managed = try num.clone();
    var thousand_managed = try std.math.big.int.Managed.initSet(allocator, 1000);
    const num_str = try num.toString(allocator, 10, std.fmt.Case.lower);
    const num_len = num_str.len;
    if (num.eqlZero() == true) {
        result = try allocator.alloc(u8, bases[0].len);
        @memcpy(result[0..bases[0].len], bases[0]);
        return result;
    } else {
        thousands_list = try std.ArrayList(u10).initCapacity(allocator, num_len / 3 + 1);
        result = try allocator.alloc(u8, thousands_list.capacity * max_word_size);
        @memset(result, 0);
    }
    var dummy_remainder = try std.math.big.int.Managed.init(allocator);
    while (res.eqlZero() == false) : (try res.divFloor(&dummy_remainder, &res, &thousand_managed)) {
        var quotient = try std.math.big.int.Managed.init(allocator);
        var remainder = try std.math.big.int.Managed.init(allocator);
        defer quotient.deinit();
        defer remainder.deinit();
        try std.math.big.int.Managed.divFloor(&quotient, &remainder, &res, &thousand_managed);
        const printVal = try remainder.toInt(u10);
        try thousands_list.append(allocator, printVal);
    }
    var filled : usize = 0;
    const items = thousands_list.items;
    var item_index = items.len - 1;
    while (item_index >= 0) : (item_index -= 1) {
        const item = items[item_index];
        if (item == 0) continue;
        const currentWord = try wordFromPower(@as(u64, @truncate(item_index * 3)));
        defer allocator.free(currentWord);
        filled += try injectUnderThousandNum(result[0..], filled, item);
        filled += try strConcatFormat(result, filled, "{s}", .{currentWord});
        if (item_index != 0) {
            filled += try strConcatFormat(result, filled, "{s}", .{", "});
        } else {
            break;
        }
    }
    var result_size : usize = undefined;
    for (result, 0..) |char, i| {
        if (char == 0) {
            result_size = i;
            break;
        }
    }
    result = try allocator.realloc(result, result_size);
    defer {
        res.deinit();
        allocator.free(num_str);
        thousands_list.deinit(allocator);
        dummy_remainder.deinit();
        thousand_managed.deinit();
    }
    return result;
}

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    const cwd = std.fs.cwd();
    const file = try cwd.readFileAlloc(allocator, "./bignumber.txt", std.math.maxInt(usize));
    var my_num = try std.math.big.int.Managed.init(allocator);
    try my_num.setString(10, file);
    const buf = printOutNum(my_num) catch {
        std.debug.print("Number is too big!\n", .{});
        return;
    };
    const my_num_str = try my_num.toString(allocator, 10, std.fmt.Case.lower);
    const highest_power = my_num_str.len - 1;
    const roughly_needed_bits = std.math.ceil(@as(f64, @floatFromInt(highest_power + 1)) * std.math.log2(@as(f64, 10.0))) + 1;
    const highest_word_power = highest_power - (highest_power % 3);
    const highest_cardinal = (highest_word_power - 3) / 3;
    std.debug.print("Value of item is 10^{d} and needs roughly {d} bits to represent (largest number word is 10^{d} or the cardinal sequence {d})\n", .{highest_power, roughly_needed_bits, highest_word_power, highest_cardinal});
    std.debug.print("{s}\n", .{buf});
    // Add testing here if needed.
    // const buf = try wordFromPower(198473298471);
    // std.debug.print("{d} : {s}\n", .{198473298471, buf});
    defer {
        my_num.deinit();
        std.process.argsFree(allocator, args);
        allocator.free(file);
        allocator.free(buf);
        allocator.free(my_num_str);
        const leaky = gpa.deinit();
        if (leaky == std.heap.Check.leak) {
            std.debug.print("AAAA leak\n", .{});
        }
    }
}
