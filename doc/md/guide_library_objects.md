# Creating New Library Objects

Modules accessed by a library object like `punkpc` ...

- ... will not attempt to `.include` any modules already in the GAS environment
- ... can be configured to use a different target subdirectory
- ... can be configured to use a different file extension


You may create new importable class modules that can be added into punkpc or a custom library in your own implementations using the `library` module.


## PunkPC Library Object

To make a library object, you must make a main file for `.include` statements to access.

Here is the file used for punkpc, as an example to start with:

```YAML
# --- Main file

.ifndef punkpc.library.included

  .ifndef punkpc.module.version

    .include "punkpc/library.s"
  .endif

  module.library punkpc, ".s", ppc
.endif

punkpc.subdir "punkpc/", ".s"

```

- `punkpc/library.s` is the default location of the class module responsible for creating library objects.
  - any GAS environment that has a library object in it is capable of using this to create new modules, or new library objects for different file directories

- `punkpc.module.version` is a non-0 version number for 'punkpc' signifying that the punkpc `library.s` module is already included.
- `module.library` is a method used to generate a library object
  - in this case `punkpc`, which uses `.s` file extensions and has the default argument `ppc` if none are given to it when invoked.

- `punkpc.library.included` is a symbol defined simply to signify that the `punkpc` library object exists somewhere in the GAS environment.
- `punkpc.subdir` is a method of the punkpc library object that can be used to change the subdirectory used in `.include` statements made by the library object.

By including the above file in an include statement `.include "punkpc.s"` -- we cause the library module to create a new library object that accesses the folder called `punkpc/` for importing `*.s` files. If punkpc has already been included, then the `.ifdef` block will prevent it from being loaded multiple times.

Each file can be referenced as part of a list of comma-separated arguments that have no extension or path.

---
All files imported by the punkpc library object are formatted like so:

```YAML
# --- A Class Module

.ifndef punkpc.library.included
  .include "punkpc.s"
.endif

punkpc.module myModule, 1  # --- Name, (optional version number)
.if module.included == 0


  # --- a new punkpc module called 'myModule' goes here


.endif
```

- `punkpc.library.included` is checked here at the module level to ensure that the library object is available in the GAS environment
  - this enables the module to be loaded without the library object and still afford similar protections through `.if` blocks

- `punkpc.module` is a method of punkpc that instantiates a non-0 version number for this module
  - this helps inform the environment about whether or not this module is already loaded
    - `1` will be used by default if none is given, to qualify as non-0

- `module.included` is a volatile return bool that can be used to inform a `.if` block that protects your module contents.

---

The `.if` block generated from the returned `module.included` flag will protect the contents of the class module from being defined multiple times.

In that sense, class modules are nothing more than **protective wrappers** for writing constructor macros that create and manage a designed class of object.


## Custom Library Object

Adding a custom library is then just a matter of invoking `punkpc/library.s` to set up a new library object with a different name, subdirectory, and paramters.

Here is an example that defines an object called **myLib**, and uses the `myLib/` subdirectory:

```YAML
.ifndef myLib.library.included
  .ifndef punkpc.module.version; .include "punkpc.s"; .endif
  # we need the punkpc library module, which we can get from "punkpc.s"

  module.library myLib, ".s"  # --- name of the library, 'myLib'
.endif

myLib.subdir "myLib/", ".s"  # --- library subdir and implied file extension
```


... and the corresponding module template:

```YAML
.ifndef myLib.library.included; .include "myLib.s"; .endif

myLib.module  myModule # --- name the module here
.if module.included == 0


  # --- write module contents here


.endif
```

NOTE:
> The keyword used to import a module will be its file name. <br />
> 'myModule' is the internal name given to this module -- not necessarily the file name

---

A module written inside of module block like the above may contain ...


- class definitions, using punkpc modules like `obj`
- anything that needs prerequisites from `punkpc` or other `myLib` modules
- instructions
- data structures
- any number of symbol or macro definitions, and/or symbol assignments
- etc

Attempting to load a module multiple times will only work the first time, so accounting for prerequisites in any module is as simple as heading it with a library object statement:

```YAML
myLib   myPrereq, myFavoriteTool
punkpc  stack, obj, items

# --- if any of these prereqs don't exist in the environment, they are loaded
```


## Raw Binary Libraries

If you use the `.raw` method of any library object, you can load a file as raw binary instead of interpreted source literals for GAS. This is useful if you want to include instructions or data that's been assembled or compiled from another source.

```YAML
.ifndef myFiles.library.included
  .ifndef punkpc.module.version; .include "punkpc.s"; .endif;  

  module.library  myFiles  # --- a library for emitting binary files
.endif

myFiles.subdir "myFiles/"  # --- no file extension needs to be given
```
Omitting the file extension will require the files to be explicitly named when calling the library object:

```YAML
myFiles.raw  functions.bin
```

No source literals are interpreted when loading a file with `.raw`, so you don't need to create any special blocks for protecting your modules. You can however protect the call to `.raw` if you want to make it so that a binary is only loaded once in an assembler environment.

---

If you provide your `.raw` filename args in quotes, you may also provide an additional pair of arguments that define the starting and ending byte offsets you want to include in the assembly.

```YAML
myFiles.raw  "functions.bin, 0x380, 0x460", "functions.bin, 0x800, 0x1040"
```

The above includes just the sections at `0x380 ... 0x460` and `0x800 ... 0x1040` in the file `functions.bin`.
