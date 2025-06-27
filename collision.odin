package main

import "core:math"
import sa "core:container/small_array"
import rl "vendor:raylib"

StaticCollider :: struct {
	vertices: [4]Vec2
}

ColliderIter :: struct {
	colliders: sa.Small_Array(1000, StaticCollider),
	index: int
}

collider_make_iter :: proc(colliders: sa.Small_Array(1000, StaticCollider)) -> ColliderIter {
		return ColliderIter {colliders = colliders}
}

iter_collider :: proc(it: ^ColliderIter) -> (val: StaticCollider, cond: bool) {
	in_range := it.index < sa.len(it.colliders)

	for in_range {
		val := sa.get(it.colliders, it.index)
		cond = true
		it.index += 1
		return
	}
	return
}

iter_collider_ptr :: proc(it: ^ColliderIter) -> (val: ^StaticCollider, cond: bool) {
	in_range := it.index < sa.len(it.colliders)

	for in_range {
		collider := sa.get(it.colliders, it.index)
		val = &collider
		cond = true
		it.index += 1
		return
	}
	return
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
