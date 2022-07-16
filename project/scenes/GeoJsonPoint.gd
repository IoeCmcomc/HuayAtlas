class_name GeoJsonPoint

extends Node2D

onready var camera: Camera2D = $"../../TouchCamera2D"

var props: Dictionary
var icon: Texture
var color: Color = Color.darkgoldenrod

func _ready():
	set_physics_process(false)
	set_physics_process_internal(false)
	update()

func _process(_delta):
	if 'SCALERANK' in props:
		if Global.to_zoom_level(camera.zoom.x) >= props['MIN_ZOOM']:
			show()
			scale = camera.zoom
		else:
			hide()

func _draw():
	var text_pos := Vector2.ZERO
	if icon:
		draw_texture(icon, Vector2.ZERO)
		text_pos.x = icon.get_size().x / 2
	if props:
		draw_string(Global.font, text_pos, props['name'], color)
