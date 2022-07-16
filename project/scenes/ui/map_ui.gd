extends MarginContainer

signal basemap_type_changed(type)
signal zoom_in_clicked
signal zoom_out_clicked

var about_dialog: PopupDialog = preload("res://scenes/ui/AboutDialog.tscn").instance()

onready var type_chooser := $"VBox/HBox/PanelContainer/Grid/TypeChooser"
onready var menu_btn := $"VBox/HBox/MenuBtn"

func _ready():
	type_chooser.set_item_metadata(0, "sentinel")
	type_chooser.set_item_metadata(1, "administrative")
	type_chooser.set_item_metadata(2, "transportation")
	
	menu_btn.get_popup().connect("id_pressed", self, "_on_menu_item_pressed")
	
	add_child(about_dialog)



func _on_TypeChooser_item_selected(index):
	emit_signal("basemap_type_changed", type_chooser.get_item_metadata(index))


func _on_ZoomIn_pressed():
	emit_signal("zoom_in_clicked")


func _on_ZoomOut_pressed():
	emit_signal("zoom_out_clicked")

func _on_menu_item_pressed(id: int):
	if id == 0:
		about_dialog.popup_centered()
