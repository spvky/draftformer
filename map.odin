package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"

MapScreenState :: struct {
	show_map: bool,
	mode: enum{Placement, Selection},
	cursor_position: Tile,
	cursor_displayed_vec_pos: Vec2,
	cursor_vec_pos: Vec2,
	held_room_index: int,
	dirty: bool,
}

increase_held_index :: proc(world: ^World, state: ^MapScreenState) {
	length:= sa.len(world.held_rooms)
	new_index:= state.held_room_index + 1
	iter_count:= 1
	if new_index >= length do new_index = 0


	for iter_count < length {
		if _, ok := sa.get_safe(world.held_rooms, new_index); ok {
			state.held_room_index = new_index
		}
		iter_count += 1
		new_index += 1
		if new_index >= length do new_index = 0
	}
	return
}

decrease_held_index :: proc(world: ^World, state: ^MapScreenState) {
	length:= sa.len(world.placed_map_rooms)
	new_index:= state.held_room_index - 1
	iter_count:= 1
	if new_index < 0 do new_index = length - 1
	
	for iter_count < length {
		if _, ok := sa.get_safe(world.held_rooms, new_index); ok {
			state.held_room_index = new_index
		}
		iter_count += 1
		new_index -= 1
		if new_index < 0 do new_index = length - 1
	}
	return
}

draw_map :: proc(world: ^World, map_state: ^MapScreenState, cursor_sprite: ^rl.Texture2D) {
	draw_map_grid()
	draw_placed_map_rooms(world)
	draw_cursor(world,map_state,cursor_sprite)
}

make_map_state :: proc() -> MapScreenState {
	starting_pos:= map_tile_to_screen_pos(Tile{0,0})
	occupied_tiles:= make(map[Tile]bool, 100)

	return MapScreenState {
		cursor_displayed_vec_pos = starting_pos,
		cursor_vec_pos = starting_pos,
	}
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


	map_state.cursor_vec_pos = map_tile_to_screen_pos(map_state.cursor_position)
}

// Cycle through available rooms
select_room :: proc(world: ^World, map_state: ^MapScreenState) {
	if rl.IsKeyPressed(.F) do increase_held_index(world, map_state)
	if rl.IsKeyPressed(.G) do increase_held_index(world, map_state)
}

// Handles the cursor lerping to it's desired location
handle_cursor :: proc(map_state: ^MapScreenState, frametime: f32) {
	if l.distance(map_state.cursor_displayed_vec_pos, map_state.cursor_vec_pos) > 1.0 {
		map_state.cursor_displayed_vec_pos = l.lerp(map_state.cursor_displayed_vec_pos, map_state.cursor_vec_pos, frametime * 20)
	} else {
		map_state.cursor_displayed_vec_pos = map_state.cursor_vec_pos
	}
}

toggle_map :: proc(world: ^World, map_state: ^MapScreenState) {
	if rl.IsKeyPressed(.M) {
		if map_state.show_map {
			bake_rooms(world, map_state)
		}
		map_state.show_map = !map_state.show_map
	}
}
map_controls :: proc(world: ^World, map_state: ^MapScreenState, frametime: f32) {
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
		switch map_state.mode {
			case .Placement:
				place_room(world,map_state)
			case .Selection:
		}
	}
	select_room(world, map_state)
	rotate_room(world,map_state)
	handle_cursor(map_state, frametime)
}


draw_cursor :: proc(world: ^World, state: ^MapScreenState, cursor_sprite: ^rl.Texture2D) {
	switch state.mode {
		case .Placement:
			if room, ok := get_held_room_ptr(world,state); ok {
				draw_map_room(world,state,room)
			}
		case .Selection:
			rl.DrawTextureV(cursor_sprite^, state.cursor_displayed_vec_pos, rl.WHITE)
	}
}

draw_placed_map_rooms :: proc(world: ^World) {
	for i in 0..<sa.len(world.placed_map_rooms) {
		placed_room := sa.get(world.placed_map_rooms, i)
		cell_iter := cell_make_iter(cells = placed_room.room_ptr.cells, origin = placed_room.origin, rotation = placed_room.room_ptr.rotation)
		for cell in iter_cell(&cell_iter) {
			position:= MAP_OFFSET + map_tile_to_vec(cell.location)
			rl.DrawRectangleV(position, MAP_TILE_SIZE, ROOM_COLOR)
			draw_cell_contents(cell)
		}
	}
}


draw_map_grid :: proc() {
	rl.DrawRectangleV(MAP_OFFSET, {MAP_TILE_SIZE.x * 10,MAP_TILE_SIZE.y * 10}, {128,128,128,100})
}


