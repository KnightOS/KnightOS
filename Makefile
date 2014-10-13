include .knightos/variables.make

.PHONY: links rom upgrade
INIT=/bin/castle

ALL_TARGETS:=$(ETC)castle.conf $(ETC)LICENSE $(ETC)THANKS links

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

rom: all
	cp $(SDK)debug.rom $(OUT)KnightOS-$(PLATFORM).rom

upgrade: rom
	mktiupgrade -p -d $(PLATFORM) -k keys/$(KEY).key -n $(KEY) bin/KnightOS-$(PLATFORM).rom \
		bin/KnightOS-$(PLATFORM).$(UPGRADEEXT) 00 01 02 03 04 05 06 $(FAT) $(PRIVEDGED)

include .knightos/sdk.make
