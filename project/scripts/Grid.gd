class_name Grid

extends Node2D

export var color := Color.cyan

onready var camera: Camera2D = $"../.."
onready var root: Node2D = $"../../.."

var font := Global.font

func dec_to_degree_str(dec: float) -> String:
	var degrees := int(dec)
	dec -= degrees
	if not is_equal_approx(dec, 0):
		dec *= 60
		var minutes := int(dec)
		dec -= minutes
		if not is_equal_approx(dec, 0):
			return "%d°%d'%d''" % [degrees, minutes, dec * 60]
		else:
			return "%d°%d'" % [degrees, minutes]
	else:
		return "%d°" % degrees

func dec_to_lon_str(dec: float) -> String:
	if dec != 0:
		if dec > 0:
			return dec_to_degree_str(dec) + 'Đ'
		else:
			return dec_to_degree_str(-dec) + 'T'
	else:
		return '0°'

func dec_to_lat_str(dec: float) -> String:
	if dec != 0:
		if dec > 0:
			return dec_to_degree_str(dec) + 'B'
		else:
			return dec_to_degree_str(-dec) + 'N'
	else:
		return '0°'

func _ready():
	set_physics_process(false)
	set_physics_process_internal(false)

func _draw():
	var xform: Transform2D = root.get_global_transform_with_canvas()
	var size = get_viewport_rect().size
	var cell_size := max(512, 512 * nearest_po2(camera.zoom.x))
	var disp_size := cell_size / camera.zoom.x
	var topleft_inv = xform.affine_inverse().xform(Vector2.ZERO)
	topleft_inv.x = ceil(topleft_inv.x / cell_size)
	topleft_inv.y = ceil(topleft_inv.y / cell_size)
	topleft_inv *= cell_size
	var topleft = xform.xform(topleft_inv)
		
	for i in range(int((topleft.x - size.x) / disp_size) - 2, int((size.x + topleft.x) / disp_size) + 2):
		var line_x: float = topleft.x + i * disp_size
		draw_line(Vector2(line_x, topleft.y + size.y + disp_size), Vector2(line_x, topleft.y - size.y - disp_size), color)
		var line_lon: float = Global.pixel_pos_to_epsg4326(topleft_inv.x + i * cell_size, 0)[1]
		draw_string(font, Vector2(line_x + 2, 18), dec_to_lon_str(line_lon), color)
	for i in range(int((topleft.y - size.y) / disp_size) - 2, int((size.y + topleft.y) / disp_size) + 2):
		var line_y: float = topleft.y + i * disp_size
		draw_line(Vector2(topleft.x + size.x + disp_size, line_y), Vector2(topleft.x - size.x - disp_size, line_y), color)
		var line_lat: float = Global.pixel_pos_to_epsg4326(0, topleft_inv.y + i * cell_size)[0]		
		draw_string(font, Vector2(2 , line_y), dec_to_lat_str(line_lat), color)
