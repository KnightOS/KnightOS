OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/

all: package

package: $(LIBDIR)fx3d $(INCDIR)fx3dlib.inc
	kpack fx3dlib-0.1.0.pkg $(OUTDIR)

$(LIBDIR)fx3d: fx3dlib.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/fx3dlib/" fx3dlib.asm $(LIBDIR)fx3d

$(INCDIR)fx3dlib.inc:
	mkdir -p $(INCDIR)
	cp fx3dlib.inc $(INCDIR)fx3dlib.inc

clean:
	rm -rf $(OUTDIR)
	rm -rf fx3dlib-0.1.0.pkg

install: package
	kpack -e fx3dlib-0.1.0.pkg $(PREFIX)

.PHONY: all clean
