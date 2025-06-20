package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"


RoomArray :: sa.Small_Array(40, MapRoom)

MapRoom :: struct {
	area: AreaTag,
	cells: CellArray,
	name: string,
	rotation: i8, // 0 = 0, 1 = 90, 2 = 180, 3 = 270
	placed: bool,
	static: bool
}

RoomTag :: enum {
	A,
	B,
	C,
	D,
	E
}

Cell :: struct {
	location: Tile,
	pixels: [12][12]u8
}
CellArray :: sa.Small_Array(20,Cell)

rotate_room :: proc(map_state: ^MapScreenState) {
	if room, ok := sa.get_ptr_safe(&map_state.rooms, map_state.held_room_index); ok {
		if rl.IsKeyPressed(.E) {
			new_rotation := room.rotation + 1
			if new_rotation > 3 {
				new_rotation = 0
			}
			room.rotation = new_rotation
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

tiles_colliding :: proc(map_state: MapScreenState, cell_iterator: ^CellIter) -> bool {
	for cell in iter_cell(cell_iterator) {
		tile := cell.location
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
	cell_iterator := cell_make_iter(room.cells, map_state.cursor_position, room.rotation)
	collision := tiles_colliding(map_state^, &cell_iterator)

	if collision do return false

	for cell in iter_cell(&cell_iterator) {
		map_state.occupied_tiles[cell.location] = {}
	}
	sa.append(&map_state.display_map.placed_rooms, PlacedRoom{room =room^, origin = map_state.cursor_position})
	increase_held_index(map_state)
	room.placed =  true
	return true
}

pickup_room :: proc(map_state: ^MapScreenState, room: ^MapRoom) {
	cell_iterator := cell_make_iter(cells = room.cells, rotation = room.rotation)
	for cell in iter_cell(&cell_iterator) {
		delete_key(&map_state.occupied_tiles, cell.location)
	}
	room.placed =  false
}

draw_map_room :: proc(map_state: MapScreenState, room: MapRoom) {
	cell_iterator := cell_make_iter(cells = room.cells, origin = map_state.cursor_position, rotation = room.rotation)
	collision := tiles_colliding(map_state, &cell_iterator)

	for cell in iter_cell(&cell_iterator) {
		position:= MAP_OFFSET + tile_to_vec(cell.location)
		rl.DrawRectangleV(position + SHADOW_OFFSET, TILE_SIZE, ROOM_SHADOW )
	}

	for cell in iter_cell(&cell_iterator) {
		position:= MAP_OFFSET + tile_to_vec(cell.location)
		color := collision ? ROOM_COLOR_COLLIDING : ROOM_COLOR
		color.a = PLACEMENT_OPACITY
		rl.DrawRectangleV(position, TILE_SIZE, color)
		draw_cell_contents(cell)

	}
}
