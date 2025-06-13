package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"

AreaTag :: enum {
	Basic,
	Tech,
	Sewer,
	Engine,
}

MapRegion :: struct {
	filled_positions: TileSet,
	rooms: MapRoom,
}

MapScreenState :: struct {
	cursor_position: Tile,
	cursor_displayed_vec_pos: Vec2,
	cursor_vec_pos: Vec2,
	rooms: RoomArray,
	rooms_iter: RoomIter,
	held_room_index: int,
	occupied_tiles: TileSet
}

get_held_room :: proc(state: MapScreenState) -> (val: MapRoom, cond: bool) {
	room, ok := sa.get_safe(state.rooms, state.held_room_index); if ok {
		val = room
		cond = true
	}
	return
}
get_held_room_ptr :: proc(state: ^MapScreenState) -> (val: ^MapRoom, cond: bool) {
	room, ok := sa.get_ptr_safe(&state.rooms, state.held_room_index); if ok {
		val = room
		cond = true
	}
	return
}
increase_held_index :: proc(state: ^MapScreenState) {
	length:= sa.len(state.rooms)
	new_index:= state.held_room_index + 1
	iter_count:= 1
	if new_index >= length do new_index = 0
	
	for iter_count < length {
		if room, ok := sa.get_safe(state.rooms, new_index); ok && !room.placed {
			fmt.printfln("New index of %v set", new_index)
			state.held_room_index = new_index
			return
		}
		iter_count += 1
		new_index += 1
		if new_index >= length do new_index = 0
	}
	fmt.println("No valid index found")
	return
}
decrease_held_index :: proc(state: ^MapScreenState) {
	length:= sa.len(state.rooms)
	new_index:= state.held_room_index - 1
	iter_count:= 1
	if new_index >= length do new_index = 0
	
	for iter_count < length {
		if room, ok := sa.get_safe(state.rooms, new_index); ok && !room.placed {
			fmt.printfln("New index of %v set", new_index)
			state.held_room_index = new_index
			return
		}
		iter_count += 1
		new_index -= 1
		if new_index < 0 do new_index = length - 1
	}
	fmt.println("No valid index found")
	return
}

draw_map :: proc(map_state: MapScreenState) {
	draw_map_grid()
	draw_cursor(map_state)
}

make_map_state :: proc() -> MapScreenState {
	starting_pos:= tile_to_screen_pos(Tile{0,0})
	occupied_tiles:= make(map[Tile]bool, 100)
	room_1:= room_make(
		{0,0},
		{1,0},
		{2,0},
		{3,0},
		{3,-1},
		{0,-1},
		{2,1}
	)

	room_2:= room_make(
		{0,0},
		{1,0},
		{2,0},
		{3,0},
		{4,0},
		{4,-1},
		{4,-2}
	)

	rooms: RoomArray
	sa.append_elems(&rooms, room_1, room_2)
	return MapScreenState {
		cursor_displayed_vec_pos = starting_pos,
		cursor_vec_pos = starting_pos,
		rooms = rooms,
	}
}

delete_map_state :: proc(map_state: MapScreenState) {
	delete(map_state.occupied_tiles)
}

move_cursor :: proc(using map_state: ^MapScreenState, delta: Tile) {
	cursor_position += delta
	if cursor_position.x < 0 {
		cursor_position.x = 0
	}

	if cursor_position.x > 9 {
		cursor_position.x = 9
	}

	if cursor_position.y < 0 {
		cursor_position.y = 0
	}

	if cursor_position.y > 9 {
		cursor_position.y = 9
	}


	map_state.cursor_vec_pos = tile_to_screen_pos(map_state.cursor_position)
}

select_room :: proc(map_state: ^MapScreenState) {
	if rl.IsKeyPressed(.F) do increase_held_index(map_state)
	if rl.IsKeyPressed(.G) do increase_held_index(map_state)
}


draw_cursor :: proc(map_state: MapScreenState) {
	if room, ok := sa.get_safe(map_state.rooms,map_state.held_room_index); ok {
		draw_map_room(map_state.cursor_displayed_vec_pos, room)
	} else {
	rl.DrawRectangleV(map_state.cursor_displayed_vec_pos, TILE_SIZE, {0,0,0,100})
	rl.DrawRectangleV(map_state.cursor_displayed_vec_pos + SHADOW_OFFSET, TILE_SIZE, {0,86,214,255})
	}
}

draw_map_grid :: proc() {
	rl.DrawRectangleV({400,200}, {TILE_SIZE.x * 10,TILE_SIZE.y * 10}, {128,128,128,100})
}

handle_cursor :: proc(map_state: ^MapScreenState, frametime: f32) {
	if l.distance(map_state.cursor_displayed_vec_pos, map_state.cursor_vec_pos) > 2.0 {
		map_state.cursor_displayed_vec_pos = l.lerp(map_state.cursor_displayed_vec_pos, map_state.cursor_vec_pos, frametime * 20)
	} else {
		map_state.cursor_displayed_vec_pos = map_state.cursor_vec_pos
	}
}

