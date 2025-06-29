@tool
class_name ContextMenu extends EditorContextMenuPlugin

signal on_make_define(nodes: Array[Node])
signal on_mark_unique(nodes: Array[Node])


func _popup_menu(paths: PackedStringArray) -> void:
	if paths.is_empty():
		return
	add_context_menu_item("Make Unique And Define", _make_unique_and_define)
	add_context_menu_item("Make Define", _make_define)


func _make_define(nodes: Array[Node]) -> void:
	on_make_define.emit(nodes)


func _make_unique_and_define(nodes: Array[Node]) -> void:
	var to_mark: Array[Node] = []
	for node in nodes:
		if not node.unique_name_in_owner:
			to_mark.append(node)
	on_mark_unique.emit(nodes)
