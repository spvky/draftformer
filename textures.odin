package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

TextureAtlas :: struct {
	room_textures: [RoomTag]rl.Texture2D,
	cursor: rl.Texture2D,
	guy: rl.Texture2D,
}

make_texture_atlas :: proc() -> TextureAtlas {
	atlas: TextureAtlas
	load_room_textures(&atlas)
	load_misc_sprites(&atlas)
	return atlas
}

load_misc_sprites :: proc(atlas: ^TextureAtlas) {
	cursor := rl.LoadTexture("./sprites/cursor.png")
	guy := rl.LoadTexture("./sprites/guy.png")
	atlas.guy = guy
	atlas.cursor = cursor
}

load_room_textures :: proc(atlas: ^TextureAtlas) {
	for &t,i in atlas.room_textures {
		fmt.printfln("Loading texture for %v", i)
		texture_path := room_tag_as_filepath(i,.PNG)
		texture := rl.LoadTexture(strings.clone_to_cstring(texture_path, allocator = context.temp_allocator))
		t = texture
	}
}

