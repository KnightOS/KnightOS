OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/
ETCDIR:=$(OUTDIR)etc/

all: package
	
package: $(LIBDIR)core $(INCDIR)corelib.inc $(ETCDIR)extensions $(ETCDIR)magic
	kpack corelib-0.1.0.pkg $(OUTDIR)

$(LIBDIR)core: corelib.asm characters.asm errors.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/corelib/" corelib.asm $(LIBDIR)core

$(INCDIR)corelib.inc:
	mkdir -p $(INCDIR)
	cp corelib.inc $(INCDIR)corelib.inc

$(ETCDIR)extensions:
	# This would just be an empty file by default, but we're testing things
	mkdir -p $(ETCDIR)
	cp extensions $(ETCDIR)extensions

$(ETCDIR)magic:
	# This is just an empty file by default
	mkdir -p $(ETCDIR)
	touch $(ETCDIR)magic

clean:
	rm -rf $(OUTDIR)
	rm -rf corelib-0.1.0.pkg

install: package
	kpack -e -s corelib-0.1.0.pkg $(PREFIX)

.PHONY: all clean
