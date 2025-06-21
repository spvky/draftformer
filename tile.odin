package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"


Tile :: [2]i16

CellIter :: struct {
	cells: CellArray,
	rotation: i8,
	origin: Tile,
	index: int,
}

// Create a cell iter from a Small_Array(Cell)
cell_make_iter :: proc(cells: CellArray, origin: Tile = {0,0}, rotation: i8 = 0) -> CellIter {
	return CellIter {cells = cells, origin = origin, rotation = rotation}
}

// Iterate through a cell iter, notably does not consume the iter
iter_cell :: proc(it: ^CellIter) -> (val: Cell, cond: bool) {
	in_range := it.index < sa.len(it.cells)

	for in_range {
		cell := sa.get(it.cells, it.index)
		cell_pixels := cell.pixels
		raw_val:= cell.location
		location: Tile
		switch it.rotation {
			case 0:
				 location = it.origin + raw_val
			case 1:
				location = it.origin + {-raw_val.y, raw_val.x}
				rotate_pixels90(&cell_pixels)
			case 2:
				location = it.origin + {-raw_val.x, -raw_val.y}
				rotate_pixels90(&cell_pixels)
				rotate_pixels90(&cell_pixels)
			case 3:
				location = it.origin + {raw_val.y, -raw_val.x}
				rotate_pixels90(&cell_pixels)
				rotate_pixels90(&cell_pixels)
				rotate_pixels90(&cell_pixels)
		}
		cond = true
		it.index += 1
		val = Cell {
			location = location, pixels = cell_pixels
		}
		return
	}

	// When we have no more tiles left to iterate, reset the index, to allow reuse of the iterator
	it.index = 0
	return
}

map_tile_to_vec :: proc(tile: Tile) -> Vec2 {
	return Vec2{f32(tile.x)  * MAP_TILE_SIZE.x, f32(tile.y) * MAP_TILE_SIZE.y}
}

map_tile_to_screen_pos :: proc(tile: Tile) -> Vec2 {
	map_start:= Vec2{400,200}
	return map_start + map_tile_to_vec(tile)
}

draw_cell_contents :: proc(cell: Cell) {
	tile:= cell.location
	tile_vec:= Vec2{f32(tile.x)  * MAP_TILE_SIZE.x, f32(tile.y) * MAP_TILE_SIZE.y}
	for i in 0..<12 {
		for j in 0..<12 {
			pixel:= cell.pixels[i][j]
			pixel_position:= tile_vec + Vec2{f32(j)*4,f32(i)*4} + MAP_OFFSET
			switch pixel {
			case 1:
				rl.DrawRectangleV(pixel_position,{4,4}, {255,255,255,125})
			case 3: 
				rl.DrawRectangleV(pixel_position,{4,4}, rl.YELLOW)
			}
		}
	}
}



rotate_pixels90 :: proc(pixels: ^[12][12]u8) {
    for i in 0..<12 {
        for j in i+1..<12 {
          pixels[i][j], pixels[j][i] = pixels[j][i], pixels[i][j]
        }
    }
    for i in 0..<12 {
			start, end := 0,11
			for start < end {
					pixels[i][start], pixels[i][end] = pixels[i][end], pixels[i][start]
				start += 1
				end -= 1
			}
		}
}
