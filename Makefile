# makefile for KnightOS

# Common variables

# Package configuration
#
# To manually specify packages to build, uncomment this: 
# PACKAGES=demos
#
# Or to automatically build all packages, uncomment this:
PACKAGES=$(wildcard packages/*)
# End config.

PACKBUF=$(patsubst %, %.package, $(PACKAGES))

# Paths
PACKAGEPATH=packages
# Where packages are placed relative to the top directory
PKGREL=../../

TI73: PLATFORM := TI73
TI73: DEVICE := TI-73
TI73: FAT := 17
TI73: PRIVEDGED := 1C
TI73: KEY := 02
TI73: UPGRADEEXT := 73u
TI73: EXPLOIT := 0
TI73: userland

TI83p: PLATFORM := TI83p
TI83p: DEVICE := TI-83+
TI83p: FAT := 17
TI83p: PRIVEDGED := 1C
TI83p: KEY := 04
TI83p: UPGRADEEXT := 8xu
TI83p: EXPLOIT := 0
TI83p: userland

TI83pSE: PLATFORM := TI83pSE
TI83pSE: DEVICE := TI-83+SE
TI83pSE: FAT := 77
TI83pSE: PRIVEDGED := 7C
TI83pSE: KEY := 04
TI83pSE: UPGRADEEXT := 8xu
TI83pSE: EXPLOIT := 0
TI83pSE: userland

TI84p: PLATFORM := TI84p
TI84p: DEVICE := TI-84+
TI84p: FAT := 37
TI84p: PRIVEDGED := 3C
TI84p: KEY := 0A
TI84p: UPGRADEEXT := 8xu
TI84p: EXPLOIT := 0
TI84p: userland

TI84pSE: PLATFORM := TI84pSE
TI84pSE: DEVICE := TI-84+SE
TI84pSE: FAT := 77
TI84pSE: PRIVEDGED := 7C
TI84pSE: KEY := 0A
TI84pSE: UPGRADEEXT := 8xu
TI84pSE: EXPLOIT := 0
# TODO: Support boot code exploit on 84+ SE
#TI84pSE: EXPLOIT := 1
#TI84pSE: EXPLOIT_PAGES := 73 74
#TI84pSE: EXPLOIT_ADDRESS := 1890943
#TI84pSE: EXPLOIT_ADDRESS_F3 := 1884160
#TI84pSE: EXPLOIT_ADDRESS_F4 := 1900544
TI84pSE: userland

TI84pCSE: PLATFORM := TI84pCSE
TI84pCSE: DEVICE := TI-84+CSE
TI84pCSE: FAT := F7
TI84pCSE: PRIVEDGED := FC
TI84pCSE: KEY := 0F
TI84pCSE: UPGRADEEXT := 8cu
TI84pCSE: EXPLOIT := 1
TI84pCSE: EXPLOIT_PAGES := F3 F4 EB
TI84pCSE: EXPLOIT_ADDRESS := 3988095
TI84pCSE: EXPLOIT_ADDRESS_F3 := 3981312
TI84pCSE: EXPLOIT_ADDRESS_F4 := 3997696
TI84pCSE: EXPLOIT_ADDRESS_FAT := 4046848
TI84pCSE: EXPLOIT_ADDRESS_FAT_BACKUP := 3850240
TI84pCSE: userland

AS=sass
EMU=wabbitemu
ASFLAGS=--encoding "Windows-1252"
INCLUDE=inc/;kernel/bin/$(PLATFORM);temp/include/;
.DEFAULT_GOAL=TI84pSE

PACKAGE_AS=sass
PACKAGE_INCLUDE=$(PKGREL)inc/;$(PKGREL)kernel/bin/$(PLATFORM);

.PHONY: kernel userland run runcolor buildpkgs license directories clean %.package exploit \
	TI73 TI83p TI83pSE TI84p TI84pSE TI84pCSE

run: TI84pSE
	$(EMU) bin/TI84pSE/KnightOS-TI84pSE.rom

runcolor: TI84pCSE
	$(EMU) bin/TI84pCSE/KnightOS-TI84pCSE.rom

kernel: directories
	cd kernel && make $(PLATFORM)
	cp kernel/bin/$(PLATFORM)/kernel.inc temp/include/kernel.inc

exploit:
	if [ $(EXPLOIT) -eq 1 ]; then\
		$(AS) $(ASFLAGS) --include "$(INCLUDE)" --define "$(PLATFORM)" exploit/exploit.asm bin/exploit.bin;\
	fi

userland: kernel directories buildpkgs license exploit
	cp kernel/bin/$(PLATFORM)/kernel.rom bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom
	git describe --dirty=+ > temp/etc/version
	genkfs bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom temp
ifndef savemockfs
	@rm -rf temp
endif
	if [ $(EXPLOIT) -eq 1 ]; then\
		cp bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom temp.rom;\
		dd bs=1 if=temp.rom of=bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom skip=$(EXPLOIT_ADDRESS_FAT) seek=$(EXPLOIT_ADDRESS_FAT_BACKUP) conv=notrunc;\
		dd bs=1 if=exploit/pageF3_exploit.bin of=bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom seek=$(EXPLOIT_ADDRESS_F3) conv=notrunc;\
		dd bs=1 if=exploit/pageF4_exploit.bin of=bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom seek=$(EXPLOIT_ADDRESS_F4) conv=notrunc;\
		dd bs=1 if=bin/exploit.bin of=bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom seek=$(EXPLOIT_ADDRESS) conv=notrunc;\
		echo -ne "\xFF" | dd bs=1 of=bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom seek=38 conv=notrunc;\
		echo -ne "\xFF" | dd bs=1 of=bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom seek=86 conv=notrunc;\
		mktiupgrade -p -s exploit/signature.bin -d $(DEVICE) -n $(KEY) bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom \
				bin/$(PLATFORM)/KnightOS-$(PLATFORM).$(UPGRADEEXT) 00 01 02 03 04 05 06 $(PRIVEDGED) $(EXPLOIT_PAGES);\
		rm temp.rom;\
	else\
		mktiupgrade -p -d $(DEVICE) -k kernel/keys/$(KEY).key bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom \
			bin/$(PLATFORM)/KnightOS-$(PLATFORM).$(UPGRADEEXT) 00 01 02 03 04 05 06 $(FAT) $(PRIVEDGED);\
	fi

%.package: %
	@cd $<; \
	make AS="$(PACKAGE_AS)" ASFLAGS="$(ASFLAGS)" PLATFORM="$(PLATFORM)" INCLUDE="$(PACKAGE_INCLUDE)" \
				PACKAGEPATH="$(PACKAGEPATH)";
	@cd $<; \
	cp -r bin/* "$(PKGREL)temp";

buildpkgs: directories $(PACKBUF)

license: directories
	mkdir -p temp/etc/
	cp LICENSE temp/etc/LICENSE

directories:
	mkdir -p bin/$(PLATFORM)
	rm -rf temp
	mkdir -p temp
	mkdir -p temp/bin
	mkdir -p temp/etc
	mkdir -p temp/home
	mkdir -p temp/var/foo/bar
	echo "Hi there" > temp/var/foo/bar/foobar
	mkdir -p temp/lib
	mkdir -p temp/share
	mkdir -p temp/include
	mkdir -p temp/var

clean:
	@for f in $(PACKAGES) ; do \
		cd $$f ; make clean ; cd $(PKGREL); \
	done
	cd kernel && make clean
	rm -rf bin
	rm -rf temp
