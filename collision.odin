package main

import "core:math"
import sa "core:container/small_array"
import rl "vendor:raylib"

StaticCollider :: struct {
	vertices: [4]Vec2
}

draw_colliders :: proc(world: ^World) {
	length := sa.len(world.static_colliders)

	for i in 0..<length {
		collider := sa.get(world.static_colliders, i)
		total: Vec2
		for p in 0..<4 {
			total += collider.vertices[p]
		}
		avg := total / 4
		width := math.abs(collider.vertices[0].x - collider.vertices[1].x)
		height := math.abs(collider.vertices[1].y - collider.vertices[2].y)
		rl.DrawRectangleV(avg, {width, height}, rl.RED)
	}
}
