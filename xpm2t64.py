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


def parse_color(data):
    if (data[1] == ',') or (data[1] == ';'):
        raise ParseException()

    data = remove_chars(data)

    if (data[2] != 'c') or (data[4] != '#'):
        raise ParseException()

    c = data[0]
    raw_col = data[5:].strip()

    if (len(raw_col) != 6) and (len(raw_col) != 12):
        raise ParseException()

    if len(raw_col) == 6:
        col_data = ColData(int(raw_col[0:2], 16), int(raw_col[2:4], 16), int(raw_col[4:], 16), c)
    else:
        red = int(raw_col[0:4], 16) // 256
        green = int(raw_col[4:8], 16) // 256
        blue = int(raw_col[8:], 16) // 256
        col_data = ColData(red, green, blue, c) 

    return (col_data, c)


def read_xpm(in_file, all_colors):
    local_cols = {}

    with open(in_file, "r") as f:
        lines = f.readlines()

    if lines[0].strip() != '/* XPM */':
        raise ParseException()

    col_def = clean_up(lines[2])

    col_def = col_def.split(" ")
    if len(col_def) !=  4:
        raise ParseException()

    col_def = ColDefs(col_def[0], col_def[1], col_def[2], col_def[3])

    if col_def.char_width != 1:
        raise ParseException()

    for i in range(col_def.num_cols):
        col_data, char = parse_color(lines[3 + i])
        local_cols[char] = col_data
        all_colors[col_data.col] = col_data

    pic_data = []

    for i in range(col_def.y_size):
        data = clean_up(lines[3 + col_def.num_cols + i])
        if len(data) != col_def.x_size:
            raise ParseException()
        
        pic_line = []

        for p in data:
            pic_line.append(local_cols[p].col)
        
        pic_data.append(pic_line)
    
    if len(pic_data) != col_def.y_size:
        raise ParseException()
    
    return pic_data, all_colors


def gen_asm(all_tiles, all_cols, col_offset, tile_offset):    
    col_nums = list(all_cols.keys())
    col_nums.sort()
    count = 0
    for i in col_nums:
        if i != 0xFFFFFF:
            all_cols[i].label = f"TC{count}"
        else:
            all_cols[i].label = "0"
        count += 1

    with open("auto_cols.inc", "w") as f:
        for i in range(len(col_nums)):
            col_obj = all_cols[col_nums[i]]
            if col_obj.label != '0':
                f.write(f"{col_obj.label} = {col_offset + i}\n")


    with open("auto_clut.inc", "w") as f:
        for i in range(len(col_nums)):
            col_obj = all_cols[col_nums[i]]
            if col_obj.label != '0':
                f.write(f"    #setGfxColAlternate {col_obj.label}, ${all_cols[col_nums[i]].col:06x}\n")

    tile_count = tile_offset

    with open("auto_tiles.inc", "w") as f:
        for i in all_tiles:
            name = i[0].upper()
            f.write("\n")
            f.write(f"{name}_TILE = {tile_count}\n")
            f.write(f"{name}\n")
            for j in i[1]:
                help = "    .byte "
                for l in j:
                    help = help + f"{all_cols[l].label}, "
                f.write(f"{help[:-2]}\n")
            tile_count += 1


if __name__ == '__main__':
    COL_OFFSET = 7
    TILE_OFFSET = 5
    all_cols = {}    
    all_tiles = []
    for i in sys.argv[1:]:
        tile, new_cols = read_xpm(i, all_cols)
        all_tiles.append((i[:-4], tile))
        all_cols = new_cols
    
    gen_asm(all_tiles, all_cols, COL_OFFSET, TILE_OFFSET)
    