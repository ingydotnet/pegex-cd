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

build:
	coffee --compile --output lib src
	coffee --compile --output test/lib test/src

test: build
	node -e 'require("./test/lib/Test/Harness").run()' $@
