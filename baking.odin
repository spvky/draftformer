package main

import sa "core:container/small_array"

bake_rooms :: proc(world: ^World, state: ^MapScreenState) {
	if !state.dirty do return
	
	// Clear out the currently placed rooms in the world
	sa.clear(&world.placed_world_rooms)
	
	placed_length := sa.len(world.placed_map_rooms)
	for i in 0..<placed_length {
		map_room := sa.get(world.placed_map_rooms, i)
		vec_origin := Vec2{f32(map_room.origin.x) * WORLD_TILE_SIZE.x, f32(map_room.origin.y) * WORLD_TILE_SIZE.y}
		world_room := WorldRoom {
			tag = map_room.room_ptr.name,
			position = vec_origin,
			rotation = f32(map_room.room_ptr.rotation) * 90,
		}
		sa.append(&world.placed_world_rooms, world_room)
	}


	
	state.dirty = false
}
