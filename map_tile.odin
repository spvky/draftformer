package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"

TILE_SIZE :: [2]f32 {64,64}
SHADOW_OFFSET :: [2]f32{-10,10}

Tile :: [2]i16
TileArray :: sa.Small_Array(100,Tile)
TileSet :: map[Tile]struct{}

// Struct for easily iterating tiles, while respecting rotation
TileIter :: struct {
	tiles: TileArray,
	rotation: i8,
	origin: Tile,
	index: int,
}

// Create a tile iter from a Small_Array(Tile)
tile_make_iter :: proc(tiles: TileArray, origin: Tile = {0,0}, rotation: i8 = 0) -> TileIter {
	return TileIter {tiles = tiles, origin = origin, rotation = rotation}
}

// Iterate through a tile iter, notably does not consume the iter
iter_tiles :: proc(it: ^TileIter) -> (val: Tile, cond: bool) {
	in_range := it.index < sa.len(it.tiles)

	for in_range {
		raw_val := sa.get(it.tiles, it.index)
		switch it.rotation {
			case 0:
				val = it.origin + raw_val
			case 1:
				val = it.origin + {-raw_val.y, raw_val.x}
			case 2:
				val = it.origin + {-raw_val.x, -raw_val.y}
			case 3:
				val = it.origin + {raw_val.y, -raw_val.x}
		}
		cond = true
		it.index += 1
		return
	}

	// When we have no more tiles left to iterate, reset the index, to allow reuse of the iterator
	it.index = 0
	return
}


tile_to_vec :: proc(tile: Tile) -> Vec2 {
	return Vec2{f32(tile.x)  * TILE_SIZE.x, f32(tile.y) * TILE_SIZE.y}
}

tile_to_screen_pos :: proc(tile: Tile) -> Vec2 {
	map_start:= Vec2{400,200}
	return map_start + tile_to_vec(tile)
}
