# f256_snake

A simple snake clone for the Foenix 256 line of modern retro computers which was developed 
during the October 2024 game jam on the Foenix retro systems discord server. 

The game idea is simple and well known: A caterpillar wants to eat apples, which appear at
random locations on the playfield. Unfortunately for each apple it consumes it grows longer. 
The number of apples already consumed is shown in the top left corner. The caterpillar must not 
collide with itself or with the rocks which can be found on the screens. There are 
five screens at the moment, which present different sets of additional obstacles.

In principle the playfield has no boundaries, i.e. if the caterpillar moves out of the playfield 
it simply reappears on the opposite end if there is no rock in the way.

The game can be controlled with the cursor keys, a joystick in port 0 or an SNES pad in the first
socket. Whenever you press one of the keys 0, 1, 2, 3 or 4 you start a new game on the corresponding screen. 
When F3 is pressed the game is ended and SuperBASIC is restarted. You can pause the game by pressing 
the space bar. Press the space bar again in order to resume the game. You can also pause and resume
the game with the fire button on the joystick or the two buttons at the front of the SNES pad.

The duration of the current game is shown below the playfield. Calculating the duration of
the current game is not stopped when the game is paused.

![](/scrshot.png?raw=true "Screenshot of snake in emulator")

# A bit of technical info

`f256_snake` runs in 40x30 characters text mode on top of an 8x8 tiles layer to draw the playing 
field. The tiles can be edited using any program, which can read and write pictures in `.xpm` format.
A python script (`xpm2t64.py`) is used to auto generate `64tass` compatible source code fom the picture 
data. One only has to draw the head of the caterpillar in 'up' direction. The other orientations are
created automatically by `xpm2t64.py` using corresponding transformations.

As `f256_snake` also uses some modified characters you have to switch your machine off and on again
if you want to get rid of the modified font.

# Building and modifying the game

You will need a python3 interpreter, GNU make and 64tass on your machine to build this software.
Use `make` to build a `.pgz` executable and transfer it to your machine via an SD-card or `dcopy`.
Alternatively you can use `make upload` to upload and start the program via the USB debug port.

If the game runs too slow for your taste you can try to decrease the value of the constant 
`GAME_SPEED` which is defined in the file `snake.asm`. Unfortuately this also decreases the precision
by which the caterpillar can be controlled.

You can turn off SNES pad support by setting the constant `USE_SNES_PAD` in `main.asm` to 0. Doing
this allows you to run the program in the emulator.

Look at the file `screens.asm` in order to find three examples for levels if you want to add your own.
If you want to do that you also have to modify the constant `ASCII_LMAX` to the ASCII value of the 
highest level number between `0` and `9` in order to make all levels selectable in the "UI". 
If you want to be thorough you can adapt the text values `TXT_START` and `TXT_END` to reflect 
the new level numbers.
