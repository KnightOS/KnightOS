# makefile for KnightOS

# Common variables

# Set lang with `make [platform] LANG=[langauge]`
LANG=en_us
# Default packages: base castle threadlist unixcommon terminal demos manfiles
PACKAGES=base castle threadlist unixcommon terminal demos manfiles

# Paths
SOURCEPATH=src
PACKAGEPATH=$(SOURCEPATH)/packages

ifeq ($(OS),Windows_NT)
ASPREFIX=
EMUPREFIX=
else
ASPREFIX=mono 
EMUPREFIX=wine 
endif
AS=$(ASPREFIX)build/sass.exe
EMU=$(EMUPREFIX)build/Wabbitemu.exe
INCLUDE=inc/;kernel/bin/;kernel/inc/;lang/$(LANG)/
ASFLAGS=--encoding "Windows-1252"
.DEFAULT_GOAL=TI84pSE

all:
	make TI73
	make TI83p
	make TI83pSE
	make TI84p
	make TI84pSE

run: TI84pSE
	$(EMU) bin/$(PLATFORM)/KnightOS_$(LANG).rom

TI73: PLATFORM := TI73
TI73: directories userland

TI83p: PLATFORM := TI83p
TI83p: directories userland

TI83pSE: PLATFORM := TI83pSE
TI83pSE: directories userland

TI84p: PLATFORM := TI84p
TI84p: directories userland

TI84pSE: PLATFORM := TI84pSE
TI84pSE: directories userland

.PHONY: kernel

kernel:
	cd kernel && make $(PLATFORM)

userland: kernel $(PACKAGES)
	cp kernel/bin/kernel-$(PLATFORM).rom bin/$(PLATFORM)/KnightOS-$(LANG).rom

base:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" $(PACKAGEPATH)/base/init.asm temp/bin/init

libtext:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/libtext/" $(PACKAGEPATH)/libtext/libtext.asm temp/lib/libtext

stdio:
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/stdio/" $(PACKAGEPATH)/stdio/stdio.asm temp/lib/stdio

applib: libtext
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/applib/" $(PACKAGEPATH)/applib/applib.asm temp/lib/applib

castle: libtext
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" $(PACKAGEPATH)/castle/castle.asm temp/bin/castle
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" $(PACKAGEPATH)/castle/castle.config.asm temp/etc/castle.config

threadlist: libtext
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/threadlist/" $(PACKAGEPATH)/threadlist/threadlist.asm temp/bin/threadlist

unixcommon: stdio
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/unixcommon/" $(PACKAGEPATH)/unixcommon/clear.asm temp/bin/clear
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/unixcommon/" $(PACKAGEPATH)/unixcommon/echo.asm temp/bin/echo
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/unixcommon/" $(PACKAGEPATH)/unixcommon/man.asm temp/bin/man
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/unixcommon/" $(PACKAGEPATH)/unixcommon/reboot.asm temp/bin/reboot
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/unixcommon/" $(PACKAGEPATH)/unixcommon/shutdown.asm temp/bin/shutdown
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/unixcommon/" $(PACKAGEPATH)/unixcommon/version.asm temp/bin/version

terminal: stdio applib
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/terminal/" $(PACKAGEPATH)/terminal/terminal.asm temp/bin/terminal

demos: applib stdio
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/count.asm temp/bin/count
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/demo.asm temp/bin/demo
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/gfxdemo.asm temp/bin/gfxdemo
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/hello.asm temp/bin/hello
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/todo.asm temp/bin/todo
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/demos/" $(PACKAGEPATH)/demos/userhello.asm temp/bin/userhello

manfiles:
	cp $(PACKAGEPATH)/manfiles/* temp/etc/man

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