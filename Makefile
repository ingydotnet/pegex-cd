.PHONY: build test node clean purge help

ALL_LIB := $(shell find src -type d)
ALL_LIB := $(ALL_LIB:src/%=lib/%)

ALL_COFFEE := $(shell find src -name *.coffee)
ALL_JS := $(ALL_COFFEE:src/%.coffee=lib/%.js)

ALL_TEST_LIB := $(shell find test/src -type d)
ALL_TEST_LIB := $(ALL_TEST_LIB:test/src/%=test/lib/%)

ALL_TEST_COFFEE := $(shell find test/src -name *.coffee)
ALL_TEST_JS := $(ALL_TEST_COFFEE:test/src/%.coffee=test/lib/%.js)

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

build: $(ALL_LIB) $(ALL_JS) $(ALL_TEST_LIB) $(ALL_TEST_JS)

lib/%.js: src/%.coffee
	coffee --compile -p $< > $@

test/lib/%.js: test/src/%.coffee
	coffee --compile -p $< > $@

test xtest: build
	coffee -e '(require "./test/lib/Test/Harness").run()' $@

node: build pkg/node
	rm -fr node/lib
	cp -r lib node/lib

clean purge:
	rm -fr node_modules lib test/lib pkg

$(ALL_LIB) $(ALL_TEST_LIB) pkg/node:
	mkdir -p $@
