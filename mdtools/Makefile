# Requirements: free pascal compiler, fpc-markdown units
 
fpc = fpc
fpcopts =

help:
	@echo "Available targets:"
	@echo "  all: Build mdtohtml"
	@echo "  clean: Remove build results"
	@echo "  test: Build and run mdtohtml with a small test file\n"

all: mdtohtml

prepare:
	mkdir -p build

.PHONY: clean
clean:
	rm -r build
	rm -r mdtools
	rm mdtools.info
	rm mdtools.lha

.PHONY: test
test: mdtohtml
	build/mdtohtml -f test/test.md -t test/template.html

mdtohtml: prepare src/mdtohtml.pas
	$(fpc) $(fpcopts) src/mdtohtml.pas -FEbuild/

.PHONY:	dist
dist:
	execute createdist
	