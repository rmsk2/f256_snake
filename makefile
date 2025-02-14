RM=rm
PORT=/dev/ttyUSB0
SUDO=

BINARY=snake
BINARY_EMU=snake_emu
FORCE=-f
PYTHON=python3
CP=cp
DIST=dist

ifdef WIN
RM=del
PORT=COM3
SUDO=
FORCE=
endif

PICS = grass.xpm obstacle.xpm apple.xpm ct_segment.xpm head.xpm
TILE_INCLUDES = auto_cols.inc auto_tiles.inc auto_clut.inc
ONBOARDPREFIX=snake_
LOADER=loader.bin
FLASHBLOCKS=cart_snake.bin

.PHONY: all
all: pgz

.PHONY: pgz
pgz: $(BINARY).pgz

.PHONY: dist
dist: clean pgz $(BINARY_EMU).pgz cartridge onboard
	$(RM) $(FORCE) $(DIST)/*
	$(CP) $(BINARY).pgz $(DIST)/
	$(CP) $(BINARY_EMU).pgz $(DIST)/
	$(CP) $(FLASHBLOCKS) $(DIST)/
	$(CP) $(ONBOARDPREFIX)*.bin $(DIST)/


$(BINARY): *.asm $(TILE_INCLUDES)
	64tass --nostart -D USE_SNES_PAD=1 -o $(BINARY) main.asm


$(BINARY_EMU).pgz: clean *.asm $(TILE_INCLUDES)
	64tass --nostart -D USE_SNES_PAD=0 -o $(BINARY_EMU) main.asm
	$(PYTHON) make_pgz.py $(BINARY_EMU)


$(TILE_INCLUDES): $(PICS)
	$(PYTHON) xpm2t64.py $(PICS)

clean: 
	$(RM) $(FORCE) $(BINARY)
	$(RM) $(FORCE) $(BINARY).pgz
	$(RM) $(FORCE) $(BINARY_EMU)
	$(RM) $(FORCE) $(BINARY_EMU).pgz	
	$(RM) $(FORCE) $(LOADER)
	$(RM) $(FORCE) $(TILE_INCLUDES)
	$(RM) $(FORCE) $(BINARY).bin
	$(RM) $(FORCE) $(FLASHBLOCKS)
	$(RM) $(FORCE) $(ONBOARDPREFIX)*.bin
	$(RM) $(FORCE) $(DIST)/*


upload: $(BINARY).pgz
	$(SUDO) $(PYTHON) fnxmgr.zip --port $(PORT) --run-pgz $(BINARY).pgz


$(BINARY).pgz: $(BINARY)
	$(PYTHON) make_pgz.py $(BINARY)


$(LOADER): flashloader.asm
	64tass --nostart -o $(LOADER) flashloader.asm

.PHONY: cartridge
cartridge: $(FLASHBLOCKS)


$(FLASHBLOCKS) &: $(BINARY) $(LOADER)
	$(PYTHON) pad_binary.py $(BINARY) $(LOADER) $(FLASHBLOCKS)


.PHONY: onboard
onboard: $(FLASHBLOCKS)
	$(PYTHON) split8k.py $(FLASHBLOCKS) $(ONBOARDPREFIX)
