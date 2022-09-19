extends PopupDialog

func _ready():
	if OS.get_name() != "HTML5":
		$"%RichTextLabel".connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")

func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)
