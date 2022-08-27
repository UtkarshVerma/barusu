.POSIX:

PREFIX = /usr/local
CFLAGS ?= -g -std=c17 -Wall -Wpedantic -Wno-unused-parameter
LDLIBS = -lrt

DEPENDENCIES = glesv2 egl
LDLIBS += $(shell pkg-config $(DEPENDENCIES) --libs)

CFLAGS += $(shell pkg-config wayland-client --cflags)
LDLIBS += $(shell pkg-config wayland-client --libs)
WAYLAND_PROTOCOLS_DIR = $(shell pkg-config wayland-protocols --variable=pkgdatadir)
WAYLAND_SCANNER = $(shell pkg-config --variable=wayland_scanner wayland-scanner)

PROTOCOLS = wlr-layer-shell-unstable-v1 xdg-shell
PROTOCOL_HEADERS = $(addsuffix -client-protocol.h, $(PROTOCOLS))
PROTOCOL_SOURCES = $(addsuffix -protocol.c, $(PROTOCOLS))
PROTOCOL_OBJECTS = $(addsuffix -protocol.o, $(PROTOCOLS))

OBJECTS = main.o $(PROTOCOL_OBJECTS)
BIN = barusu

all: $(PROTOCOL_HEADERS) $(PROTOCOL_SOURCES) $(BIN)

$(BIN): $(OBJECTS)
	$(CC) $^ -o $@ $(LDLIBS)

%-client-protocol.h: protocols/%.xml
	$(WAYLAND_SCANNER) client-header $< $@

%-protocol.c: protocols/%.xml
	$(WAYLAND_SCANNER) private-code $< $@

.SECONDEXPANSION:
%-client-protocol.h: $$(wildcard $(WAYLAND_PROTOCOLS_DIR)/*/*/%.xml)
	$(WAYLAND_SCANNER) client-header $< $@

.SECONDEXPANSION:
%-protocol.c: $$(wildcard $(WAYLAND_PROTOCOLS_DIR)/*/*/%.xml)
	$(WAYLAND_SCANNER) private-code $< $@

clean:
	$(RM) $(OBJECTS) $(PROTOCOL_HEADERS) $(PROTOCOL_SOURCES) $(BIN)

install: $(BIN)
	install -D -m 755 $(BIN) $(DESTDIR)/$(PREFIX)/bin/

uninstall:
	$(RM) $(DESTDIR)/$(PREFIX)/bin/$(BIN)

.PHONY: clean install uninstall
