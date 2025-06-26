package main

import "core:math"
import sa "core:container/small_array"
import rl "vendor:raylib"

StaticCollider :: struct {
	vertices: [4]Vec2
}

collider_size :: proc(using collider: StaticCollider) -> Vec2 {
	width := math.abs(vertices[0].x - vertices[1].x)
	height := math.abs(vertices[0].y - vertices[2].y)
	return Vec2{width,height}
}

draw_colliders :: proc(world: ^World) {
	length := sa.len(world.static_colliders)
	for i in 0..<length {
		collider := sa.get(world.static_colliders, i)
		rl.DrawTriangle(collider.vertices[2], collider.vertices[1], collider.vertices[0], rl.RED)
		rl.DrawTriangle(collider.vertices[3], collider.vertices[2], collider.vertices[0], rl.RED)
		for j in 0..<4 {
			rl.DrawCircleV(collider.vertices[j], 0.5,rl.PINK)
		}
	}
}
