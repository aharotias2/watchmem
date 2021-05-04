PKG = --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=posix
SRC = $(shell find src -type f)

all: $(SRC)
	valac $(PKG) -o watchmem $^

c: $(SRC)
	valac $(PKG) -C $^
