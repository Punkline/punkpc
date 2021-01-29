.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module small, 0x100
.if module.included == 0
  punkpc bcount, enum

  .macro small.__build, rlw
    .macro \rlw, va:vararg; small.__instr \rlw, \va; .endm
  .endm

  .macro small.__instr, rlw, d, a, m, va:vararg
    .purgem \rlw
    # temporarily purge instruction hook

    .ifnb \va; \rlw \d, \a, (\m)&31, \va;
      # run normal instruction if 4 or more args are given

    .else

      small.rot_bits = 0
      .ifc \rlw, rlwimi; small.rot_bits = 1;
      .else; .ifc \rlw, rlwimi.; small.rot_bits = 1; .endif; .endif
      # check if inserting or extracting

      .if \m
        .if (\m)&1
          bcount.zsigned \m
          .if bcount.sign
            bcount = 1 + bcount
          .endif
        .else;
          bcount.be \m
        .endif
        # bcount = number of bits to rotate mask left by

        .if small.rot_bits
          small.rot_mask = \m
          small.rot_bits = 32 - bcount
          # use mask and inverted bits if inserting

        .else
          small.rot_bits = bcount
          small.rot_mask = \m << bcount
          small.rot_mask = small.rot_mask | (\m >> ((32-bcount)&31))
          # use bits and rotated mask if extracting

        .endif
        small.rot_bits = small.rot_bits & 31
        \rlw \d, \a, small.rot_bits, small.rot_mask
        # invoke normal instruction with interpreted custom syntax

      .else
        .if small.rot_bits == 0
          li \d, 0
        .endif # if mask is null, and we're extracting a number, then just load '0' as an immediate
      .endif
    .endif
    small.__build \rlw
    # rebuild instruction hook

  .endm; .macro small.enable_insr_extr
    .if small.enable_insr_extr == 0
      small.enable_insr_extr = 1
      .irp rlw, rlwinm, rlwinm., rlwimi, rlwimi.
        small.__build \rlw
      .endr
    .endif
  .endm; .macro small.disable_insr_extr
    .if small.enable_insr_extr
      small.enable_insr_extr = 0
      .irp rlw, rlwinm, rlwinm., rlwimi, rlwimi.
        .purgem \rlw
      .endr
    .endif
  .endm; small.enable_insr_extr = 0; small.enable_insr_extr
.endif
