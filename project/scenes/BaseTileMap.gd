extends Node2D

export var map_type := 'sentinel' setget set_map_type

onready var camera := $"../TouchCamera2D"
onready var tile_layer := $TileMapLayer
onready var static_layer := $StaticLayer

func set_map_type(type: String):
	map_type = type
	if static_layer and tile_layer:
		static_layer.map_type = map_type
		tile_layer.map_type = map_type
		load_static()

func load_static() -> void:
	static_layer.load_map_once()

func _ready():
	set_process(visible)
	set_physics_process(false)
	set_physics_process_internal(false)
	
	if not camera:
		camera = $TouchCamera2D
	camera.set_position(Global.epsg4326_to_pixel_pos(16.046480, 108.200665))
	
	set_map_type(map_type)

func _process(_delta):
	var zoom_level := round(Global.to_zoom_level(camera.zoom.x))
	if zoom_level > 5:
		tile_layer.zoom_level = zoom_level
