# Kaitai scripts

This directory contains Kaitai Struct scripts (`.ksy`) which can then be used to generate
utilities in multiple programming languages.

To compile:

```
ksc --target python --outdir python smart.ksy
ksc --target python --outdir python smartv3.ksy
ksc --target python --outdir python mwp.ksy
ksc --target python --outdir python smart_project.ksy
ksc --target python --outdir python microwin_project.ksy
```

Or just do it all at once:

```
ksc --target python --outdir python smart.ksy smartv3.ksy mwp.ksy smart_project.ksy microwin_project.ksy
```

