extends Node

const CELL_SIZE := 16

var cell_hidden: Texture2D
var cell_revealed: Texture2D
var cell_flagged: Texture2D
var cell_mine: Texture2D
var cell_exploded: Texture2D

var number_textures: Array[Texture2D] = []

var _colors := {
	"hidden_bg": Color(0.267, 0.251, 0.345),
	"hidden_border": Color(0.369, 0.351, 0.447),
	"hidden_highlight": Color(0.392, 0.373, 0.494),
	"hidden_shadow": Color(0.188, 0.176, 0.251),
	"revealed_bg": Color(0.118, 0.110, 0.157),
	"revealed_border": Color(0.188, 0.176, 0.251),
	"flag_base": Color(0.345, 0.318, 0.431),
	"flag_pole": Color(0.200, 0.196, 0.247),
	"flag_triangle": Color(0.847, 0.388, 0.318),
	"mine_body": Color(0.059, 0.055, 0.082),
	"mine_spike": Color(0.200, 0.196, 0.247),
	"mine_highlight": Color(1.0, 1.0, 1.0),
	"explode_bg": Color(0.549, 0.251, 0.200),
	"number_1": Color(0.392, 0.737, 0.847),
	"number_2": Color(0.471, 0.816, 0.502),
	"number_3": Color(0.847, 0.518, 0.424),
	"number_4": Color(0.737, 0.518, 0.831),
	"number_5": Color(0.549, 0.251, 0.200),
	"number_6": Color(0.157, 0.424, 0.580),
	"number_7": Color(0.267, 0.235, 0.345),
	"number_8": Color(0.353, 0.337, 0.431),
}

func _ready() -> void:
	cell_hidden = _make_cell_hidden()
	cell_revealed = _make_cell_revealed()
	cell_flagged = _make_cell_flagged()
	cell_mine = _make_cell_mine()
	cell_exploded = _make_cell_exploded()
	_make_number_textures()

