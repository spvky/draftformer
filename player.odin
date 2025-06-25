package main

import rl "vendor:raylib"
import l "core:math/linalg"

Player :: struct {
	translation: Vec2
}

move_player :: proc(world: ^World, frametime: f32) {
	delta: Vec2

	if rl.IsKeyDown(.A) {
		delta.x -= 1
	}
	if rl.IsKeyDown(.D) {
		delta.x += 1
	}
	if rl.IsKeyDown(.W) {
		delta.y -= 1
	}
	if rl.IsKeyDown(.S) {
		delta.y += 1
	}

	if delta != {0,0} {
		world.player.translation += l.normalize(delta) * frametime * 50
	}
}

player_update :: proc(world: ^World, frametime: f32) {
	move_player(world, frametime)
}

draw_player :: proc(world: ^World, atlas: ^TextureAtlas) {
	rl.DrawTextureV(atlas.guy, world.player.translation, rl.WHITE)
}
