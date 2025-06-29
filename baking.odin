package main

import "core:fmt"
import sa "core:container/small_array"

bake_rooms :: proc(world: ^World, state: ^MapScreenState) {
	if !state.dirty do return
	
	// Clear out the currently placed rooms in the world
	sa.clear(&world.placed_world_rooms)
	sa.clear(&world.static_colliders)
	placed_length := sa.len(world.placed_map_rooms)
	for i in 0..<placed_length {
		map_room := sa.get(world.placed_map_rooms, i)
		vec_origin := Vec2{f32(map_room.origin.x) * WORLD_CELL_SIZE.x, f32(map_room.origin.y) * WORLD_CELL_SIZE.y}
		world_room := WorldRoom {
			tag = map_room.room_ptr.name,
			position = vec_origin,
			rotation = f32(map_room.room_ptr.rotation) * 90,
		}
		sa.append(&world.placed_world_rooms, world_room)
		build_room_colliders(world, map_room)
	}


	
	state.dirty = false
}

build_room_colliders :: proc(world: ^World, placed_room: PlacedRoomEntry) {
	room := placed_room.room_ptr^
	cells_length := sa.len(room.cells)
	PixelRange :: struct {y_value: int, start: int, end: int}

	aabb_from_range :: proc(origin: Vec2, range: PixelRange) -> AABB {
		aabb: AABB
		aabb.min = {f32(range.start) * WORLD_PIXEL_SIZE.x, f32(range.y_value) * WORLD_PIXEL_SIZE.y} + origin
		aabb.max = {f32(range.end + 1) * WORLD_PIXEL_SIZE.x, f32(range.y_value + 1) * WORLD_PIXEL_SIZE.y} + origin
		return aabb
	}


	cell_iter := cell_make_iter(cells = room.cells, origin = placed_room.origin, rotation = room.rotation)
	for cell in iter_cell(&cell_iter) {
		cell_origin := Vec2{f32(cell.location.x) * WORLD_CELL_SIZE.x, f32(cell.location.y) * WORLD_CELL_SIZE.y}
		vec_origin := Vec2{f32(placed_room.origin.x) * WORLD_CELL_SIZE.x, f32(placed_room.origin.y) * WORLD_CELL_SIZE.y}
		adjusted_origin := cell_origin - (WORLD_CELL_SIZE / 2)
		for i in 0..<12 {
			current_range: Maybe(PixelRange)
			for j in 0 ..<12 {
				switch cell.pixels[i][j] {
					case 1:
						if range, ok := &current_range.?; ok {
							range.end = j
							if j == 11 {
								sa.append(&world.static_colliders, aabb_from_range(adjusted_origin, range^))
								current_range = nil
							}
						} else {
							current_range = PixelRange {y_value = i, start = j, end = j}
							if j == 11 {
								sa.append(&world.static_colliders, aabb_from_range(adjusted_origin,current_range.?))
								current_range = nil
							}
						}
					case:
						if range, ok := &current_range.?; ok {
							sa.append(&world.static_colliders, aabb_from_range(adjusted_origin,range^))
							current_range = nil
						}
				}
			}
		}
	}
}
