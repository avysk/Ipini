all:
	ocamlbuild -use-ocamlfind ipini.native
clean:
	ocamlbuild -clean

.PHONY: all clean
