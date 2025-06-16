package main

import "core:fmt"
import "core:encoding/csv"
import "core:os"
import "core:strconv"
import sa "core:container/small_array"

RoomTag :: enum {
	A,
	B,
	C
}

RoomCell :: struct {
	location: Tile,
	pixels: [12][12]u8
}

is_valid_room_cell :: proc(room_cell: RoomCell) -> bool {
	for i in 0..<12 {
		for j in 0..<12 {
			value: = room_cell.pixels[i][j]
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

// Read all records at once
read_level :: proc(filename: string) -> sa.Small_Array(20, RoomCell) {
	r: csv.Reader
	r.trim_leading_space  = true
	defer csv.reader_destroy(&r)

	room_cell_array: sa.Small_Array(20, RoomCell)

	csv_data, ok := os.read_entire_file(filename)
	if ok {
		csv.reader_init_with_string(&r, string(csv_data))
	} else {
		fmt.printfln("Unable to open file: %v", filename)
		return room_cell_array
	}
	defer delete(csv_data)

	records, err := csv.read_all(&r)
	if err != nil do fmt.printfln("Failed to parse CSV file for %v", filename)

	defer {
		for rec in records {
			delete(rec)
		}
		delete(records)
	}
	width:= len(records[0]) / 12
	height:= len(records) / 12

	
	rooms: [10][10]RoomCell

	for r, i in records {
		x: i16 = i16(i) / 12 //X and Y inform which room cell we are populating
		for f, j in r {
			y: i16 = i16(j) / 12 //X and Y inform which room cell we are populating
			ix:= i16(i) - (x * 12)
			iy:= i16(j) - (y * 12)
			current_cell := &rooms[x][y]
			current_cell.location = Tile{x,y}
			if field, ok := strconv.parse_uint(f); ok {
				current_cell.pixels[ix][iy] = u8(field)
			}
			// fmt.printfln("Record %v, field %v: %q", i, j, f)
		}
	}
	fmt.printfln("Width: %v, Height: %v", width, height)

	for i in 0..<10 {
		for j in 0..<10 {
			validity:= is_valid_room_cell(rooms[i][j])
			if validity {
				sa.append(&room_cell_array,rooms[i][j])
			}
		}
	}
	return room_cell_array
}
