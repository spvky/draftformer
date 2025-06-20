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

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Draftformer")
	cursor:= rl.LoadTexture("./sprites/cursor.png")
	defer rl.CloseWindow()
	map_state:= make_map_state()
	world := make_world()
	defer delete_world(world)

	main_block: for !rl.WindowShouldClose() {

		frametime:= rl.GetFrameTime()

		map_controls(&world,&map_state, frametime)

		// Drawing
		rl.BeginDrawing()
		rl.ClearBackground({255,211,172,255})
		draw_map(&world, &map_state, &cursor)
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
}

