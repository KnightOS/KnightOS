include .knightos/variables.make

INIT=/bin/castle

ALL_TARGETS:=$(ETC)castle.conf

$(ETC)castle.conf: config/castle.conf
	mkdir -p $(ETC)
	cp config/castle.conf $(ETC)castle.conf

include .knightos/sdk.make
