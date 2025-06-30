package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"


debug_ui :: proc(world: ^World) {
	grounded_text := fmt.tprintf("Grounded: %v", world.player.grounded)
	rl.DrawText(strings.clone_to_cstring(grounded_text), 800, 450, 24, rl.WHITE)
}
