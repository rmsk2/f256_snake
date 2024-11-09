import sys


class ParseException(Exception):
    pass


class ColDefs:
    def __init__(self, x_size, y_size, num_cols, char_width):
        self.x_size = int(x_size)
        self.y_size = int(y_size)
        self.num_cols = int(num_cols)
        self.char_width = int(char_width)


class ColData:
    def __init__(self, r, g, b, character):
        self.red = r
        self.green = g
        self.blue = b
        # 24 bit colour value
        self.col = r * 65536 + g * 256 + b
    
    def __str__(self):
        return f"{self.red} {self.green} {self.blue}"


def clean_up(col_def):
    col_def = col_def.strip()
    return remove_chars(col_def)


def remove_chars(col_def):
    col_def = col_def.replace('"', '')
    col_def = col_def.replace(',', '')
    col_def = col_def.replace('}', '')
    col_def = col_def.replace(';', '')
    
    return col_def

#Parse a color defintion line
def parse_color(data):
    # Make sure , oder ; are not used as a standin for a colour
    if (data[1] == ',') or (data[1] == ';'):
        raise ParseException()

    data = remove_chars(data)

    if (data[2] != 'c') or (data[4] != '#'):
        raise ParseException()

    # standin char for colour
    c = data[0]
    # extract RGB value
    raw_col = data[5:].strip()

    # Check whether RGB values are 16 or 8 bit per channel
    if (len(raw_col) != 6) and (len(raw_col) != 12):
        raise ParseException()

    # Convert RGB hex strings into numbers
    if len(raw_col) == 6:
        col_data = ColData(int(raw_col[0:2], 16), int(raw_col[2:4], 16), int(raw_col[4:], 16), c)
    else:
        red = int(raw_col[0:4], 16) // 256
        green = int(raw_col[4:8], 16) // 256
        blue = int(raw_col[8:], 16) // 256
        col_data = ColData(red, green, blue, c) 

    return (col_data, c)

# Parse an XPM file
def read_xpm(in_file, all_colors):
    # This holds a dictionary which maps the stand in character to
    # the colour data, i.e. a ColData object.
    local_cols = {}

    with open(in_file, "r") as f:
        lines = f.readlines()

    if lines[0].strip() != '/* XPM */':
        raise ParseException()

    col_def = clean_up(lines[2])

    col_def = col_def.split(" ")
    if len(col_def) !=  4:
        raise ParseException()

    # Parse line with colour and format definitions.
    # Example "8 8 6 1", => 8 by 8 pixels, 6 colours one standin char per colour
    col_def = ColDefs(col_def[0], col_def[1], col_def[2], col_def[3])

    if col_def.char_width != 1:
        raise ParseException()

    # parse colour definition lines
    for i in range(col_def.num_cols):
        col_data, char = parse_color(lines[3 + i])
        local_cols[char] = col_data
        # Add the ColData object to the global dict of all colours. This maps
        # the 24 bit RGB value to a ColData object.
        all_colors[col_data.col] = col_data

    pic_data = []

    # Parse pixel data. There are col_def.y_size lines of pixel data
    for i in range(col_def.y_size):
        data = clean_up(lines[3 + col_def.num_cols + i])
        # check that line length matches excpected value
        if len(data) != col_def.x_size:
            raise ParseException()
        
        pic_line = []

        # map standin character to 24 bit colour value
        for p in data:
            pic_line.append(local_cols[p].col)
        
        pic_data.append(pic_line)
    
    # Check that we have read all lines
    if len(pic_data) != col_def.y_size:
        raise ParseException()
    
    return pic_data, all_colors


def gen_asm(all_tiles, all_cols, col_offset, tile_offset):
    # determine all 24 bit colour values which we have seen in the XPM files    
    col_nums = list(all_cols.keys())
    col_nums.sort()
    # number these colours from 0 to len(all_cols.keys())-1
    count = 0
    for i in col_nums:
        if i != 0xFFFFFF:
            # Create a symbolic label
            all_cols[i].label = f"TC{count}"
        else:
            # White means that the tile is transparent at this pixel. Do not
            # create a label simply use the value
            all_cols[i].label = "0"
        count += 1

    # Write a file which creates a 64tass label for each nonzero colour. The label value holds the
    # colour number in the F256 graphics CLUT. The colour number simply is the position in col_nums.
    with open("auto_cols.inc", "w") as f:
        for i in range(len(col_nums)):
            col_obj = all_cols[col_nums[i]]
            if col_obj.label != '0':
                f.write(f"{col_obj.label} = {col_offset + i}\n")


    # Write a file which maps the CLUT colour number to an RGB value and modifies the F256 graphics
    # CLUT accordingly
    with open("auto_clut.inc", "w") as f:
        for i in range(len(col_nums)):
            col_obj = all_cols[col_nums[i]]
            if col_obj.label != '0':
                f.write(f"    #setGfxColAlternate {col_obj.label}, ${all_cols[col_nums[i]].col:06x}\n")

    tile_count = tile_offset

    # Write a file which contains the pixel data. Each pixel is represented by the colour number
    # label as defined above.
    with open("auto_tiles.inc", "w") as f:
        # iterate over all tiles
        for i in all_tiles.keys():
            name = i.upper()
            f.write("\n")
            f.write(f"{name}_TILE = {tile_count}\n")
            f.write(f"{name}\n")
            # iterate over all lines
            for line in all_tiles[i]:
                help = "    .byte "
                # iterate over values in one line
                for pixel_value in line:
                    help = help + f"{all_cols[pixel_value].label}, "
                    # remove last ', '
                f.write(f"{help[:-2]}\n")
            tile_count += 1


def process_xpms(file_names):
    # First colour number which can be assigned automatically
    COL_OFFSET = 7
    # First tile number which can be assigned automatically
    TILE_OFFSET = 5
    all_cols = {}
    # data of all tiles. Maps the name of the tile to the pixel data
    all_tiles = {}

    # process all files
    for i in file_names:
        tile, new_cols = read_xpm(i, all_cols)
        all_tiles[i[:-4]] = tile
        all_cols = new_cols
    
    gen_asm(all_tiles, all_cols, COL_OFFSET, TILE_OFFSET)


if __name__ == '__main__':
    process_xpms(sys.argv[1:])