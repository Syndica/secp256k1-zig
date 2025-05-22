const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("secp256k1", .{});
    const translate_c = b.addTranslateC(.{
        .root_source_file = upstream.path("include/secp256k1_recovery.h"),
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("secp256k1", .{
        .root_source_file = translate_c.getOutput(),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    mod.addIncludePath(upstream.path("include"));

    const libsecp256k1 = b.addStaticLibrary(.{
        .name = "secp256k1",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    b.installArtifact(libsecp256k1);

    libsecp256k1.addIncludePath(upstream.path("include"));
    libsecp256k1.addCSourceFiles(.{
        .root = upstream.path(&.{}),
        .flags = FLAGS,
        .files = &.{
            "src/secp256k1.c",
            "src/precomputed_ecmult.c",
            "src/precomputed_ecmult_gen.c",
        },
    });
    mod.linkLibrary(libsecp256k1);
}

const FLAGS = &.{
    "-DENABLE_MODULE_RECOVERY",
    "-DENABLE_MODULE_ECDH",
};
