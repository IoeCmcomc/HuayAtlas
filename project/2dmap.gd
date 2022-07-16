extends Node2D

onready var camera := $TouchCamera2D
onready var square := $Polygon2D
onready var basemap := $BaseTileMap

func _ready():
	camera.set_position(Global.epsg4326_to_pixel_pos(16.046480, 108.200665))

func _process(_delta):
	var mouse_pos := get_local_mouse_position()
#	print(mouse_pos)
	var mouse_tile_pos := Vector2(int(mouse_pos.x / 256), int(mouse_pos.y / 256))
	square.position = mouse_tile_pos * 256


func _on_Map_UI_basemap_type_changed(type):
	if basemap:
		basemap.map_type = type


func _on_Map_UI_zoom_in_clicked():
	camera.zoom_at(camera.zoom * camera.mouse_zoom_factor, camera.vp_size / 2)


func _on_Map_UI_zoom_out_clicked():
	camera.zoom_at(camera.zoom / camera.mouse_zoom_factor, camera.vp_size / 2)
