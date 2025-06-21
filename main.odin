package main

import "core:fmt"
import "core:mem"
import sa "core:container/small_array"
import rl "vendor:raylib"

Vec2 :: [2]f32

SCREEN_WIDTH :: 1600
SCREEN_HEIGHT :: 900
game_state := GameState{mode = .Map}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				for _, entry in track.allocation_map {
					fmt.eprintf("%v leaked % bytes\n", entry.location, entry.size)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	// Create Window
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Draftformer")
	defer rl.CloseWindow()

	// Load Textures
	cursor:= rl.LoadTexture("./sprites/cursor.png")

	// Build our cameras
	gameplay_camera: rl.Camera2D
	map_screen:= rl.LoadRenderTexture(SCREEN_WIDTH * 0.75, SCREEN_HEIGHT)

	// Create the game state
	map_state:= make_map_state()
	world := make_world()
	atlas := make_texture_atlas()
	defer delete_world(world)

	main_block: for !rl.WindowShouldClose() {

		frametime:= rl.GetFrameTime()

		toggle_map(&world, &map_state)
		if map_state.show_map {
			map_controls(&world,&map_state, frametime)
		}

		// Map Screen pass
		rl.BeginTextureMode(map_screen)
		map_screen_pass: {
			rl.ClearBackground({255,211,172,255})
			draw_map(&world, &map_state, &cursor)
		}
		rl.EndTextureMode()

		// Drawing to the actual screen
		rl.BeginDrawing()

		rl.BeginMode2D(gameplay_camera)
		rl.ClearBackground(rl.BLACK)
		rl.EndMode2D()

		draw_world_rooms(&world, &atlas)

		if map_state.show_map {
		rl.DrawTexturePro(
			map_screen.texture,
			rl.Rectangle{x = 250, y = 50, width = 780, height = -780},
			rl.Rectangle{x = 550, y = 200, width = 500, height = 500},
			{0,0},
			0,
			rl.WHITE
		)
		}
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
	rl.UnloadRenderTexture(map_screen)
}

