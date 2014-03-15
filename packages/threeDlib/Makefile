OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/

all: $(LIBDIR)threeD

$(LIBDIR)threeD: threeDlib.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/threeDlib/" threeDlib.asm $(LIBDIR)threeD

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
