const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_model = .native,
        },
    });
    const exe = b.addExecutable(.{
        .name = "filegen",
        .root_module = b.createModule(.{
            .root_source_file = b.path("filegen.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .code_model = .large,
        }),
    });
    exe.linkLibC();
    b.installArtifact(exe);
}