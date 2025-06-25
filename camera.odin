package main

import l "core:math/linalg"

move_camera :: proc(world: ^World, frametime: f32) {
	world.camera.target = l.lerp(world.camera.target, world.target_camera_position, frametime * 20)
}

clamp_camera_target :: proc(world: ^World, frametime: f32) {
	clamp_x, clamp_y := i32(world.player.translation.x / 48), i32(world.player.translation.y / 48)

	world.target_camera_position = {f32(clamp_x * 48), f32(clamp_y * 48)} - {48,48}
}

update_camera :: proc(world: ^World, frametime: f32) {
	clamp_camera_target(world,frametime)
	move_camera(world, frametime)
}
