OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/;

all: package
	
package: $(BINDIR)phoenix
	kpack phoenix-0.1.0.pkg $(OUTDIR)

$(BINDIR)phoenix: *.asm *.i
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/phoenix/;$(DEPENDENCIES)" phoenix.asm $(BINDIR)phoenix

clean:
	rm -rf $(OUTDIR)
	rm -rf phoenix-0.1.0.pkg

install: package
	kpack -e -s phoenix-0.1.0.pkg $(PREFIX)

.PHONY: all clean
