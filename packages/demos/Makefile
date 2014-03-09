all:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" count.asm $(OUTDIR)/bin/count
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" hello.asm $(OUTDIR)/bin/hello
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" gfxdemo.asm $(OUTDIR)/bin/gfxdemo
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" todo.asm $(OUTDIR)/bin/todo

.PHONY: all
