package main

import "core:fmt"
import br "shared:bragi"
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
	// if rl.IsKeyDown(.W) {
	// 	delta.y -= 1
	// }
	// if rl.IsKeyDown(.S) {
	// 	delta.y += 1
	// }
	if delta != {0,0} {
		world.player.velocity.x += l.normalize(delta).x * frametime * 50
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
	// fmt.printfln("Player Translation: %v\nPlayer Velocity: %v", world.player.translation, world.player.velocity)
}

player_collision_with_scene :: proc(world: ^World) {
	iter := collider_make_iter(world.static_colliders)

	for collider in iter_collider_ptr(&iter) {
		player_center := world.player.translation + world.player.velocity + Vec2 {8,8}
		// player_capsule := br.Capsule {translation = br.extend(player_center, 0), height = 16, radius = 8}
		player_capsule := br.Sphere {translation = br.extend(player_center, 0), radius = 8}
		player_sphere := br.Sphere{ translation = br.extend(world.player.translation + Vec2 {8,16}, 0), radius = 2}
		collider_points := [4][3]f32 {
			br.extend(collider.vertices[0],0),
			br.extend(collider.vertices[1],0),
			br.extend(collider.vertices[2],0),
			br.extend(collider.vertices[3],0),
		}
		world.player.grounded = br.gjk(player_sphere, collider_points[:])
		if br.gjk(player_capsule, collider_points[:]) {
			world.player.velocity.y = 0
		}
	}
}

player_update :: proc(world: ^World, frametime: f32) {
	player_locomotion(world, frametime)
	apply_player_gravity(world, frametime)
	player_collision_with_scene(world)
	apply_player_velocity(world)
}

draw_player :: proc(world: ^World, atlas: ^TextureAtlas) {
	rl.DrawTextureV(atlas.guy, world.player.translation, rl.WHITE)
	rl.DrawCircleV(world.player.translation + Vec2{8,8}, 8, {0, 255, 0, 100})
}
