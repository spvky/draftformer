package main

import sa "core:container/small_array"

bake_rooms :: proc(world: ^World, state: ^MapScreenState) {
	if !state.dirty do return
	
	// Clear out the currently placed rooms in the world
	sa.clear(&world.placed_world_rooms)
	
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
		build_room_colliders(world, map_room.room_ptr^, vec_origin)
	}


	
	state.dirty = false
}

build_room_colliders :: proc(world: ^World, room: MapRoom, origin: Vec2) {
	cells_length := sa.len(room.cells)
	PixelRange :: struct {y_value: int, start: int, end: int}
	current_range: Maybe(PixelRange)

	collider_from_range :: proc(origin: Vec2, top_row: f32, bottom_row: f32, range: PixelRange) -> StaticCollider {
		a,b,c,d: Vec2
		a = {f32(range.start) * WORLD_PIXEL_SIZE.x,top_row} + origin
		b = {f32(range.end + 1) * WORLD_PIXEL_SIZE.x,top_row} + origin
		c = {f32(range.end + 1) * WORLD_PIXEL_SIZE.x,bottom_row} + origin
		d = {f32(range.start) * WORLD_PIXEL_SIZE.x,bottom_row} + origin
		return StaticCollider {vertices = {a,b,c,d}}
	}

	for c in 0..<cells_length {
		cell := sa.get(room.cells,c)
		for j in 0..<12 {
			top_row := f32(j) * WORLD_PIXEL_SIZE.y
			bottom_row := f32(j + 1) * WORLD_PIXEL_SIZE.y
			for i in 0 ..<12 {
				switch cell.pixels[j][i] {
					case 1:
						if range, ok := &current_range.?; ok {
							range.end = i
							if i == 11 {
								sa.append(&world.static_colliders, collider_from_range(origin, top_row, bottom_row, range^))
								current_range = nil
							}
						} else {
							current_range = PixelRange {y_value = j, start = i, end = i}
						}
					case:
						if range, ok := &current_range.?; ok {
							sa.append(&world.static_colliders, collider_from_range(origin, top_row, bottom_row, range^))
							current_range = nil
						}
				}
			}
		}
	}
}
