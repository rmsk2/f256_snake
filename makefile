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

PICS = grass.xpm obstacle.xpm apple.xpm ct_segment.xpm head.xpm

all: pgz
pgz: $(AUTO_GEN) $(BINARY).pgz

$(BINARY): *.asm *.inc
	64tass --nostart -o $(BINARY) main.asm

*.inc: $(PICS)
	python xpm2t64.py $(PICS)

clean: 
	$(RM) $(FORCE) $(BINARY)
	$(RM) $(FORCE) $(BINARY).pgz
	$(RM) $(FORCE) auto_cols.inc
	$(RM) $(FORCE) auto_tiles.inc
	$(RM) $(FORCE) auto_clut.inc

upload: $(BINARY).pgz
	$(SUDO) python fnxmgr.zip --port $(PORT) --run-pgz $(BINARY).pgz


$(BINARY).pgz: $(BINARY)
	python3 make_pgz.py $(BINARY)

