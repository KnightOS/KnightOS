OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/
ETCDIR:=$(OUTDIR)etc/

all: $(LIBDIR)core $(INCDIR)corelib.inc $(ETCDIR)extensions $(ETCDIR)magic

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

.PHONY: all clean
