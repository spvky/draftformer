package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"

ROOM_COLOR :rl.Color: {0,86,214,255}
ROOM_COLOR_COLLIDING: rl.Color: {128,4,4,255}
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
	if room, ok := sa.get_ptr_safe(&map_state.rooms, map_state.held_room_index); ok {
		if rl.IsKeyPressed(.E) {
			new_rotation := room.rotation + 1
			if new_rotation > 3 {
				new_rotation = 0
			}
			room.rotation = new_rotation
			tile_iter := tile_make_iter(room.tiles, map_state.cursor_position, new_rotation)
			for tile in iter_tiles(&tile_iter) {
				fmt.printfln("Tile true pos: %v", tile)
			}
		}

		if rl.IsKeyPressed(.Q) {
			new_rotation := room.rotation - 1
			if new_rotation < 0 {
				new_rotation = 3
			}
			room.rotation = new_rotation
		}
	}
}

tiles_colliding :: proc(map_state: MapScreenState, tile_iterator: ^TileIter) -> bool {
	for tile in iter_tiles(tile_iterator) {
		if tile.x < 0 || tile.y < 0 || tile.x > 9 || tile.y > 9 do return true
		for position in map_state.occupied_tiles {
			if tile == position   {
				return true
			}
		}
	}
	return false
}

place_room :: proc(map_state: ^MapScreenState) -> bool {
	room, ok := get_held_room_ptr(map_state)
	if !ok do return false
	tile_iterator := tile_make_iter(room.tiles, map_state.cursor_position, room.rotation)
	collision := tiles_colliding(map_state^, &tile_iterator)

	if collision do return false

	for tile in iter_tiles(&tile_iterator) {
		map_state.occupied_tiles[tile] = {}
	}
	sa.append(&map_state.display_map.placed_rooms, PlacedRoom{room =room^, origin = map_state.cursor_position})
	increase_held_index(map_state)
	room.placed =  true
	return true
}

pickup_room :: proc(map_state: ^MapScreenState, room: ^MapRoom) {
	tile_iterator := tile_make_iter(tiles = room.tiles, rotation = room.rotation)
	for tile in iter_tiles(&tile_iterator) {
		delete_key(&map_state.occupied_tiles, tile)
	}
	room.placed =  false
}

draw_map_room :: proc(map_state: MapScreenState, room: MapRoom) {
	tile_iterator := tile_make_iter(tiles = room.tiles, origin = map_state.cursor_position, rotation = room.rotation)
	collision := tiles_colliding(map_state, &tile_iterator)

	for tile in iter_tiles(&tile_iterator) {
		position:= MAP_OFFSET + tile_to_vec(tile)
		rl.DrawRectangleV(position + SHADOW_OFFSET, TILE_SIZE, ROOM_SHADOW )
	}

	for tile in iter_tiles(&tile_iterator) {
		exits := get_tile_exits(tile, tile_iterator.tiles)
		position:= MAP_OFFSET + tile_to_vec(tile)
		rl.DrawRectangleV(position, TILE_SIZE, collision ? ROOM_COLOR_COLLIDING : ROOM_COLOR)

	}
}
