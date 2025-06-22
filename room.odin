package main

import "core:fmt"
import rl "vendor:raylib"
import sa "core:container/small_array"
import l "core:math/linalg"

MapRoom :: struct {
	cells: CellArray,
	name: RoomTag,
	rotation: i8, // 0 = 0, 1 = 90, 2 = 180, 3 = 270
	placed: bool,
	static: bool,
	unlocked: bool,
}

WorldRoom :: struct {
	tag: RoomTag,
	position: Vec2,
	rotation: f32
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

draw_map_room :: proc(world: ^World, map_state: ^MapScreenState, room: ^MapRoom) {
	cell_iterator := cell_make_iter(cells = room.cells, origin = map_state.cursor_position, rotation = room.rotation)
	collision := tiles_colliding(world, &cell_iterator)

	for cell in iter_cell(&cell_iterator) {
		position:= MAP_OFFSET + map_tile_to_vec(cell.location)
		rl.DrawRectangleV(position + SHADOW_OFFSET, MAP_TILE_SIZE, ROOM_SHADOW )
	}

	for cell in iter_cell(&cell_iterator) {
		position:= MAP_OFFSET + map_tile_to_vec(cell.location)
		color := collision ? ROOM_COLOR_COLLIDING : ROOM_COLOR
		color.a = PLACEMENT_OPACITY
		rl.DrawRectangleV(position, MAP_TILE_SIZE, color)
		draw_cell_contents(cell)
	}
}

draw_world_rooms :: proc(world: ^World, atlas: ^TextureAtlas) {
	length := sa.len(world.placed_world_rooms)
	for i in 0..<length {
		room := sa.get(world.placed_world_rooms, i)
		pos:= room.position
		tex := atlas.room_textures[room.tag]
		rl.DrawTexturePro(
			tex,
			{x = 0, y = 0, width = f32(tex.width), height = f32(tex.height)},
			{x = pos.x, y = pos.y, width = f32(tex.width), height = f32(tex.height)},
			{48,48}, 
			room.rotation, 
			rl.WHITE)
	}
}
