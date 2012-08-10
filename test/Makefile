.PHONY: build clean purge help

ALL_LIB := $(shell find src -type d)
ALL_LIB := $(ALL_LIB:src/%=lib/%)

ALL_COFFEE := $(shell find src -name '*.coffee')
ALL_JS := $(ALL_COFFEE:src/%.coffee=lib/%.js)

default: help

help:
	@echo ''
	@echo 'Makefile targets:'
	@echo ''
	@echo '    make build  - Compile stuff'
	@echo '    make clean  - Clean up'
	@echo '    make help   - Get Help'
	@echo ''

build: $(ALL_LIB) $(ALL_JS)

lib/%.js: src/%.coffee
	coffee --compile -p $< > $@

clean purge:
	rm -fr lib

$(ALL_LIB):
	mkdir -p $@
