const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_model = .native,
        },
    });
    const exe = b.addExecutable(.{
        .name = "bignum",
        .root_module = b.createModule(.{
            .root_source_file = b.path("bignum.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .code_model = .large,
        }),
    });
    b.installArtifact(exe);
}