@tool
class_name ContextMenu extends EditorContextMenuPlugin

signal on_make_define(mark_unique: bool)


func _popup_menu(paths: PackedStringArray) -> void:
	if paths.is_empty():
		return

	var menu := PopupMenu.new()
	menu.add_item("Define")
	menu.add_item("Unique And Define")
	menu.id_pressed.connect(_on_submenu)
	add_context_submenu_item("Make Onready-Value", menu)


func _on_submenu(id: int) -> void:
	on_make_define.emit(id == 1)
