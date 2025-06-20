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
	mode: enum{Placement, Selection},
	cursor_position: Tile,
	cursor_displayed_vec_pos: Vec2,
	cursor_vec_pos: Vec2,
	rooms: RoomArray,
	display_map: DisplayMap,
	held_room_index: int,
	occupied_tiles: TileSet,
	dirty: bool,
}

DisplayMap :: struct {
	placed_rooms: PlacedRoomArray
}

PlacedRoom :: struct {
	using room: MapRoom,
	origin: Tile
}

PlacedRoomArray :: sa.Small_Array(20,PlacedRoom)

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
			state.held_room_index = new_index
			return
		}
		iter_count += 1
		new_index += 1
		if iter_count == length {
			state.mode = .Selection
		}
		if new_index >= length do new_index = 0
	}
	return
}
decrease_held_index :: proc(state: ^MapScreenState) {
	length:= sa.len(state.rooms)
	new_index:= state.held_room_index - 1
	iter_count:= 1
	if new_index >= length do new_index = 0
	
	for iter_count < length {
		if room, ok := sa.get_safe(state.rooms, new_index); ok && !room.placed {
			state.held_room_index = new_index
			return
		}
		iter_count += 1
		new_index -= 1
		if new_index < 0 do new_index = length - 1
	}
	return
}

draw_map :: proc(map_state: MapScreenState, cursor_sprite: ^rl.Texture2D) {
	draw_map_grid()
	draw_placed_rooms(map_state)
	draw_cursor(map_state,cursor_sprite)
}

make_map_state :: proc() -> MapScreenState {
	starting_pos:= tile_to_screen_pos(Tile{0,0})
	occupied_tiles:= make(map[Tile]bool, 100)

	rooms: RoomArray
	sa.append_elems(&rooms,read_room(.A), read_room(.B), read_room(.C), read_room(.D), read_room(.E))
	return MapScreenState {
		cursor_displayed_vec_pos = starting_pos,
		cursor_vec_pos = starting_pos,
		rooms = rooms,
	}
}

delete_map_state :: proc(map_state: MapScreenState) {
	delete(map_state.occupied_tiles)
}

// Move the cursor around the map screen
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

// Cycle through available rooms
select_room :: proc(map_state: ^MapScreenState) {
	if rl.IsKeyPressed(.F) do increase_held_index(map_state)
	if rl.IsKeyPressed(.G) do increase_held_index(map_state)
}

// Handles the cursor lerping to it's desired location
handle_cursor :: proc(map_state: ^MapScreenState, frametime: f32) {
	if l.distance(map_state.cursor_displayed_vec_pos, map_state.cursor_vec_pos) > 1.0 {
		map_state.cursor_displayed_vec_pos = l.lerp(map_state.cursor_displayed_vec_pos, map_state.cursor_vec_pos, frametime * 20)
	} else {
		map_state.cursor_displayed_vec_pos = map_state.cursor_vec_pos
	}
}

map_controls :: proc(map_state: ^MapScreenState, frametime: f32) {
	cursor_movement: Tile
	x,y: f32

	if rl.IsKeyPressed(.A) {
		x -= 1
	}
	if rl.IsKeyPressed(.D) {
		x += 1
	}
	if rl.IsKeyPressed(.W) {
		y -= 1
	}
	if rl.IsKeyPressed(.S) {
		y += 1
	}

	if x != 0 || y != 0 { 
		cursor_movement.x = i16(x)
		cursor_movement.y = i16(y)
		move_cursor(map_state,cursor_movement)
	}

	if rl.IsKeyPressed(.ENTER) {
		can_place_room := place_room(map_state)
		if !can_place_room do fmt.println("Cannot place room")
	}
	select_room(map_state)
	rotate_room(map_state)
	handle_cursor(map_state, frametime)
}


draw_cursor :: proc(state: MapScreenState, cursor_sprite: ^rl.Texture2D) {
	switch state.mode {
		case .Placement:
			if room, ok := sa.get_safe(state.rooms,state.held_room_index); ok {
				draw_map_room(state, room)
			} else {
			rl.DrawRectangleV(state.cursor_displayed_vec_pos, TILE_SIZE, {0,0,0,100})
			rl.DrawRectangleV(state.cursor_displayed_vec_pos + SHADOW_OFFSET, TILE_SIZE, {0,86,214,255})
			}
		case .Selection:
			rl.DrawTextureV(cursor_sprite^, state.cursor_displayed_vec_pos, rl.WHITE)
	}
}

draw_placed_rooms :: proc(map_state: MapScreenState) {
	for i in 0..<sa.len(map_state.display_map.placed_rooms) {
		if placed_room, ok := sa.get_safe(map_state.display_map.placed_rooms, i); ok {
			cell_iter := cell_make_iter(cells = placed_room.cells, origin = placed_room.origin, rotation = placed_room.rotation)
			for cell in iter_cell(&cell_iter) {
				position:= MAP_OFFSET + tile_to_vec(cell.location)
				rl.DrawRectangleV(position, TILE_SIZE, ROOM_COLOR)
				draw_cell_contents(cell)
			}
		}
	}
}


draw_map_grid :: proc() {
	rl.DrawRectangleV(MAP_OFFSET, {TILE_SIZE.x * 10,TILE_SIZE.y * 10}, {128,128,128,100})
}


