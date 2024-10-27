# f256_snake
A simple snake clone for the Foenix 256 line of modern retro computers which was developed 
during the October 2024 game jam on the Foenix retro systems discord server. 

The game idea is simple and well knwown: A caterpillar wants to eat apples, which appear at
random locations on the playfield. Unfortunately for each apple it consumes it grows longer. The 
caterpillar must not collide with itself or with the gravestones which can be found on some 
levels. The caterpillar which eats the most apples wins. The number of apples already consumed 
is shown in the top left corner.

The graveyard has no boundaries, i.e. if the caterpillar moves out of the playfield it simply 
reappears on the opposite end. 

The game can be controlled with the cursor keys or a joystick in port 0. Whenever you press one
of the keys 0, 1 or 2 you start a new game in the corresponding level. When F3 is pressed the 
game is ended and SuperBASIC is restarted. You can pause the game by pressing the space bar. 
Press the space bar again in order to resume the game. You have to switch your machine off and 
on again if you want to get rid of the modified font `f256_snake` uses.

# A bit of technical info

`f256_snake` runs in 40x30 characters text mode and uses a modified font to draw on the screen. 
In retrospect an esthetically more pleasing result could have been achieved using 8x8 tiles 
(in 256 colours) instead of characters with only two colours without being much more difficult 
to program. On the other hand I am not an artist and who knows maybe the end result would not 
have been that better `;-)`. 

# Building and modifying the game

You will need a python3 interpreter, GNU make and 64tass on your machine to build this software.
Use `make` to build a `.pgz` executable and transfer it to your machine via an SD-card or `dcopy`.
Alternatively you can use `make upload` to upload and start the program via the USB debug port.

If the game runs too slow for your taste you can try to decrease the value of the constant 
`GAME_SPEED` which is defined in the file `snake.asm`. Unfortuately this also decreases the precision
by which the caterpillar can be controlled. 

Look at the file `levels.asm` in order to find two examples for levels if you want to add your own.
If you want to do that you also have to modify the constant `ASCII_LMAX` to the ASCII value of the 
highest level number between `0` and `9` in order to make all levels selectable in the "UI". 
If you want to be thorough you can adapt the text values `TXT_START` and `TXT_END` to reflect 
the new level numbers.
