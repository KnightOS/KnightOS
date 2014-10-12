# makefile for KnightOS

PACKAGES:=core/init core/corelib core/configlib core/textview core/castle core/threadlist core/settings extra/fileman ports/phoenix
KERNELVER:=0.6.3
# This can be a path to the root of a kernel source tree to use a development kernel
KERNEL:=download

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

PACKBUF=$(patsubst %, packages/%.pkg, $(PACKAGES))

AS:=sass
EMU:=wabbitemu
EMUFLAGS:=
.DEFAULT_GOAL=TI84pSE
OUTDIR:=bin/

.PHONY: userland clean exploit kernel run install_userspace directories configs \
	TI73 TI83p TI83pSE TI84p TI84pSE TI84pCSE \
	packages/%.pkg

run: TI84pSE
	$(EMU) $(EMUFLAGS) bin/TI84pSE/KnightOS-TI84pSE.rom

$(OUTDIR)exploit.bin:
	if [ $(EXPLOIT) -eq 1 ]; then\
		$(AS) $(ASFLAGS) --include "$(INCLUDE)" --define "$(PLATFORM)" exploit/exploit.asm bin/exploit.bin;\
	fi

kernel:
	if [ -e "$(KERNEL)" ]; then\
		cd "$(KERNEL)" && make $(PLATFORM);\
		cp "$(KERNEL)/bin/$(PLATFORM)" kernels/;\
	else\
		wget -nc -O kernels/kernel-$(PLATFORM).rom "https://github.com/KnightOS/kernel/releases/download/$(KERNELVER)/kernel-$(PLATFORM).rom" || true;\
	fi

packages/%.pkg:
	wget -nc -O $@ "https://packages.knightos.org/$$(echo -n "$@" | cut -c 10- | rev | cut -c 5- | rev)/download"

install_userspace:
	find packages -exec kpack -s -e {} root/ \;

userland: directories kernel packages $(OUTDIR)exploit.bin $(PACKBUF) install_userspace configs
	cp kernels/kernel-$(PLATFORM).rom bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom
	git describe --dirty=+ > root/etc/version
	genkfs bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom root
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
		mktiupgrade -p -d $(DEVICE) -k keys/$(KEY).key -n $(KEY) bin/$(PLATFORM)/KnightOS-$(PLATFORM).rom \
			bin/$(PLATFORM)/KnightOS-$(PLATFORM).$(UPGRADEEXT) 00 01 02 03 04 05 06 $(FAT) $(PRIVEDGED);\
	fi

configs:
	ln -s /var/applications/fileman.app root/var/castle/pin-0
	ln -s /var/applications/gfxdemo.app root/var/castle/pin-1
	ln -s /var/applications/hello.app root/var/castle/pin-2
	ln -s /var/applications/count.app root/var/castle/pin-3
	ln -s /var/applications/settings.app root/var/castle/pin-4
	ln -s /var/applications/phoenix.app root/var/castle/pin-5
	echo -ne "icon=/share/icons/copyright.kio\nname=License\nexec=/etc/LICENSE" > root/var/castle/pin-9
	cp inittab root/etc/
	cp castle.conf root/etc/
	cp THANKS root/etc/
	cp LICENSE root/etc/

directories:
	mkdir -p kernels
	mkdir -p bin/$(PLATFORM)
	mkdir -p packages/
	mkdir -p packages/core
	mkdir -p packages/extra
	mkdir -p packages/community
	mkdir -p packages/ports
	rm -rf root
	mkdir -p root
	mkdir -p root/bin
	mkdir -p root/etc
	mkdir -p root/home
	mkdir -p root/lib
	mkdir -p root/share
	mkdir -p root/var
	mkdir -p root/var
	mkdir -p root/var/castle

clean:
	rm -rf bin
	rm -rf root
