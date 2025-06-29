package main

import "core:math"
import sa "core:container/small_array"
import l "core:math/linalg"
import rl "vendor:raylib"


AABBIter :: struct {
	aabbs: sa.Small_Array(1000, AABB),
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

bb_triangles :: proc(aabb: AABB) -> [2]Triangle {
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

bb_vertices :: proc(a: AABB) -> [4]Vec2 {
	return [?]Vec2 {
		{a.min.x,a.min.y},
		{a.max.x,a.min.y},
		{a.max.x,a.max.y},
		{a.min.x,a.max.y},
	}
}

bb_nearest :: proc(aabb: AABB, point: Vec2) -> Vec2 {
	return Vec2{
		math.clamp(point.x, aabb.min.x, aabb.max.x),
		math.clamp(point.y, aabb.min.y, aabb.max.y),
	}
}

sphere_bb_collision :: proc(s: Sphere, b: AABB) -> (data: CollisionData, colliding: bool){
	nearest := bb_nearest(b,s.translation)
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

bb_make_iter :: proc(aabbs: sa.Small_Array(1000, AABB)) -> AABBIter {
		return AABBIter {aabbs = aabbs}
}

iter_bb :: proc(it: ^AABBIter) -> (val: AABB, cond: bool) {
	in_range := it.index < sa.len(it.aabbs)

	for in_range {
		val := sa.get(it.aabbs, it.index)
		cond = true
		it.index += 1
		return
	}
	return
}

iter_bb_ptr :: proc(it: ^AABBIter) -> (val: ^AABB, cond: bool) {
	in_range := it.index < sa.len(it.aabbs)

	for in_range {
		val = sa.get_ptr(&it.aabbs, it.index)
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
		triangles := bb_triangles(collider)
		verts := bb_vertices(collider)
		for t in triangles {
			using t
			rl.DrawTriangle(vertices[2], vertices[1], vertices[0], rl.RED)
		}
		for v in verts {
			rl.DrawCircleV(v, 0.5,rl.PINK)
		}
	}
}
