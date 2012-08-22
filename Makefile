.PHONY: build test npm clean purge help

ALL_LIB := $(shell find src -type d)
ALL_LIB := $(ALL_LIB:src/%=lib/%)

ALL_CDENT := $(shell find src -name *.cd.uni)
ALL_JS := $(ALL_CDENT:src/%.cd.uni=lib/%.js)

default: help

help:
	@echo ''
	@echo 'Makefile targets:'
	@echo ''
	@echo '    make build  - Compile stuff'
	@echo '    make test   - Run the tests'
	@echo ''
	@echo '    make npm    - Make a Node.js package'
	@echo ''
	@echo '    make clean  - Clean up'
	@echo '    make help   - Get Help'
	@echo ''

build: $(ALL_LIB) $(ALL_JS)
	@make -C test $@

lib/%.js: src/%.cd.uni
	coffee --compile -p $< > $@

test xtest: build
	coffee -e '(require "./test/lib/Test/Harness").run()' $@

npm: clean build
	mkdir -p $@/test
	cp -r \
	    LICENSE* \
	    README* \
	    doc \
	    lib \
	    test \
	    $@/
	cp -r test/lib $@/test/
	./bin/cdent-package-yaml-converter package.yaml > $@/package.json

clean purge:
	rm -fr node_modules lib npm
	@make -C test $@

$(ALL_LIB):
	mkdir -p $@
