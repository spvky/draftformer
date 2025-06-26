package main

import "core:fmt"
import "core:encoding/csv"
import "core:os"
import "core:strconv"
import sa "core:container/small_array"
import rl "vendor:raylib"


World :: struct {
	show_collision: bool,
	rooms: sa.Small_Array(40, MapRoom),
	placed_map_rooms: sa.Small_Array(40,PlacedRoomEntry),
	held_rooms: sa.Small_Array(40,^MapRoom),
	occupied_tiles: map[Tile]struct{},
	placed_world_rooms: sa.Small_Array(40, WorldRoom),
	camera: rl.Camera2D,
	player: Player,
	target_camera_position: Vec2,
	static_colliders: sa.Small_Array(100, StaticCollider)
}


PlacedRoomEntry :: struct {
	room_ptr: ^MapRoom,
	origin: Tile,
}

make_world :: proc() -> World {
	rooms: sa.Small_Array(40, MapRoom)
	held_rooms: sa.Small_Array(40,^MapRoom)
	sa.append_elems(&rooms,read_room(.A), read_room(.B), read_room(.C), read_room(.D), read_room(.E))

	for i in 0..<sa.len(rooms) {
		ptr := sa.get_ptr(&rooms, i)
		sa.append_elem(&held_rooms, ptr)
	}

	camera := rl.Camera2D {
		target = {0,0},
		zoom = 10
	}

	return World {
		rooms = rooms,
		held_rooms = held_rooms,
		camera = camera
	}
}

delete_world :: proc(world: World) {
	delete(world.occupied_tiles)
}

get_held_room_ptr :: proc(world: ^World, state: ^MapScreenState) -> (ptr: ^MapRoom, ok: bool) {
	if ptr, ok = sa.get_safe(world.held_rooms, state.held_room_index); ok {
		return
	}
	return
}

is_valid_room_cell :: proc(cell: Cell) -> bool {
	for i in 0..<12 {
		for j in 0..<12 {
			value: = cell.pixels[i][j]
			if value != 0 && value != 2 {
				return true
			}
		}
	}
	return false
}

BakingRoom :: struct {
	room_tag: RoomTag
}

room_tag_as_filepath :: proc(tag: RoomTag, extension: enum{CSV, PNG}) -> string {
	switch extension {
		case .CSV:
			return fmt.tprintf("ldtk/samples/simplified/%v/Main.csv", tag)
		case .PNG:
			return fmt.tprintf("ldtk/samples/simplified/%v/Main.png", tag)
	}
	return ""
}

// Read all records at once
read_room :: proc(tag: RoomTag) -> MapRoom {
	filename := room_tag_as_filepath(tag, .CSV)
	r: csv.Reader
	r.trim_leading_space  = true
	defer csv.reader_destroy(&r)

	cell_array: sa.Small_Array(20, Cell)

	csv_data, ok := os.read_entire_file(filename)
	if ok {
		csv.reader_init_with_string(&r, string(csv_data))
	} else {
		fmt.printfln("Unable to open file: %v", filename)
		return MapRoom{}
	}
	defer delete(csv_data)

	records, err := csv.read_all(&r)
	if err != nil do fmt.printfln("Failed to parse CSV file for %v\nErr: %v", filename, err)

	defer {
		for rec in records {
			delete(rec)
		}
		delete(records)
	}
	width:= len(records[0]) / 12
	height:= len(records) / 12

	
	rooms: [10][10]Cell

	for r, i in records {
		for f, j in r {
			x: i16 = i16(j) / 12 //X and Y inform which room cell we are populating
			y: i16 = i16(i) / 12 //X and Y inform which room cell we are populating
			ix:= i16(j) - (x * 12)
			iy:= i16(i) - (y * 12)
			current_cell := &rooms[x][y]
			current_cell.location = Tile{x,y}
			if field, ok := strconv.parse_uint(f); ok {
				current_cell.pixels[iy][ix] = u8(field)
			}
		}
	}

	for i in 0..<10 {
		for j in 0..<10 {
			validity:= is_valid_room_cell(rooms[j][i])
			if validity {
				sa.append(&cell_array,rooms[j][i])
			}
		}
	}
	return  MapRoom {cells=cell_array, name = tag}
}
