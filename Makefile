include .knightos/variables.make

.PHONY: links
INIT=/bin/castle

ALL_TARGETS:=$(ETC)castle.conf links

$(ETC)castle.conf: config/castle.conf
	mkdir -p $(ETC)
	cp config/castle.conf $(ETC)castle.conf

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

include .knightos/sdk.make
