OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

all: $(BINDIR)count $(BINDIR)hello $(BINDIR)gfxdemo

$(BINDIR)count: count.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" count.asm bin/bin/count

$(BINDIR)hello: hello.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" hello.asm bin/bin/hello

$(BINDIR)gfxdemo: gfxdemo.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" gfxdemo.asm bin/bin/gfxdemo

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
