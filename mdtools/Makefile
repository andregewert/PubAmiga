# Requirements: free pascal compiler, fpc-markdown units
 
fpc = fpc
fpcopts =

help:
	@echo "Available targets:"
	@echo "  all: Build mdtohtml"
	@echo "  deps: Build dependencies (only)"
	@echo "  clean: Remove build results"
	@echo "  test: Build and run mdtohtml with a small test file"
	@echo "  dist: Create archive file for distribution\n"

all: mdtohtml

prepare:
	mkdir -p build

deps: prepare
	fpc /fpc-markdown/source/MarkdownProcessor.pas -FEbuild
	
.PHONY: clean
clean:
	rm -r build
	rm -r mdtools
	rm mdtools.info
	rm mdtools.lha

.PHONY: test
test: mdtohtml
	build/mdtohtml -f test/test.md -t test/template.html

mdtohtml: deps src/mdtohtml.pas
	$(fpc) $(fpcopts) src/mdtohtml.pas -FEbuild/

.PHONY:	dist
dist:
	execute createdist
	