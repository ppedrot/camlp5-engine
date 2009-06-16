# This file has been generated by program: do not edit!

TOP=../..
include $(TOP)/config/Makefile

INCLUDES=
OCAMLCFLAGS=-warn-error A $(INCLUDES)
OBJS=ploc.cmo plexing.cmo plexer.cmo fstream.cmo gramext.cmo grammar.cmo diff.cmo extfold.cmo extfun.cmo pretty.cmo pprintf.cmo eprinter.cmo stdpp.cmo token.cmo
SHELL=/bin/sh
TARGET=gramlib.cma

all: $(TARGET)
opt: $(TARGET:.cma=.cmxa)

$(TARGET): $(OBJS)
	$(OCAMLC) $(OBJS) -a -o $(TARGET)

$(TARGET:.cma=.cmxa): $(OBJS:.cmo=.cmx)
	$(OCAMLOPT) $(OBJS:.cmo=.cmx) -a -o $(TARGET:.cma=.cmxa)

clean::
	rm -f *.cm[ioax] *.cmxa *.pp[io] *.[ao] *.obj *.lib *.bak .*.bak
	rm -f $(TARGET)

depend:
	cp .depend .depend.bak
	> .depend
	@export LC_ALL=C; for i in $$(ls *.mli *.ml); do \
	  NAME=$(NAME) ../tools/depend.sh $(INCLUDES) $$i | \
	  sed -e 's| $(OTOP)| $$(OTOP)|g' >> .depend; \
	done

promote:
	cp $(OBJS) $(OBJS:.cmo=.cmi) $(TOP)/boot/.

compare:
	@for j in $(OBJS) $(OBJS:.cmo=.cmi); do \
		if cmp $$j $(TOP)/boot/$$j; then :; else exit 1; fi; \
	done

install:
	-$(MKDIR) "$(DESTDIR)$(LIBDIR)/$(NAME)"
	cp $(TARGET) *.mli "$(DESTDIR)$(LIBDIR)/$(NAME)/."
	cp *.cmi "$(DESTDIR)$(LIBDIR)/$(NAME)/."
	if test -f $(TARGET:.cma=.cmxa); then \
	  $(MAKE) installopt LIBDIR="$(LIBDIR)" DESTDIR=$(DESTDIR); \
	fi

installopt:
	cp $(TARGET:.cma=.cmxa) *.cmx "$(DESTDIR)$(LIBDIR)/$(NAME)/."
	if test -f $(TARGET:.cma=.lib); then \
	  cp $(TARGET:.cma=.lib) "$(DESTDIR)$(LIBDIR)/$(NAME)/."; \
	else \
	  tar cf - $(TARGET:.cma=$(EXT_LIB)) | \
	  (cd "$(DESTDIR)$(LIBDIR)/$(NAME)/."; tar xf -); \
	fi

include .depend
