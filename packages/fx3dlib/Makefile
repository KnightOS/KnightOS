OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/

all: $(LIBDIR)fx3d

$(LIBDIR)fx3d: fx3dlib.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/fx3dlib/" fx3dlib.asm $(LIBDIR)fx3d

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
