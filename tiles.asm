EMPTY_TILE = 0
TILE_SET_ADDR
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0

APPLE_TILE = 1
APPLE
    .byte 0,0,0,0,0,APPLE_COL,0,0
    .byte 0,0,0,0,APPLE_COL,0,0,0
    .byte 0,0,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,0
    .byte 0,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL
    .byte 0,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL    
    .byte 0,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL
    .byte 0,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL
    .byte 0,0,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,APPLE_COL,0

HEAD_R_TILE = 2
HEAD_RIGHT
    .byte HEAD_COL,HEAD_COL,0,0,HEAD_COL,HEAD_COL,HEAD_COL,0
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0,0,HEAD_COL
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0,0
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0,0
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0,0
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0,0
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0,0,HEAD_COL
    .byte HEAD_COL,HEAD_COL,0,0,HEAD_COL,HEAD_COL,HEAD_COL,0

HEAD_L_TILE = 3
HEAD_LEFT
    .byte 0,HEAD_COL,HEAD_COL,HEAD_COL,0,0,HEAD_COL,HEAD_COL
    .byte HEAD_COL,0,0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte 0,0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte 0,0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL    
    .byte 0,0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte 0,0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte HEAD_COL,0,0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte 0,HEAD_COL,HEAD_COL,HEAD_COL,0,0,HEAD_COL,HEAD_COL

HEAD_U_TILE = 4
HEAD_UP
    .byte 0,HEAD_COL,0,0,0,0,HEAD_COL,0
    .byte HEAD_COL,0,0,0,0,0,0,HEAD_COL
    .byte HEAD_COL,0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0,HEAD_COL
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte 0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0
    .byte 0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL

HEAD_D_TILE = 5
HEAD_DOWN
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte 0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0
    .byte 0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0
    .byte HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL
    .byte HEAD_COL,0,HEAD_COL,HEAD_COL,HEAD_COL,HEAD_COL,0,HEAD_COL
    .byte HEAD_COL,0,0,0,0,0,0,HEAD_COL
    .byte 0,HEAD_COL,0,0,0,0,HEAD_COL,0

SEGMENT_TILE = 6
CT_SEGMENT
    .byte SEGMENT_COL,SEG_COL2,SEG_COL2,SEG_COL2,SEG_COL2,SEG_COL2,SEG_COL2,SEGMENT_COL
    .byte SEG_COL2,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEG_COL2
    .byte SEG_COL2,SEGMENT_COL,SEG_COL2,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEG_COL2
    .byte SEG_COL2,SEGMENT_COL,SEG_COL2,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEG_COL2
    .byte SEG_COL2,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEG_COL2,SEGMENT_COL,SEG_COL2
    .byte SEG_COL2,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEG_COL2,SEGMENT_COL,SEG_COL2    
    .byte SEG_COL2,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEGMENT_COL,SEG_COL2
    .byte SEGMENT_COL,SEG_COL2,SEG_COL2,SEG_COL2,SEG_COL2,SEG_COL2,SEG_COL2,SEGMENT_COL

OBSTACLE_TILE = 7
OBSTACLE
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,OBSTACLE_COL,OBSTACLE_COL,OBSTACLE_COL,0,0
    .byte 0,0,OBSTACLE_COL,0,0,0,OBSTACLE_COL,0
    .byte 0,OBSTACLE_COL,0,0,OBSTACLE_COL,0,0,OBSTACLE_COL
    .byte 0,OBSTACLE_COL,0,OBSTACLE_COL,OBSTACLE_COL,OBSTACLE_COL,0,OBSTACLE_COL
    .byte 0,OBSTACLE_COL,0,0,OBSTACLE_COL,0,0,OBSTACLE_COL
    .byte 0,OBSTACLE_COL,0,0,OBSTACLE_COL,0,0,OBSTACLE_COL
    .byte 0,OBSTACLE_COL,OBSTACLE_COL,OBSTACLE_COL,OBSTACLE_COL,OBSTACLE_COL,OBSTACLE_COL,OBSTACLE_COL

GRASS_TILE = 8
GRASS
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,GRASS_COL,0,0
    .byte 0,0,GRASS_COL,0,GRASS_COL,0,0,0
    .byte 0,0,0,GRASS_COL,GRASS_COL,0,0,0
    .byte GRASS_COL,0,0,0,GRASS_COL,0,0,0
    .byte 0,GRASS_COL,0,0,0,0,0,0
    .byte 0,GRASS_COL,0,0,0,0,0,0