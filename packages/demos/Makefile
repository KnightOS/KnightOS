OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/;../fx3dlib/

all: $(BINDIR)count $(BINDIR)hello $(BINDIR)gfxdemo

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

.PHONY: all clean
