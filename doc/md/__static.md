## Guides
- [Creating New Library Objects](/doc/md/guide_library_objects.md)
>toc


## Modules
Documentation links use the following emojis: <br />
[:pencil2:](/src) = ***commented source***, with attribute information <br />
[:alembic:](/doc/s/examples) = ***example usage***, with guiding comments <br />
[:boom:](/doc/s/exploded_lines) = ***exploded lines***, uncommented

Some modules use other modules as dependencies. Loading them will load the dependencies alongside the module automatically, as required.

A :heavy_plus_sign: sign is used to show these extra inclusions.

Note that -- when using the `punkpc` library object to include modules (like each module does, internally) -- a `.include` statement is only called if the file is not already in the GAS environment. Because of this, including multiple modules that have a common prerequisite will have faster load times because the prereq only needs to be loaded once between them all.

---
>toc :
