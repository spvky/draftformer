package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"

ROOM_COLOR :rl.Color: {0,86,214,255}
ROOM_SHADOW :rl.Color:{0,0, 0, 100}

RoomArray :: sa.Small_Array(20, MapRoom)

MapRoom :: struct {
	area: AreaTag,
	tiles: sa.Small_Array(100,Tile),
	name: string,
	rotation: i8, // 0 = 0, 1 = 90, 2 = 180, 3 = 270
	placed: bool,
	static: bool
}

RoomIter :: struct {
	rooms: RoomArray,
	index: int,
}

room_make :: proc(tiles: ..Tile) -> MapRoom {
	room_tiles: sa.Small_Array(100, Tile)
	sa.append_elems(&room_tiles, ..tiles)
	return MapRoom { tiles = room_tiles}
}


rotate_room :: proc(map_state: ^MapScreenState) {
	if room_tile, ok := sa.get_ptr_safe(&map_state.rooms, map_state.held_room_index); ok {
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

valid_room_placement :: proc(map_state: MapScreenState, room: MapRoom) -> bool {
	tile_iterator := tile_make_iter(room.tiles, room.rotation)

	for tile in iter_tiles(&tile_iterator) {
		for position in map_state.occupied_tiles {
			if tile == position {
				return true
			}
		}
	}
	return false
}

place_room :: proc(map_state: ^MapScreenState, room: ^MapRoom) -> bool {
	tile_iterator := tile_make_iter(room.tiles, room.rotation)
	collision := valid_room_placement(map_state^, room^)

	if !collision do return false

	for tile in iter_tiles(&tile_iterator) {
		map_state.occupied_tiles[tile] = {}
	}
	room.placed =  true
	return true
}

pickup_room :: proc(map_state: ^MapScreenState, room: ^MapRoom) {
	tile_iterator := tile_make_iter(room.tiles, room.rotation)
	for tile in iter_tiles(&tile_iterator) {
		delete_key(&map_state.occupied_tiles, tile)
	}
	room.placed =  false
}

draw_map_room :: proc(origin: Vec2, room: MapRoom) {
	tile_iterator := tile_make_iter(room.tiles, room.rotation)

	for tile in iter_tiles(&tile_iterator) {
		position:= origin + tile_to_vec(tile)
		rl.DrawRectangleV(position + SHADOW_OFFSET, TILE_SIZE, ROOM_SHADOW )
	}

	for tile in iter_tiles(&tile_iterator) {
		position:= origin + tile_to_vec(tile)
		rl.DrawRectangleV(position, TILE_SIZE, ROOM_COLOR)
	}
}