func _make_cell_hidden() -> ImageTexture:
	var img := Image.create(CELL_SIZE, CELL_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(_colors["hidden_bg"])
	for x in range(CELL_SIZE):
		img.set_pixel(x, 0, _colors["hidden_highlight"])
		img.set_pixel(x, CELL_SIZE - 1, _colors["hidden_shadow"])
	for y in range(CELL_SIZE):
		img.set_pixel(0, y, _colors["hidden_highlight"])
		img.set_pixel(CELL_SIZE - 1, y, _colors["hidden_shadow"])
	img.set_pixel(CELL_SIZE - 1, 0, _colors["hidden_bg"])
	img.set_pixel(0, CELL_SIZE - 1, _colors["hidden_bg"])
	return ImageTexture.create_from_image(img)

func _make_cell_revealed() -> ImageTexture:
	var img := Image.create(CELL_SIZE, CELL_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(_colors["revealed_bg"])
	for x in range(CELL_SIZE):
		img.set_pixel(x, 0, _colors["revealed_border"])
		img.set_pixel(x, CELL_SIZE - 1, _colors["revealed_border"])
	for y in range(CELL_SIZE):
		img.set_pixel(0, y, _colors["revealed_border"])
		img.set_pixel(CELL_SIZE - 1, y, _colors["revealed_border"])
	return ImageTexture.create_from_image(img)

func _make_cell_flagged() -> ImageTexture:
	var img := _make_hidden_base()
	var pole_x := 8
	for py in range(3, 13):
		img.set_pixel(pole_x, py, _colors["flag_pole"])
		img.set_pixel(pole_x + 1, py, _colors["flag_pole"])
	for dy in range(4):
		for dx in range(5 - dy):
			img.set_pixel(pole_x - 1 - dx, 3 + dy, _colors["flag_triangle"])
	for bx in range(-3, 4):
		img.set_pixel(pole_x + bx, 12, _colors["flag_base"])
		img.set_pixel(pole_x + bx, 13, _colors["flag_base"])
	return ImageTexture.create_from_image(img)

func _make_hidden_base() -> Image:
	var img := Image.create(CELL_SIZE, CELL_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(_colors["hidden_bg"])
	for x in range(CELL_SIZE):
		img.set_pixel(x, 0, _colors["hidden_highlight"])
		img.set_pixel(x, CELL_SIZE - 1, _colors["hidden_shadow"])
	for y in range(CELL_SIZE):
		img.set_pixel(0, y, _colors["hidden_highlight"])
		img.set_pixel(CELL_SIZE - 1, y, _colors["hidden_shadow"])
	img.set_pixel(CELL_SIZE - 1, 0, _colors["hidden_bg"])
	img.set_pixel(0, CELL_SIZE - 1, _colors["hidden_bg"])
	return img

func _make_cell_mine() -> ImageTexture:
	var img := _make_revealed_base()
	_draw_mine(img)
	return ImageTexture.create_from_image(img)

func _make_cell_exploded() -> ImageTexture:
	var img := Image.create(CELL_SIZE, CELL_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(_colors["explode_bg"])
	for x in range(CELL_SIZE):
		img.set_pixel(x, 0, _colors["revealed_border"])
		img.set_pixel(x, CELL_SIZE - 1, _colors["revealed_border"])
	for y in range(CELL_SIZE):
		img.set_pixel(0, y, _colors["revealed_border"])
		img.set_pixel(CELL_SIZE - 1, y, _colors["revealed_border"])
	_draw_mine(img)
	return ImageTexture.create_from_image(img)

func _make_revealed_base() -> Image:
	var img := Image.create(CELL_SIZE, CELL_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(_colors["revealed_bg"])
	for x in range(CELL_SIZE):
		img.set_pixel(x, 0, _colors["revealed_border"])
		img.set_pixel(x, CELL_SIZE - 1, _colors["revealed_border"])
	for y in range(CELL_SIZE):
		img.set_pixel(0, y, _colors["revealed_border"])
		img.set_pixel(CELL_SIZE - 1, y, _colors["revealed_border"])
	return img

func _draw_mine(img: Image) -> void:
	var cx := 8
	var cy := 8
	var r := 4
	for dx in range(-r, r + 1):
		for dy in range(-r, r + 1):
			if dx * dx + dy * dy <= r * r:
				img.set_pixel(cx + dx, cy + dy, _colors["mine_body"])
	for s in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		img.set_pixel(cx + s.x * 5, cy + s.y * 5, _colors["mine_spike"])
		img.set_pixel(cx + s.x * 6, cy + s.y * 6, _colors["mine_spike"])
	for s in [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]:
		img.set_pixel(cx + s.x * 4, cy + s.y * 4, _colors["mine_spike"])
	img.set_pixel(cx - 2, cy - 2, _colors["mine_highlight"])
	img.set_pixel(cx - 1, cy - 2, _colors["mine_highlight"])
	img.set_pixel(cx - 2, cy - 1, _colors["mine_highlight"])

func _make_number_textures() -> void:
	var number_colors := [
		_colors["number_1"],
		_colors["number_2"],
		_colors["number_3"],
		_colors["number_4"],
		_colors["number_5"],
		_colors["number_6"],
		_colors["number_7"],
		_colors["number_8"],
	]
	var digit_patterns := [
		[[0,0,1,0,0],[0,1,1,0,0],[1,0,1,0,0],[0,0,1,0,0],[0,0,1,0,0],[0,0,1,0,0],[0,1,1,1,0]],
		[[0,1,1,1,0],[1,0,0,0,1],[0,0,0,0,1],[0,0,1,1,0],[0,1,0,0,0],[1,0,0,0,0],[1,1,1,1,1]],
		[[0,1,1,1,0],[1,0,0,0,1],[0,0,0,0,1],[0,0,1,1,0],[0,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
		[[0,0,0,1,0],[0,0,1,1,0],[0,1,0,1,0],[1,0,0,1,0],[1,1,1,1,1],[0,0,0,1,0],[0,0,0,1,0]],
		[[1,1,1,1,1],[1,0,0,0,0],[1,1,1,1,0],[0,0,0,0,1],[0,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
		[[0,1,1,1,0],[1,0,0,0,0],[1,0,0,0,0],[1,1,1,1,0],[1,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
		[[1,1,1,1,1],[0,0,0,0,1],[0,0,0,1,0],[0,0,1,0,0],[0,1,0,0,0],[0,1,0,0,0],[0,1,0,0,0]],
		[[0,1,1,1,0],[1,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0],[1,0,0,0,1],[1,0,0,0,1],[0,1,1,1,0]],
	]

	for i in range(8):
		var img := _make_revealed_base()
		var pattern: Array = digit_patterns[i]
		var pat_h: int = pattern.size()
		var pat_w: int = (pattern[0] as Array).size()
		var ox: int = (CELL_SIZE - pat_w) / 2
		var oy: int = (CELL_SIZE - pat_h) / 2
		for py in range(pat_h):
			for px in range(pat_w):
				if pattern[py][px] == 1:
					img.set_pixel(ox + px, oy + py, number_colors[i])
		number_textures.append(ImageTexture.create_from_image(img))
