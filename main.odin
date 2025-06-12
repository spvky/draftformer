package main

import rl "vendor:raylib"

Vec2 :: [2]f32

SCREEN_WIDTH :: 1600
SCREEN_HEIGHT :: 900

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Draftformer")
	defer rl.CloseWindow()
	map_state: MapScreenState

	main_block: for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({255,211,172,255})

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
			move_cursor(&map_state,cursor_movement)
		}

		draw_map(map_state)
		rl.EndDrawing()
	}
}

