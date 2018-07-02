# Makefile,v

OCAMLC=ocamlc
OCAMLOPT=ocamlopt
OCAMLDEP=ocamldep

MLFILES=ploc.ml plexing.ml fstream.ml gramext.ml grammar.ml
CMOS=$(MLFILES:.ml=.cmo)
TARGET=gramlib.cma

all: $(TARGET)
opt: $(TARGET:.cma=.cmxa)

$(TARGET): $(CMOS)
	$(OCAMLC) $(CMOS) -a -o $(TARGET)

$(TARGET:.cma=.cmxa): $(CMOS:.cmo=.cmx)
	$(OCAMLOPT) $(CMOS:.cmo=.cmx) -a -o $(TARGET:.cma=.cmxa)

clean::
	$(RM) -f *.cm[ioax] *.cmxa *.pp[io] *.[ao] *.obj *.lib *.bak .*.bak
	$(RM) -f $(TARGET)

.depend:
	$(OCAMLDEP) *.ml *.mli > .depend

install:
	-$(MKDIR) "$(DESTDIR)$(LIBDIR)/$(CAMLP5N)"
	cp $(TARGET) *.mli "$(DESTDIR)$(LIBDIR)/$(CAMLP5N)/."
	cp *.cmi "$(DESTDIR)$(LIBDIR)/$(CAMLP5N)/."
	if test -f $(TARGET:.cma=.cmxa); then \
	  $(MAKE) installopt LIBDIR="$(LIBDIR)" DESTDIR=$(DESTDIR); \
	fi

installopt:
	cp $(TARGET:.cma=.cmxa) *.cmx "$(DESTDIR)$(LIBDIR)/$(CAMLP5N)/."
	if test -f $(TARGET:.cma=.lib); then \
	  cp $(TARGET:.cma=.lib) "$(DESTDIR)$(LIBDIR)/$(CAMLP5N)/."; \
	else \
	  tar cf - $(TARGET:.cma="")$(EXT_LIB) | \
	  (cd "$(DESTDIR)$(LIBDIR)/$(CAMLP5N)/."; tar xf -); \
	fi

%.cmx: %.ml
	$(OCAMLOPT) -c $<

%.cmo: %.ml
	$(OCAMLC) -c $<

%.cmi: %.mli
	$(OCAMLC) -c $<

include .depend
