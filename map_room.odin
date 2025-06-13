package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"

RoomArray :: sa.Small_Array(20, MapRoom)

MapRoom :: struct {
	area: AreaTag,
	tiles: sa.Small_Array(100,Tile),
	name: string,
	rotation: i8 // 0 = 0, 1 = 90, 2 = 180, 3 = 270
}

rotate_room :: proc(map_state: ^MapScreenState) {
	if room_tile, ok := &map_state.held_tile.?; ok {
		if rl.IsKeyPressed(.E) {
			new_rotation := room_tile.rotation + 1
			if new_rotation > 3 {
				new_rotation = 0
			}
			room_tile.rotation = new_rotation
		}

		if rl.IsKeyPressed(.Q) {
			new_rotation := room_tile.rotation - 1
			if new_rotation < 0 {
				new_rotation = 3
			}
			room_tile.rotation = new_rotation
		}
	}
}

ROOM_COLOR :rl.Color: {0,86,214,255}
ROOM_SHADOW :rl.Color:{0,0, 0, 100}

draw_map_room :: proc(origin: Vec2, room: MapRoom) {
	tile_iterator := tile_make_iter(room.tiles, room.rotation)

	for tile in tile_iter(&tile_iterator) {
		position:= origin + grid_to_vec(tile)
		rl.DrawRectangleV(position + SHADOW_OFFSET, TILE_SIZE, ROOM_SHADOW )
	}

	for tile in tile_iter(&tile_iterator) {
		position:= origin + grid_to_vec(tile)
		rl.DrawRectangleV(position, TILE_SIZE, ROOM_COLOR)
	}
}
