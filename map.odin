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

TILE_SIZE :: [2]f32 {64,64}

Tile :: [2]i16

RoomTile :: struct {
	area: AreaTag,
	grid_positions: sa.Small_Array(100,Tile),
	name: string,
}

AreaMap :: struct {
	filled_positions: sa.Small_Array(10000,Tile),
	rooms: RoomTile,
}

MapScreenState :: struct {
	cursor_position: Tile,
	cursor_displayed_vec_pos: Vec2,
	cursor_vec_pos: Vec2,
	held_tile: Maybe(^RoomTile),
	occupied_tiles: map[Tile]bool
}

make_map_state :: proc() -> MapScreenState {
	starting_pos:= grid_to_screen_pos(Tile{0,0})
	occupied_tiles:= make(map[Tile]bool, 100)
	return MapScreenState {
		cursor_displayed_vec_pos = starting_pos,
		cursor_vec_pos = starting_pos,
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
	map_state.cursor_vec_pos = grid_to_screen_pos(map_state.cursor_position)
}

grid_to_vec :: proc(tile: Tile) -> Vec2 {
	return Vec2{f32(tile.x)  * TILE_SIZE.x, f32(tile.y) * TILE_SIZE.y}
}

grid_to_screen_pos :: proc(tile: Tile) -> Vec2 {
	map_start:= Vec2{400,200}
	return map_start + grid_to_vec(tile)
}

draw_cursor :: proc(map_state: MapScreenState) {
	rl.DrawRectangleV(map_state.cursor_displayed_vec_pos, TILE_SIZE, {0,0,0,100})
	rl.DrawRectangleV(map_state.cursor_displayed_vec_pos + {10,-10}, TILE_SIZE, {0,86,214,255})
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

draw_map :: proc(map_state: MapScreenState) {
	draw_map_grid()
	draw_cursor(map_state)
}


