PKG = --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=posix
SRC_VALA = $(shell find src -type f)
SRC_GENIE = $(shell find src-genie -type f)

all: $(SRC_VALA)
	valac $(PKG) -o watchmem $^

genie: $(SRC_GENIE)
	valac $(PKG) -X -g -o watchmem $^
