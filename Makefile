include .knightos/variables.make

SHELL:=/bin/bash

# 84+ CSE exploit constants
EXPLOIT_PAGES := F3 F4 EB
EXPLOIT_ADDRESS := 3988095
EXPLOIT_ADDRESS_F3 := 3981312
EXPLOIT_ADDRESS_F4 := 3997696
EXPLOIT_ADDRESS_FAT := 4046848
EXPLOIT_ADDRESS_FAT_BACKUP := 3850240

.PHONY: links rom upgrade
INIT=/bin/castle

ALL_TARGETS:=$(ETC)castle.conf $(ETC)LICENSE $(ETC)THANKS links

$(OUT)exploit.bin: exploit/exploit.asm
	$(AS) $(ASFLAGS) --define $(PLATFORM) exploit/exploit.asm $(OUT)exploit.bin

$(ETC)castle.conf: config/castle.conf
	mkdir -p $(ETC)
	cp config/castle.conf $(ETC)castle.conf

$(ETC)LICENSE: LICENSE
	mkdir -p $(ETC)
	cp LICENSE $(ETC)LICENSE

$(ETC)THANKS: THANKS
	mkdir -p $(ETC)
	cp THANKS $(ETC)THANKS

links:
	mkdir -p $(SHARE)
	mkdir -p $(BIN)
	mkdir -p $(ROOT)home
	rm -rf $(VAR)castle
	mkdir -p $(VAR)castle
	ln -s /var/applications/fileman.app $(VAR)castle/pin-0
	ln -s /var/applications/gfxdemo.app $(VAR)castle/pin-1
	ln -s /var/applications/hello.app $(VAR)castle/pin-2
	ln -s /var/applications/count.app $(VAR)castle/pin-3
	ln -s /var/applications/settings.app $(VAR)castle/pin-4
	ln -s /var/applications/phoenix.app $(VAR)castle/pin-5
	echo -ne "icon=/share/icons/copyright.kio\nname=License\nexec=/etc/LICENSE" > $(VAR)castle/pin-9
	cp defaults $(ETC)defaults
	rm -rf $(BIN)launcher
	ln -s /bin/castle $(BIN)launcher
	rm -rf $(BIN)switcher
	ln -s /bin/fileman $(BIN)switcher
	rm -rf $(BIN)browser
	ln -s /bin/fileman $(BIN)browser
	rm -rf $(BIN)editor
	ln -s /bin/bed $(BIN)editor
	knightos query version > $(ETC)version
	echo -ne "\n" >> $(ETC)version # TODO: Fix core/settings

rom: all
	cp $(SDK)debug.rom $(OUT)KnightOS-$(PLATFORM).rom

upgrade: rom $(OUT)exploit.bin
	# Applies exploit on models that require it
	if [[ "$(PLATFORM)" == "TI84pCSE" ]]; then\
		cp $(OUT)/KnightOS-$(PLATFORM).rom temp.rom;\
		dd bs=1 if=temp.rom of=$(OUT)KnightOS-$(PLATFORM).rom skip=$(EXPLOIT_ADDRESS_FAT) seek=$(EXPLOIT_ADDRESS_FAT_BACKUP) conv=notrunc;\
		dd bs=1 if=exploit/pageF3_exploit.bin of=$(OUT)KnightOS-$(PLATFORM).rom seek=$(EXPLOIT_ADDRESS_F3) conv=notrunc;\
		dd bs=1 if=exploit/pageF4_exploit.bin of=$(OUT)KnightOS-$(PLATFORM).rom seek=$(EXPLOIT_ADDRESS_F4) conv=notrunc;\
		dd bs=1 if=bin/exploit.bin of=$(OUT)KnightOS-$(PLATFORM).rom seek=$(EXPLOIT_ADDRESS) conv=notrunc;\
		echo -ne "\xFF" | dd bs=1 of=$(OUT)KnightOS-$(PLATFORM).rom seek=38 conv=notrunc;\
		echo -ne "\xFF" | dd bs=1 of=$(OUT)KnightOS-$(PLATFORM).rom seek=86 conv=notrunc;\
		mktiupgrade -p -s exploit/signature.bin -d $(PLATFORM) -n $(KEY) $(OUT)KnightOS-$(PLATFORM).rom \
				$(OUT)KnightOS-$(PLATFORM).$(UPGRADEEXT) 00 01 02 03 04 05 06 $(PRIVILEGED) $(EXPLOIT_PAGES);\
		rm temp.rom;\
	else\
		mktiupgrade -p -d $(PLATFORM) -k keys/$(KEY).key -n $(KEY) $(OUT)KnightOS-$(PLATFORM).rom \
			$(OUT)KnightOS-$(PLATFORM).$(UPGRADEEXT) 00 01 02 03 04 05 06 $(FAT) $(PRIVILEGED);\
	fi

include .knightos/sdk.make
