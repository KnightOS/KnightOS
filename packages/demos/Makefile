OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/;../fx3dlib/

all: package

package: $(BINDIR)count $(BINDIR)hello $(BINDIR)gfxdemo
	kpack demos-0.1.0.pkg $(OUTDIR)

$(BINDIR)count: count.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/;$(DEPENDENCIES)" count.asm bin/bin/count

$(BINDIR)hello: hello.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/;$(DEPENDENCIES)" hello.asm bin/bin/hello

$(BINDIR)gfxdemo: gfxdemo.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/;$(DEPENDENCIES)" gfxdemo.asm bin/bin/gfxdemo

clean:
	rm -rf $(OUTDIR)
	rm -rf demos-0.1.0.pkg

install: package
	kpack -e -s demos-0.1.0.pkg $(PREFIX)

.PHONY: all clean
