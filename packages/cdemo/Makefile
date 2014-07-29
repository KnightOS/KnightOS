OUTDIR:=bin/
WORKINGDIR:=temp/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

all: $(BINDIR)cdemo

$(BINDIR)cdemo: $(WORKINGDIR)main.ihx
	mkdir -p $(BINDIR)

$(WORKINGDIR)main.ihx: main.c
	mkdir -p $(WORKINGDIR)
	sdcc -mz80 -I$(KERNEL)include/ -I./ --std-c99 --no-std-crt0 -o $(WORKINGDIR)main.ihx main.c

clean:
	rm -rf $(OUTDIR)
	rm -rf $(WORKINGDIR)

.PHONY: all clean
