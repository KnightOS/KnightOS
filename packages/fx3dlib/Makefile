OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/

all: $(LIBDIR)fx3d $(INCDIR)fx3dlib.inc

$(LIBDIR)fx3d: fx3dlib.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/fx3dlib/" fx3dlib.asm $(LIBDIR)fx3d

$(INCDIR)fx3dlib.inc:
	mkdir -p $(INCDIR)
	cp fx3dlib.inc $(INCDIR)fx3dlib.inc

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
