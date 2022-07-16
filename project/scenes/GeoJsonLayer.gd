extends Node2D

export var file_path := "res://data/coastline_line_simplified.geojson"
export var color := Color.darkgoldenrod
export var outline_width: float = 1.0
export var point_icon: Texture

onready var camera: Camera2D = $"../TouchCamera2D"

var font := Global.font

var data := {}
var point_features = {}

#func multiple_polygon2d():
#	for feature in data['features']:
#		for coordinates in feature['geometry']['coordinates']:
#			for shape in coordinates:
#				var points := PoolVector2Array()
#				for point in shape:
#					points.append(Global.epsg4326_to_pixel_pos(point[1], point[0]))
#
#				var polygon2d := Polygon2D.new()
#				polygon2d.polygon = points
#				add_child(polygon2d)
#
#func multiple_line2d():
#	for feature in data['features']:
#		for coordinates in feature['geometry']['coordinates']:
#			for shape in coordinates:
#				var points := PoolVector2Array()
#				for point in shape:
#					points.append(Global.epsg4326_to_pixel_pos(point[1], point[0]))
#
#				var line2d := Line2D.new()
#				line2d.points = points
#				line2d.default_color = color
#				line2d.width = outline_width
#				add_child(line2d)
#
#func direct_draw():
#	for feature in data['features']:
#		for coordinates in feature['geometry']['coordinates']:
#			for shape in coordinates:
#				var points := PoolVector2Array()
#				for point in shape:
#					points.append(Global.epsg4326_to_pixel_pos(point[1], point[0]))
#
#				draw_polyline(points, color, outline_width)
#
#func visual_server_draw():
#	for feature in data['features']:
#		for coordinates in feature['geometry']['coordinates']:
#			for shape in coordinates:
#				var points := PoolVector2Array()
#				var colors := PoolColorArray()
#				for point in shape:
#					points.append(Global.epsg4326_to_pixel_pos(point[1], point[0]))
#					colors.append(color)
#
#				VisualServer.canvas_item_add_polyline(get_canvas_item(), points, colors, outline_width)
#
#func multiple_mesh2d():
#	for feature in data['features']:
#		for coordinates in feature['geometry']['coordinates']:
#			for shape in coordinates:
#				var st := SurfaceTool.new()
#				st.begin(Mesh.PRIMITIVE_LINE_LOOP)
#				st.add_color(color)
#				for point in shape:
#					var pos := Global.epsg4326_to_pixel_pos(point[1], point[0])
#					st.add_vertex(Vector3(pos.x, pos.y, 0))
#
#				var mesh2d := MeshInstance2D.new()
#				mesh2d.mesh = st.commit(null, Mesh.ARRAY_COMPRESS_DEFAULT | Mesh.ARRAY_FLAG_USE_2D_VERTICES)
#				add_child(mesh2d)

func parse() -> void:
	for feature in data['features']:
		var geometry: Dictionary = feature['geometry']
		if geometry['type'] == "MultiLineString":
			var mesh := ArrayMesh.new()
			for coordinates in geometry['coordinates']:
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_LINE_STRIP)
				st.add_color(color)
				for point in coordinates:
					var pos := Global.epsg4326_to_pixel_pos(point[1], point[0])
					st.add_vertex(Vector3(pos.x, pos.y, 0))
				st.commit(mesh, Mesh.ARRAY_COMPRESS_DEFAULT | Mesh.ARRAY_FLAG_USE_2D_VERTICES)
		
			var mesh2d := MeshInstance2D.new()
			mesh2d.mesh = mesh
			add_child(mesh2d)
		elif geometry['type'] == "Point":
			var pos := Global.epsg4326_to_pixel_pos(geometry['coordinates'][1], geometry['coordinates'][0])
			var point := GeoJsonPoint.new()
			point.position = pos
			point.color = color
			point.props = feature['properties']
			add_child(point)
		else:
			for coordinates in geometry['coordinates']:
				for shape in coordinates:
					var st := SurfaceTool.new()
					st.begin(Mesh.PRIMITIVE_LINE_LOOP)
					st.add_color(color)
					for point in shape:
						var pos := Global.epsg4326_to_pixel_pos(point[1], point[0])
						st.add_vertex(Vector3(pos.x, pos.y, 0))

					var mesh2d := MeshInstance2D.new()
					mesh2d.mesh = st.commit(null, Mesh.ARRAY_COMPRESS_DEFAULT | Mesh.ARRAY_FLAG_USE_2D_VERTICES)
					add_child(mesh2d)

#func single_mesh2d():
#	var mesh := ArrayMesh.new()
#
#	for feature in data['features']:
#		for coordinates in feature['geometry']['coordinates']:
#			for shape in coordinates:
#				var st := SurfaceTool.new()
#				st.begin(Mesh.PRIMITIVE_LINE_LOOP)
#				st.add_color(color)
#				for point in shape:
#					var pos := Global.epsg4326_to_pixel_pos(point[1], point[0])
#					st.add_vertex(Vector3(pos.x, pos.y, 0))
#				st.commit(mesh, Mesh.ARRAY_COMPRESS_DEFAULT | Mesh.ARRAY_FLAG_USE_2D_VERTICES)
#
#	var mesh2d := MeshInstance2D.new()
#	mesh2d.mesh = mesh
#	add_child(mesh2d)

func _ready():
	set_process(visible)
	if not visible:
		return
	set_physics_process(false)
	set_physics_process_internal(false)
	
	var packed_json: PackedJson = ResourceLoader.load(file_path, "PackedDataContainer")
	data = packed_json.instance()
		
	parse()
