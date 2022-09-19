extends Node2D

signal location_detected

onready var camera := $TouchCamera2D
onready var square := $Polygon2D
onready var basemap := $BaseTileMap
onready var locationMarker := $LocationMarker

var GpsSingleton = null
var isFirstLocationError = true

func _ready():
	camera.set_position(Global.epsg4326_to_pixel_pos(16.046480, 108.200665))
	camera._position = camera.position
	locationMarker.position = Global.epsg4326_to_pixel_pos(16.046480, 108.200665)
	
	get_tree().connect("on_request_permissions_result", self, "result")
	if (OS.request_permissions()):
		result("", true)
		
func _exit_tree():
	if GpsSingleton != null:
		GpsSingleton.stopLocationUpdates()

func _process(_delta):
	var mouse_pos := get_local_mouse_position()
#	print(mouse_pos)
	var mouse_tile_pos := Vector2(int(mouse_pos.x / 256), int(mouse_pos.y / 256))
	square.position = mouse_tile_pos * 256
	locationMarker.scale = camera.zoom


func _on_Map_UI_basemap_type_changed(type):
	if basemap:
		basemap.map_type = type


func _on_Map_UI_zoom_in_clicked():
	camera.zoom_at(camera.zoom * camera.mouse_zoom_factor, camera.vp_size / 2)


func _on_Map_UI_zoom_out_clicked():
	camera.zoom_at(camera.zoom / camera.mouse_zoom_factor, camera.vp_size / 2)

# Dictionary
	# |-> location["longitude"]
	# |-> location["latitude"]
	# |-> location["accuracy"]
	# |-> location["verticalAccuracyMeters"]
	# |-> location["altitude"]
	# |-> location["speed"]
	# |-> location["time"]
func on_location_updates(location: Dictionary):
	locationMarker.show()
	locationMarker.position = Global.epsg4326_to_pixel_pos(location["latitude"], location["longitude"])
	emit_signal("location_detected")

func on_last_known_location(location: Dictionary):
	locationMarker.show()
	locationMarker.position = Global.epsg4326_to_pixel_pos(location["latitude"], location["longitude"])

# 100 -> ACTIVITY_NOT_FOUND
# 101 -> LOCATION_UPDATES_NULL
# 102 -> LAST_KNOWN_LOCATION_NULL
# 103 -> LOCATION_PERMISSION_MISSING
func on_location_error(errorCode: int, message: String):
	if errorCode in [101, 102]:
		locationMarker.hide()
	elif isFirstLocationError:
		isFirstLocationError = false
	else:
		OS.alert("Error %s: %s" % [errorCode, message], "Location error")

func result(permission: String, granted: bool):
	if Engine.has_singleton("LocationPlugin"):
		GpsSingleton = Engine.get_singleton("LocationPlugin")
		GpsSingleton.connect("onLocationUpdates", self, "on_location_updates")
		GpsSingleton.connect("onLastKnownLocation", self, "on_last_known_location")
		GpsSingleton.connect("onLocationError", self, "on_location_error")
		GpsSingleton.startLocationUpdates(5000.0, 10000.0)
		GpsSingleton.getLastKnowLocation()


func _on_Map_UI_location_clicked():
	if locationMarker.visible:
		camera.set_zoom(camera.zoom)
		camera._zoom = camera.zoom
		camera.set_position(locationMarker.position)
		camera._position = camera.position
