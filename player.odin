package main

import "core:fmt"
import rl "vendor:raylib"
import l "core:math/linalg"

Player :: struct {
	translation: Vec2,
	height: f32,
	width: f32,
	velocity: Vec2,
	grounded: bool
}

player_locomotion :: proc(world: ^World, frametime: f32) {
	delta: Vec2

	if rl.IsKeyDown(.A) {
		delta.x -= 1
	}
	if rl.IsKeyDown(.D) {
		delta.x += 1
	}
	if delta != {0,0} {
		world.player.velocity.x = l.normalize(delta).x * frametime * 50
	} else {
		world.player.velocity.x = 0
	}
}

apply_player_gravity :: proc(world: ^World, frametime: f32) {
	if !world.player.grounded {
		world.player.velocity.y += 00.1 * frametime
	}
}

apply_player_velocity :: proc(world: ^World) {
	world.player.translation += world.player.velocity
}

player_jump :: proc(world: ^World, frametime: f32) {
	player := &world.player
	if rl.IsKeyPressed(.SPACE) && player.grounded {
		player.velocity.y = -100 * frametime
	}
}

player_collision :: proc(world: ^World) {
	player := &world.player
	player.grounded = false
	iter := bb_make_iter(world.static_colliders)

	player_collider:= Sphere {translation = player.translation + Vec2{8,8}, radius = 7}
	player_feet_collider := Sphere {translation = player.translation + Vec2{8,16}, radius = 2}

	for collider in iter_bb_ptr(&iter) {
		collision, colliding := sphere_bb_collision(player_collider, collider^)
		if colliding {
			// player^.grounded = true
			player.velocity -= collision.collision_normal * l.dot(player.velocity, collision.collision_normal)
			player.translation += collision.collision_normal * collision.penetration_depth
		}
		_, foot_collision := sphere_bb_collision(player_feet_collider, collider^)
		if foot_collision {
			player.grounded =  true
		}
	}
}

player_update :: proc(world: ^World, frametime: f32) {
	player_locomotion(world, frametime)
	apply_player_gravity(world, frametime)
	player_collision(world)
	player_jump(world, frametime)
	apply_player_velocity(world)
}

draw_player :: proc(world: ^World, atlas: ^TextureAtlas) {
	rl.DrawTextureV(atlas.guy, world.player.translation, rl.WHITE)
	rl.DrawCircleV(world.player.translation + Vec2{8,8}, 7, {0, 255, 0, 100})
	rl.DrawCircleV(world.player.translation + Vec2{8,16}, 2, rl.WHITE)
}
