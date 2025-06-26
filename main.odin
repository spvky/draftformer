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

	gameplay_screen := rl.LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
	map_screen := rl.LoadRenderTexture(SCREEN_WIDTH * 0.75, SCREEN_HEIGHT)

	// Create the game state
	map_state:= make_map_state()
	world := make_world()
	atlas := make_texture_atlas()
	defer delete_world(world)

	main_block: for !rl.WindowShouldClose() {

		frametime:= rl.GetFrameTime()

		toggle_map(&world, &map_state)
		player_update(&world, frametime)
		update_camera(&world, frametime)
		if map_state.show_map {
			map_controls(&world,&map_state, frametime)
		}

		// Map Screen pass
		map_screen_pass: {
			rl.BeginTextureMode(map_screen)
			rl.ClearBackground({255,211,172,255})
			draw_map(&world, &map_state, &atlas)
			rl.EndTextureMode()
		}

		gameplay_screen_pass: {
			rl.BeginTextureMode(gameplay_screen)
			rl.ClearBackground(rl.BLUE)
			rl.BeginMode2D(world.camera)
			draw_world_rooms(&world, &atlas)
			draw_player(&world, &atlas)
			draw_colliders(&world)
			rl.EndMode2D()
			rl.EndTextureMode()
		}

		rl.BeginDrawing()

		rl.DrawTexturePro(
			gameplay_screen.texture,
			rl.Rectangle{width = 1600, height = -900},
			rl.Rectangle{width = 1600, height = 900},
			{0,0},
			0,
			rl.WHITE
		)


		// If we should show the map, draw it's render texture to the screen
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

