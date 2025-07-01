package main

import "core:fmt"
import sa "core:container/small_array"

Vec2 :: [2]f32

Room :: struct {
	cell_origin: [2]i16,
	tag: RoomTag,
	cells: sa.Small_Array(10,Cell)
}

RoomTag :: enum { A,B,C,D,E,F }

Cell :: struct {
	tiles: [12][12]Tile
}

Tile :: struct {
	relative_position: [2]i16,
	value: TileValue
}

TileValue :: enum {
	Empty,
	Wall,
	Exit,
	Box,
	Pipe,
	Fan
}

main :: proc() {
	fmt.printfln("Room: %v", size_of(Room))
	fmt.printfln("Cell: %v", (size_of(Cell) * 144) / 1000)
	fmt.printfln("Tile: %v", size_of(Tile))
}
