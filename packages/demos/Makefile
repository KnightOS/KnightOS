OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
APPDIR:=$(OUTDIR)var/applications/

DEPENDENCIES=../corelib/;../fx3dlib/

all: package

package: $(BINDIR)count $(BINDIR)hello $(BINDIR)gfxdemo $(BINDIR)pixelMadness
	kpack demos-0.1.0.pkg $(OUTDIR)

$(BINDIR)count: count.asm
	mkdir -p $(BINDIR)
	mkdir -p $(APPDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/;$(DEPENDENCIES)" count.asm $(BINDIR)count
	cp count.app $(APPDIR)

$(BINDIR)hello: hello.asm
	mkdir -p $(BINDIR)
	mkdir -p $(APPDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/;$(DEPENDENCIES)" hello.asm $(BINDIR)hello
	cp hello.app $(APPDIR)

$(BINDIR)gfxdemo: gfxdemo.asm
	mkdir -p $(BINDIR)
	mkdir -p $(APPDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/;$(DEPENDENCIES)" gfxdemo.asm $(BINDIR)gfxdemo
	cp gfxdemo.app $(APPDIR)

$(BINDIR)pixelMadness: pixelMadness/*.asm
	mkdir -p $(BINDIR)
	mkdir -p $(APPDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/;$(DEPENDENCIES);pixelMadness/" pixelMadness/pixelmad.asm $(BINDIR)pixelmad
	cp pixelmad.app $(APPDIR)

clean:
	rm -rf $(OUTDIR)
	rm -rf demos-0.1.0.pkg

install: package
	kpack -e -s demos-0.1.0.pkg $(PREFIX)

.PHONY: all clean
