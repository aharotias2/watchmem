PKG = --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=posix
SRC_VALA_MAIN = src/main.vala
SRC_VALA = $(shell find src -type f -a ! -name main.vala)
SRC_GENIE = $(shell find src-genie -type f)
TEST_VALA = $(shell find test -type f)

all: $(SRC_VALA) $(SRC_VALA_MAIN)
	valac $(PKG) -o watchmem $^

genie: $(SRC_GENIE)
	valac $(PKG) -X -g -o watchmem $^

test: $(TEST_VALA) $(SRC_VALA)
	valac $(PKG) -o watchmem-tests $^

test-c: $(TEST_VALA) $(SRC_VALA)
	valac $(PKG) -C $^

test-run: test
	./watchmem-tests PStatusParser 1 867
	./watchmem-tests PStatusCollector 1
	./watchmem-tests PStatusDialog 1
