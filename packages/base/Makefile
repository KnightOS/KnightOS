all:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" init.asm $(OUTDIR)/bin/init
	cp inittab $(OUTDIR)/etc/inittab

.PHONY: all
