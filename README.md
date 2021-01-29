# punkpc

Punkpc is a collection of several loose experiments in GNU Assembler that assist in writing small binaries without relying on a linker or a compiler for high level features. It is intended for use with the PowerPC instruction set, which can exploit the `blrl` instruction to create in-line data tables that are detected relative to the program counter at runtime, and require no formal `.data` section in the assembly to access.

## About

I started this project after exploring the kind of utility that could be squeezed out of basic symbol and macro primitives in GAS. It provides in-assembler tools that are useful for writing injection code, function libraries, and small files with just `as.exe`.

Some of the modules offer convenient tweaks and extensions to the PowerPC language. They are all collected under the module called `ppc`:

![example use of the 'ppc' module][img_ppc]


Other modules provide 'classes' in GAS that can instantiate objects for use in the assembler environment.

Strings can be accessed with the `str` module. These objects allow for scalar literal memory to be stored, appended, and emitted elsewhere in the assembly program as part of a statement:

![example use of the 'str' module][img_str]


Stacks can be accessed with the `stack` module. They allow for scalar integer memory to be stored, appended, and accessed through a scalar variable, or through discretely named symbols, directly.

Lists from the `list` module are an extended version of stacks that include features for iterating through a stack of integer values, or reading/writing to them more easily with random access:

![example use of the 'list' module][img_list]

- For a full list of the provided modules, see the extra readme in the [doc directory][doc].



## Installation

Simply copy the contents of the [.include directory][inc] into your working `as.exe` directory.

- alternatively, copy them into a place that is accessed by the `-I` [command][icommand], for include directories.



## Usage

Use the `.include` directive to load **"punkpc.s"** (in quotes, all lowercase):

```
.include "punkpc.s"
```


This gives you access to the `punkpc` library object, which you can invoke it to import modules:

```
punkpc str, list, data
```

Each 'module' argument `*` corresponds with a `*.s` file in the library object's designated folder. For punkpc, this is the `punkpc/` folder. You may adjust this as needed by your assembler environment.


## More Info

- See the [doc directory][doc] for examples and documentation of various punkpc class modules
- See the [src directory][src] for commented source and scratch notes

#### Guides:

- [Creating New Library Objects][guide_library_objects]

[doc]: /doc/
[src]: /src/
[inc]: /.include/

[img_ppc]:  /doc/img/readme_main_ppc.png
[img_str]:  /doc/img/readme_main_str.png
[img_list]: /doc/img/readme_main_list.png

[guide_library_objects]: /doc/md/guide_library_objects.md

[icommand]: https://sourceware.org/binutils/docs/as/Invoking.html#Invoking
