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

AABB :: struct {
	min: Vec2,
	max: Vec2
}

Triangle :: struct {
	vertices: [3]Vec2
}

Sphere :: struct {
	translation: Vec2,
	radius: f32
}

CollisionData :: struct {
	collision_point: Vec2,
	collision_normal: Vec2,
	penetration_depth: f32
}

aabb_triangles :: proc(aabb: AABB) -> [2]Triangle {
	return [2]Triangle {
		{
			vertices = {
				aabb.min,
				{aabb.max.x, aabb.min.y},
				aabb.max
			}
		},
		{
			vertices = {
			aabb.min,
			aabb.max,
			{aabb.min.x, aabb.max.y}
			}
		}
	}
}

aabb_nearest :: proc(aabb: AABB, point: Vec2) -> Vec2 {
	return Vec2{
		math.clamp(point.x, aabb.min.x, aabb.max.x),
		math.clamp(point.y, aabb.min.y, aabb.max.y),
	}
}

sphere_aabb_collision :: proc(s: Sphere, b: AABB) -> (data: CollisionData, colliding: bool){
	nearest := aabb_nearest(b,s.translation)
	colliding = l.distance(nearest, s.translation) < s.radius
	if !colliding do return
	collision_vector := s.translation - nearest
	penetration_depth := s.radius - l.length(collision_vector)
	data = CollisionData {
		collision_normal = l.normalize(collision_vector),
		collision_point = nearest,
		penetration_depth = penetration_depth,
	}
	return
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
		val = sa.get_ptr(&it.colliders, it.index)
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
