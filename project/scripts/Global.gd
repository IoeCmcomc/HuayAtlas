extends Node

const LOG_2 := log(2)

const TILE_SIZE := 512
const BASE_ZOOM_LEVEL: int = 10

const INITIAL_RESOLUTION := 2 * PI * 6378137 / TILE_SIZE
const BASE_RESOLUTION := (2 * PI * 6378137) / (TILE_SIZE * pow(2, BASE_ZOOM_LEVEL))
const ORIGIN_SHIFT := 2 * PI * 6378137 / 2.0

var font := DynamicFont.new()


static func log2(x):
	return log(x) / LOG_2
	
static func to_zoom_level(zoom: float) -> float:
	return BASE_ZOOM_LEVEL - log2(zoom)

# Adapted from: https://gist.github.com/maptiler/fddb5ce33ba995d5523de9afdf8ef118
func epsg4326_to_epsg3857(lat: float, lon: float) -> Array:
	var mx: float = lon * ORIGIN_SHIFT / 180.0
	var my: float = -log(tan((90 + lat) * PI / 360.0)) / (PI / 180.0)

	my = my * ORIGIN_SHIFT / 180.0
	return [mx, my]
	
func epsg3857_to_pixel_pos(mx: float, my: float, zoom: int) -> Array:
	var res := INITIAL_RESOLUTION / pow(2, zoom)
	var px := (mx + ORIGIN_SHIFT) / res
	var py := (my + ORIGIN_SHIFT) / res
	return [px, py]
	
func epsg4326_to_pixel_pos(lat: float, lon: float) -> Vector2:
	var x := ((lon * ORIGIN_SHIFT / 180.0) + ORIGIN_SHIFT) / BASE_RESOLUTION
	var y := ((-log(tan((90 + lat) * PI / 360.0)) / (PI / 180.0)
			* ORIGIN_SHIFT / 180.0) + ORIGIN_SHIFT) / BASE_RESOLUTION
	
	return Vector2(x, y)

func epsg3857_to_epsg4326(mx: float, my: float) -> Vector2:
	var lon := (mx / ORIGIN_SHIFT) * 180.0
	var lat := (my / ORIGIN_SHIFT) * 180.0

	lat = 180 / PI * (2 * atan(exp(lat * PI / 180.0)) - PI / 2.0)
	return Vector2(lat, lon)

func pixel_pos_to_epsg3857(px: float, py: float, zoom: int) -> Array:
	var res := INITIAL_RESOLUTION / pow(2, zoom)
	var mx := px * res - ORIGIN_SHIFT
	var my := py * res - ORIGIN_SHIFT
	return [mx, my]
	
func pixel_pos_to_epsg4326(px: float, py: float) -> Array:
	var lon := ((px * BASE_RESOLUTION - ORIGIN_SHIFT) / ORIGIN_SHIFT) * 180.0
	var lat := 180 / PI * -(2 * atan(exp(((py * BASE_RESOLUTION - ORIGIN_SHIFT)
			/ ORIGIN_SHIFT * 180.0) * PI / 180.0)) - PI / 2.0)
	
	return [lat, lon]
	

func _ready():
	set_physics_process(false)
	font.font_data = preload("res://resources/fonts/NotoSansUI-Regular.ttf")
	var pos1 := Vector2(16.046480, 108.200665)
	var pos2 := epsg4326_to_pixel_pos(pos1.x, pos1.y)
	var pos3 := pixel_pos_to_epsg4326(pos2.x, pos2.y)
	assert (is_equal_approx(pos1.x, pos3[0]))
	assert (is_equal_approx(pos1.y, pos3[1]))
	
func _process(_delta):
	if Input.is_action_just_pressed("fullscreen_toggle"):
		OS.window_fullscreen = not OS.window_fullscreen
