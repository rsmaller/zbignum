const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_model = .native,
        },
    });
    const bignumexe = b.addExecutable(.{
        .name = "bignum",
        .root_module = b.createModule(.{
            .root_source_file = b.path("bignum.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .code_model = .large,
        }),
    });
    const filegenexe = b.addExecutable(.{
        .name = "filegen",
        .root_module = b.createModule(.{
            .root_source_file = b.path("filegen.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .code_model = .large,
        }),
    });
    const wordfrompowerexe = b.addExecutable(.{
        .name = "wordfrompower",
        .root_module = b.createModule(.{
            .root_source_file = b.path("wordfrompower.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .code_model = .large,
        }),
    });
    wordfrompowerexe.linkLibC();
    b.installArtifact(wordfrompowerexe);
    filegenexe.linkLibC();
    b.installArtifact(filegenexe);
    bignumexe.linkLibC();
    b.installArtifact(bignumexe);
}