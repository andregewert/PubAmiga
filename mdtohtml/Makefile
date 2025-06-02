# Requirements: free pascal compiler, fpc-markdown units
 
fpc = fpc
fpcopts =

all: mdtohtml

prepare:
	mkdir -p build

clean:
	rm -r build

mdtohtml: prepare mdtohtml.pas
	$(fpc) $(fpcopts) mdtohtml.pas -FEbuild/

