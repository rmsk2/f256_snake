RM=rm
PORT=/dev/ttyUSB0
SUDO=

BINARY=snake
FORCE=-f

ifdef WIN
RM=del
PORT=COM3
SUDO=
FORCE=
endif


all: pgz
pgz: $(BINARY).pgz

$(BINARY): *.asm
	64tass --nostart -o $(BINARY) main.asm

clean: 
	$(RM) $(FORCE) $(BINARY)
	$(RM) $(FORCE) $(BINARY).pgz
	$(RM) $(FORCE) tests/bin/*.bin

upload: $(BINARY).pgz
	$(SUDO) python fnxmgr.zip --port $(PORT) --run-pgz $(BINARY).pgz


$(BINARY).pgz: $(BINARY)
	python3 make_pgz.py $(BINARY)

