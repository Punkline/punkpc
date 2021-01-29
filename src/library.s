.ifndef punkpc.library.version; punkpc.library.version = 0; .endif;
.ifeq punkpc.library.version; punkpc.library.version = 1; module.included = 1
# - module information must be written manually like this, because module can't load itself

  .macro module.library, self, ext=".s", default:vararg
  # library objects create a shortcut to a subdir for including class modules

    .macro \self, va:vararg
    # This can be used to load class modules in a safe, efficient, and convenient way
    # Each given module name will check for the existence of a module version in this environment
    # - if it's found that the module already exists, it will be skipped over
    .ifb \va; .ifnb \default; \self \default; .endif
    .else
      .irp m, \va; .ifnb \m; module.included "\self", ".\m", ".version"
        .if module.included == 0; \self\().build_pathstr \m; .endif
        # if check is true, then include the file
        # - each module will copy its source literals to this assembler context
        # - the modules conditionally define their classes if their own module version isn't found

      .endif; .endr
    .endif
    .endm; .macro \self\().raw, va:vararg
      .irp args, \va; module.raw.build_args \self, \args; .endr
      # This variation invokes '.incbin' instead of '.include', for loading binary data
      #  Up to 3 comma-separated args may be provided by quoting them together in "double quotes"
      # - name   - the name of the file in the current '\self.subdir' to load
      # - offset - the byte offset in the binary file to start emitting from
      # - size   - the number of bytes to emit

    .endm; .macro \self\().module, m, version=1; module.included "\self", ".\m", ".version"
      .if module.included == 0; .irp vsn ".version"; \self\().\m\vsn = \version; .endr; .endif
      # This assigns the given version to the module if it doesn't exist yet
      # - the .module property can be checked on return in order to create a useful if-block
      # - defining the method in this if-block protects the class when it is .included manually

    .endm; .macro \self\().subdir, sub, ex; .purgem \self\().build_pathstr
    # Calling this will let us rebuild the path sub-directory used for reaching our module files
    # - if the module files use an extension besides ".s", then it may also be defined here

      .macro \self\().build_pathstr, str, s="\sub", e="\ex", lude="lude", args
        .inc\lude "\s\str\e" \args; .endm
      # The .purgem statement causes this to rebuild the path name used for reaching modules

    .endm; .macro \self\().build_pathstr; .endm
    # This dummy macro exists so that we can plug an initial path in with the '.subdir' method

    \self\().subdir \self\()/; \self\().library.included = 1
    # .lib.included allows the library file to check for the existence of this library object

  .endm; .macro module.included, __mdul_pfx, __mdul_mid, __mdul_suf=".version"
    .altmacro; module.included.alt \__mdul_pfx\__mdul_mid\__mdul_suf; .noaltmacro
    .if module.included; .if \__mdul_pfx\__mdul_mid\__mdul_suf == 0;
        module.included = 0; .endif; .endif
    # altmacro mode can avoid the need for using '\' in some cases of escaping literals
    # - this avoids an error when attempting to use a '\' in a .ifdef statement
    # - the argument names are given names that are unlikely to be confused with existing symbols

  .endm; .macro module.included.alt, __mdul_vsn; module.included = 0
    .ifdef __mdul_vsn; module.included = 1; .endif
    # if the given version property doesn't exist, then the 'module' flag is marked true
    # - this signals that it's safe to define the module

  .endm; .macro module.raw.build_args, self, file, va:vararg;
    .ifb \va; \self\().build_pathstr \file,,,"bin"
    .else; \self\().build_pathstr \file,,,"bin",", \va"; .endif
    # This passes the exploded argument tuple over to the path builder in 'self'
    # - the blanks (,,,) invoke default args on the path builder's end
    # - varargs must be given a comma, so the case of blank varargs is handled separately

  .endm
.endif
