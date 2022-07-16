extends TileMap

export var map_type := 'sentinel' setget set_map_type
export var zoom_level: int = 10 setget set_zoom_level
export var manual_loading := false

onready var camera := $"../../TouchCamera2D"

var thread := Thread.new()
var mutex := Mutex.new()

var is_ready := false
var tile_directory: String
var tile_names_rect: Rect2
var thread_should_stop := false
var file_ext := 'png'
var tile_refs := {}

func stop_thread() -> void:
	if thread.is_active():
		thread.wait_to_finish()
		mutex.lock()
		thread_should_stop = true
		mutex.unlock()

func clear_map() -> void:
	clear()
	tile_set.clear()

func set_map_type(type: String) -> void:
	if map_type == type:
		return
	map_type = type	
	clear_map()
	init()

	
func set_zoom_level(level: int) -> void:
	if level == zoom_level:
		return
	zoom_level = level
	
	mutex.lock()
	clear_map()
	mutex.unlock()
	
	scale = Vector2.ONE * pow(2, Global.BASE_ZOOM_LEVEL - zoom_level)
	init()
	
func init() -> void:
	if not is_ready:
		return
		
	tile_directory = "res://resources/map_tiles/%s/%s" % [map_type, zoom_level]
	var dirnames := dir_contents(tile_directory)
	if dirnames.size() == 0:
		tile_names_rect.size = Vector2()
		return
	
	var first_dir_filenames := dir_contents("%s/%s" % [tile_directory, dirnames[0]])

	var col_count := first_dir_filenames.size()
	
	var ref_file := tile_directory + "/tile_refs.json"
	if ResourceLoader.exists(ref_file):
		col_count -= 1
		var packed_json: PackedJson = ResourceLoader.load(ref_file, "PackedDataContainer")
		var metadata: Dictionary = packed_json.instance()
		for pos in metadata['tiles']:
			call_deferred("load_map_tile", pos[0], pos[1])
#			load_map_tile(pos[0], pos[1])
		tile_refs = metadata['refs']
	
#	var file := File.new()
#	var col_count := first_dir_filenames.size()
#	if file.file_exists(tile_directory + "/tile_refs.json"):
#		col_count -= 1
#		file.open(tile_directory + "/tile_refs.json", File.READ)
#		var metadata: Dictionary = parse_json(file.get_as_text())
#		file.close()
#		for pos in metadata['tiles']:
#			load_map_tile(pos[0], pos[1])
#		tile_refs = metadata['refs']

	tile_names_rect = Rect2(dirnames[0] as int, first_dir_filenames[0] as int,
		dirnames.size(), first_dir_filenames.size())
	file_ext = first_dir_filenames[0].get_extension()
	
	if not manual_loading and not thread.is_active():
		thread_should_stop = false
		thread.start(self, "load_map_thread")

func point_in_size(size: Vector2, point: Vector2) -> bool:
	return  ((0 <= point.x) and (point.x <= (size.x - 1))
		and (0 <= point.y) and (point.y <= (size.y - 1)))

func dir_contents(path) -> PoolStringArray:
	var entries := PoolStringArray()
	var dir := Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name := dir.get_next()
		while (file_name != ''):
			if dir.current_is_dir():
				entries.append(file_name)
			elif file_name.ends_with('.import'):
				file_name = file_name.replace('.import', '')
				entries.append(file_name)
			file_name = dir.get_next()
		return entries
	else:
		print("An error occurred when trying to access the path: %s" % path)
		return PoolStringArray()

func list_nearby_tiles(pos: Vector2, distance: int) -> PoolVector2Array:
	var tiles := PoolVector2Array()
	for x in range(pos.x-distance+1, pos.x+distance):
		tiles.append(Vector2(x, pos.y-distance))
	for y in range(pos.y-distance, pos.y+distance):
		tiles.append(Vector2(pos.x+distance, y))
	for x in range(pos.x+distance, pos.x-distance, -1):
		tiles.append(Vector2(x, pos.y+distance))
	for y in range(pos.y+distance, pos.y-distance-1, -1):
		tiles.append(Vector2(pos.x-distance, y))
	return tiles

func scale_tile_pos(pos: Vector2) -> Vector2:
	var level_diff := Global.BASE_ZOOM_LEVEL - zoom_level
	if level_diff > 0:
		return Vector2(int(pos.x / pow(2, level_diff)), int(pos.y / pow(2, level_diff)))
	else:
		return pos
	pass

func load_map_tile(tile_x: int, tile_y: int) -> void:
#	if not point_in_size(tile_names_rect.size, Vector2(tile_x, tile_y)):
#		return
	if get_cell(tile_x, tile_y) != TileMap.INVALID_CELL:
		return
	var tile_id: int = tile_y + tile_names_rect.size.y * tile_x
	if tile_id in tile_set.get_tiles_ids():
		return
	if str(tile_id) in tile_refs:
		mutex.lock()
		set_cell(tile_x, tile_y, tile_refs[str(tile_id)])
		mutex.unlock()
	else:
		var tile_filepath := "%s/%s/%s.%s" % [tile_directory, tile_x, tile_y, file_ext]
		if not ResourceLoader.exists(tile_filepath):
			return
	#	var tile_texture: StreamTexture = load(tile_filepath)
		var tile_texture: StreamTexture = ResourceLoader.load(tile_filepath, "StreamTexture")
		mutex.lock()
		tile_set.create_tile(tile_id)
		tile_set.tile_set_texture(tile_id, tile_texture)
		set_cell(tile_x, tile_y, tile_id)
		mutex.unlock()


func load_map_thread(_1 = null):
	while true:
		var curr_cell_pos: Vector2 = world_to_map(to_local(camera.position))
		load_map_tile(curr_cell_pos.x, curr_cell_pos.y)
		yield(get_tree(), "idle_frame")
		for i in range(1, 3):
			for tile in list_nearby_tiles(curr_cell_pos, i):
				mutex.lock()
				if thread_should_stop:
					thread_should_stop = false
					mutex.unlock()
					stop_thread()
					return
				mutex.unlock()
				load_map_tile(tile.x, tile.y)
				yield(get_tree(), "idle_frame")
#				yield(get_tree().create_timer(0.001), "timeout")

func load_map_once() -> void:
	var curr_cell_pos: Vector2 = world_to_map(to_local(camera.position))
	load_map_tile(curr_cell_pos.x, curr_cell_pos.y)
	for i in range(1, 3):
		for tile in list_nearby_tiles(curr_cell_pos, i):
			load_map_tile(tile.x, tile.y)

func _init():
	# Set the TileSet here instead of in the property editor so that instances have their own tile sets
	tile_set = TileSet.new()

func _ready():
	set_process(visible)
	if not visible:
		return
	set_physics_process(false)
	set_physics_process_internal(false)
	is_ready = true
	
	if not camera:
		camera = $"../TouchCamera2D"
	
	init()

func _exit_tree():
	stop_thread()
