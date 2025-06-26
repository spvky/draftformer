package main

import rl "vendor:raylib"
PLACEMENT_OPACITY :: 100
// Smallest intgrid size
WORLD_PIXEL_SIZE :: [2]f32 {8,8}
// Drawing size for a cell on the map
MAP_TILE_SIZE :: [2]f32 {48,48}
// Drawing size for a cell on the world map
WORLD_CELL_SIZE :: [2]f32 {96,96}
// How much to offset the dropshadow on the map placement screen
SHADOW_OFFSET :: [2]f32{-10,10}
// Color for placement mode drop shadow
ROOM_SHADOW :rl.Color:{0,0, 0, 50}
// Base color for rooms in map placement
ROOM_COLOR :rl.Color: {0,86,214,255}
// Base color for rooms when they cannot be placed
ROOM_COLOR_COLLIDING: rl.Color: {128,4,4,255}
// Where the map starts
MAP_OFFSET :Vec2 : {400,200}
