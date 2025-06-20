package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"

// Rotate the room currently being held by the player
rotate_room :: proc(world: ^World, map_state: ^MapScreenState) {
	if room_ptr, ok := get_held_room_ptr(world, map_state); ok {
		if rl.IsKeyPressed(.E) {
			new_rotation := room_ptr.rotation + 1
			if new_rotation > 3 {
				new_rotation = 0
			}
			room_ptr.rotation = new_rotation
		}

		if rl.IsKeyPressed(.Q) {
			new_rotation := room_ptr.rotation - 1
			if new_rotation < 0 {
				new_rotation = 3
			}
			room_ptr.rotation = new_rotation
		}
	}
}

// Check if the held room would be OOB or colliding with placed tiles
tiles_colliding :: proc(world: ^World, cell_iterator: ^CellIter) -> bool {
	for cell in iter_cell(cell_iterator) {
		tile := cell.location
		if tile.x < 0 || tile.y < 0 || tile.x > 9 || tile.y > 9 do return true
		for position in world.occupied_tiles {
			if tile == position   {
				return true
			}
		}
	}
	return false
}

// Place the currently held room on the map
place_room :: proc(world: ^World, map_state: ^MapScreenState) -> bool {
	room_ptr, ok := get_held_room_ptr(world, map_state)
	if !ok {
		return false
	}
	cell_iterator := cell_make_iter(room_ptr.cells, map_state.cursor_position, room_ptr.rotation)
	collision := tiles_colliding(world, &cell_iterator)

	if collision do return false

	for cell in iter_cell(&cell_iterator) {
		world.occupied_tiles[cell.location] = {}
	}
	sa.append(&world.placed_rooms, PlacedRoomEntry{room_ptr=room_ptr, origin = map_state.cursor_position})
	sa.unordered_remove(&world.held_rooms, map_state.held_room_index)
	if sa.len(world.held_rooms) == 0 {
		map_state.mode = .Selection
	} else {
		increase_held_index(world,map_state)
	}

	return true
}
