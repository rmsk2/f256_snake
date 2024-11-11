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
TILE_INCLUDES = auto_cols.inc auto_tiles.inc auto_clut.inc

all: pgz
pgz: $(BINARY).pgz

$(BINARY): *.asm $(TILE_INCLUDES)
	64tass --nostart -o $(BINARY) main.asm

$(TILE_INCLUDES): $(PICS)
	python xpm2t64.py $(PICS)

clean: 
	$(RM) $(FORCE) $(BINARY)
	$(RM) $(FORCE) $(BINARY).pgz
	$(RM) $(FORCE) $(TILE_INCLUDES)


upload: $(BINARY).pgz
	$(SUDO) python fnxmgr.zip --port $(PORT) --run-pgz $(BINARY).pgz


$(BINARY).pgz: $(BINARY)
	python3 make_pgz.py $(BINARY)

