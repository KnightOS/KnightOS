all:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" castle.asm $(OUTDIR)/bin/castle
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" castle.config.asm $(OUTDIR)/castle.config

.PHONY: all
