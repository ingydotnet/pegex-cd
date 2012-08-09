ALL_COFFEE = $(shell find src -name *.coffee)
ALL_JS = $(ALL_COFFEE:src/%.coffee=lib/%.js)

default: help

help:
	@echo ''
	@echo 'Makefile targets:'
	@echo ''
	@echo '    make build  - Compile stuff'
	@echo '    make test   - Run the tests'
	@echo '    make clean  - Clean up'
	@echo '    make help   - Get Help'
	@echo ''

build: $(ALL_JS)

lib/%.js: src/%.coffee
	coffee --compile -p $< > $@

test xtest: build
	coffee -e '(require "./test/lib/Test/Harness").run()' $@

clean:
	rm -fr node_modules
