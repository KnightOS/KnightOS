# makefile for KnightOS

# Common variables

# Set lang with `make [platform] LANG=[langauge]`
LANG=en_us

# Package configuration
#
# To manually specify packages to build, uncomment this: 
# PACKAGES=applib base castle threadlist demos osrecv
#
# Or to automatically build all packages, uncomment this:
PACKAGES=$(wildcard packages/*)
# End config.

PACKBUF=$(patsubst %, %.package, $(PACKAGES))

# Paths
PACKAGEPATH=packages
# Where packages are placed relative to the top directory
PKGREL=../../

ifeq ($(OS),Windows_NT)
ASPREFIX=
EMUPREFIX=
else
ASPREFIX=mono 
EMUPREFIX=wine 
endif

AS=$(ASPREFIX)kernel/build/sass.exe
EMU=$(EMUPREFIX)kernel/build/Wabbitemu.exe
INCLUDE=inc/;kernel/bin/;lang/$(LANG)/
ASFLAGS=--encoding "Windows-1252"
.DEFAULT_GOAL=TI84pSE

PACKAGE_AS=$(ASPREFIX)$(PKGREL)kernel/build/sass.exe
PACKAGE_INCLUDE=$(PKGREL)inc/;$(PKGREL)lang/$(LANG)/;$(PKGREL)kernel/bin/;

all:
	make TI73
	make TI83p
	make TI83pSE
	make TI84p
	make TI84pSE
	make TI84pCSE

TI73: PLATFORM := TI73
TI73: FAT := 17
TI73: PRIVEDGED := 1C
TI73: KEY := 02
TI73: UPGRADEEXT := 73u
TI73: userland

TI83p: PLATFORM := TI83p
TI83p: FAT := 17
TI83p: PRIVEDGED := 1C
TI83p: KEY := 04
TI83p: UPGRADEEXT := 8xu
TI83p: userland

TI83pSE: PLATFORM := TI83pSE
TI83pSE: FAT := 77
TI83pSE: PRIVEDGED := 7C
TI83pSE: KEY := 04
TI83pSE: UPGRADEEXT := 8xu
TI83pSE: userland

TI84p: PLATFORM := TI84p
TI84p: FAT := 37
TI84p: PRIVEDGED := 3C
TI84p: KEY := 0A
TI84p: UPGRADEEXT := 8xu
TI84p: userland

TI84pSE: PLATFORM := TI84pSE
TI84pSE: FAT := 77
TI84pSE: PRIVEDGED := 7C
TI84pSE: KEY := 0A
TI84pSE: UPGRADEEXT := 8xu
TI84pSE: userland

TI84pCSE: PLATFORM := TI84pCSE
TI84pCSE: FAT := F7
TI84pCSE: PRIVEDGED := FC
TI84pCSE: KEY := 0F
TI84pCSE: UPGRADEEXT := 8cu
TI84pCSE: userland

.PHONY: kernel

run: TI84pSE
	$(EMU) bin/TI84pSE/KnightOS-$(LANG).rom

runcolor: TI84pCSE
	$(EMU) bin/TI84pCSE/KnightOS-$(LANG).rom

kernel:
	cd kernel && make $(PLATFORM)

userland: kernel directories buildpkgs license
	cp kernel/bin/kernel-$(PLATFORM).rom bin/$(PLATFORM)/KnightOS-$(LANG).rom
	$(ASPREFIX)kernel/build/BuildFS.exe $(FAT) bin/$(PLATFORM)/KnightOS-$(LANG).rom temp
ifndef savemockfs
	rm -rf temp
endif
	$(ASPREFIX)kernel/build/CreateUpgrade.exe $(PLATFORM) bin/$(PLATFORM)/KnightOS-$(LANG).rom kernel/build/$(KEY).key \
			bin/$(PLATFORM)/KnightOS-$(LANG).$(UPGRADEEXT) 00 01 02 03 04 05 $(FAT) $(PRIVEDGED)

%.package: %
	echo $(TOPDIR)
	echo $? $<
	cd $<; \
	make AS="$(PACKAGE_AS)" ASFLAGS="$(ASFLAGS)" PLATFORM="$(PLATFORM)" INCLUDE="$(PACKAGE_INCLUDE)" \
				PACKAGEPATH="$(PACKAGEPATH)" OUTDIR="$(PKGREL)temp";

buildpkgs: directories $(PACKBUF)

license: directories
	cp LICENSE temp/etc/LICENSE

directories:
	mkdir -p bin/$(PLATFORM)
	rm -rf temp
	mkdir -p temp
	mkdir -p temp/bin
	mkdir -p temp/etc
	mkdir -p temp/home
	mkdir -p temp/lib
	touch temp/testfileA
	touch temp/testfileB
	touch temp/testfileC

clean:
	cd kernel && make clean
	rm -rf bin
	rm -rf temp
