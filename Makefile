# makefile for KnightOS

# Common variables

# Set lang with `make [platform] LANG=[langauge]`
LANG=en_us
# Default packages: base castle threadlist unixcommon terminal demos
PACKAGES=base castle threadlist demos osrecv

# Paths
PACKAGEPATH=packages

ifeq ($(OS),Windows_NT)
ASPREFIX=
EMUPREFIX=
else
ASPREFIX=mono 
EMUPREFIX=wine 
endif
AS=$(ASPREFIX)build/sass.exe
EMU=$(EMUPREFIX)build/Wabbitemu.exe
INCLUDE=inc/;kernel/bin/;lang/$(LANG)/;kernel/inc/
ASFLAGS=--encoding "Windows-1252"
.DEFAULT_GOAL=TI84pSE

all:
	make TI73
	make TI83p
	make TI83pSE
	make TI84p
	make TI84pSE

TI73: PLATFORM := TI73
TI73: FAT := 17
TI73: PRIVEDGED := 1C
TI73: KEY := 02
TI73: UPGRADEEXT := 73u
TI73: directories userland

TI83p: PLATFORM := TI83p
TI83p: FAT := 17
TI83p: PRIVEDGED := 1C
TI83p: KEY := 04
TI83p: UPGRADEEXT := 8xu
TI83p: directories userland

TI83pSE: PLATFORM := TI83pSE
TI83pSE: FAT := 77
TI83pSE: PRIVEDGED := 7C
TI83pSE: KEY := 04
TI83pSE: UPGRADEEXT := 8xu
TI83pSE: directories userland

TI84p: PLATFORM := TI84p
TI84p: FAT := 37
TI84p: PRIVEDGED := 3C
TI84p: KEY := 0A
TI84p: UPGRADEEXT := 8xu
TI84p: directories userland

TI84pSE: PLATFORM := TI84pSE
TI84pSE: FAT := 77
TI84pSE: PRIVEDGED := 7C
TI84pSE: KEY := 0A
TI84pSE: UPGRADEEXT := 8xu
TI84pSE: directories userland

.PHONY: kernel

run: TI84pSE
	$(EMU) bin/TI84pSE/KnightOS-$(LANG).rom

kernel:
	cd kernel && make $(PLATFORM)

userland: kernel $(PACKAGES)
	cp kernel/bin/kernel-$(PLATFORM).rom bin/$(PLATFORM)/KnightOS-$(LANG).rom
	$(ASPREFIX)build/BuildFS.exe $(FAT) bin/$(PLATFORM)/KnightOS-$(LANG).rom temp
	rm -rf temp
	$(ASPREFIX)build/CreateUpgrade.exe $(PLATFORM) bin/$(PLATFORM)/KnightOS-$(LANG).rom build/$(KEY).key bin/$(PLATFORM)/KnightOS-$(LANG).$(UPGRADEEXT) 00 04 05 $(FAT) $(PRIVEDGED)

base:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" $(PACKAGEPATH)/base/init.asm temp/bin/init
	cp $(PACKAGEPATH)/base/inittab temp/etc/inittab

applib:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/applib/" $(PACKAGEPATH)/applib/applib.asm temp/lib/applib

castle:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" $(PACKAGEPATH)/castle/castle.asm temp/bin/castle
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" $(PACKAGEPATH)/castle/castle.config.asm temp/etc/castle.config

threadlist:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/threadlist/" $(PACKAGEPATH)/threadlist/threadlist.asm temp/bin/threadlist

demos: applib
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/count.asm temp/bin/count
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/hello.asm temp/bin/hello
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/gfxdemo.asm temp/bin/gfxdemo
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/todo.asm temp/bin/todo

osrecv:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/osrecv/" $(PACKAGEPATH)/osrecv/osrecv.asm temp/bin/osrecv

directories:
	mkdir -p bin/$(PLATFORM)
	rm -rf temp
	mkdir -p temp
	mkdir -p temp/bin
	mkdir -p temp/lib
	mkdir -p temp/etc
	mkdir -p temp/etc/man

clean:
	cd kernel && make clean
	rm -rf bin
	rm -rf temp
