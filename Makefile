.PHONY: build test node clean purge help node

ALL_LIB := $(shell find src -type d)
ALL_LIB := $(ALL_LIB:src/%=lib/%)

ALL_COFFEE := $(shell find src -name *.coffee)
ALL_JS := $(ALL_COFFEE:src/%.coffee=lib/%.js)

default: help

help:
	@echo ''
	@echo 'Makefile targets:'
	@echo ''
	@echo '    make build  - Compile stuff'
	@echo '    make test   - Run the tests'
	@echo ''
	@echo '    make node   - Make a Node.js package'
	@echo ''
	@echo '    make clean  - Clean up'
	@echo '    make help   - Get Help'
	@echo ''

build: $(ALL_LIB) $(ALL_JS)
	@make -C test $@

lib/%.js: src/%.coffee
	coffee --compile -p $< > $@

test xtest: build
	coffee -e '(require "./test/lib/Test/Harness").run()' $@

node: clean build
	mkdir -p $@ $@/test
	cp -r lib doc test LICENSE* $@/
	cp -r test/lib $@/test/
	./bin/cdent-package-yaml-converter package.yaml > $@/package.json

clean purge:
	rm -fr node_modules lib node
	@make -C test $@

$(ALL_LIB):
	mkdir -p $@
