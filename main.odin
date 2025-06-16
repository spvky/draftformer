package main

import "core:fmt"
import "core:mem"
import sa "core:container/small_array"
import rl "vendor:raylib"

Vec2 :: [2]f32

SCREEN_WIDTH :: 1600
SCREEN_HEIGHT :: 900

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
	defer rl.CloseWindow()
	map_state:= make_map_state()
	defer delete_map_state(map_state)

	main_block: for !rl.WindowShouldClose() {

		frametime:= rl.GetFrameTime()

		map_controls(&map_state, frametime)

		// Drawing
		rl.BeginDrawing()
		rl.ClearBackground({255,211,172,255})
		draw_map(map_state)
		rl.EndDrawing()
	}
}

