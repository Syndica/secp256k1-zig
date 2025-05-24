const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const pic = b.option(bool, "pic", "Build library with PIC enabled");

    const upstream = b.dependency("secp256k1", .{});
    const translate_c = b.addTranslateC(.{
        .root_source_file = upstream.path("include/secp256k1_recovery.h"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "secp256k1",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .pic = pic,
        }),
        .linkage = .static,
    });
    b.installArtifact(lib);

    lib.linkLibC();
    lib.addIncludePath(upstream.path("include"));
    lib.addCSourceFiles(.{
        .root = upstream.path("."),
        .flags = FLAGS,
        .files = &.{
            "src/secp256k1.c",
            "src/precomputed_ecmult.c",
            "src/precomputed_ecmult_gen.c",
        },
    });

    const mod = b.addModule("secp256k1", .{
        .root_source_file = translate_c.getOutput(),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.linkLibrary(lib);
}

const FLAGS = &.{
    "-DENABLE_MODULE_RECOVERY",
    "-DENABLE_MODULE_ECDH",
};
