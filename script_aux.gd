@tool
extends EditorPlugin

const OLD_SOURCE = "dg_old_source"
var context_menu: ContextMenu


func _undo_code() -> void:
	var eif := get_editor_interface()
	var scene_root := eif.get_edited_scene_root()
	var scr := scene_root.get_script() as GDScript

	var old_src: Array = scene_root.get_meta(OLD_SOURCE, [])
	if old_src.is_empty():
		eif.get_editor_toaster().push_toast(
			"Internal Error (_undo_code())", EditorToaster.SEVERITY_ERROR
		)
		return
	scr.source_code = old_src.pop_back()
	scene_root.set_meta(OLD_SOURCE, old_src)
	DGAuxFunc.rewrite_script(scr)


func _do_code(code: String) -> void:
	var eif := get_editor_interface()
	var scene_root := eif.get_edited_scene_root()
	var scr := scene_root.get_script() as GDScript

	var old_src: Array = scene_root.get_meta(OLD_SOURCE, [])
	old_src.append(scr.source_code)
	scene_root.set_meta(OLD_SOURCE, old_src)
	scr.source_code = code
	DGAuxFunc.rewrite_script(scr)


func _get_selecting_nodes() -> Array[Node]:
	var eif := get_editor_interface()
	var sel := eif.get_selection()
	return sel.get_selected_nodes()


func _mark_unique(nodes: Array[Node]) -> void:
	var scene_root := get_editor_interface().get_edited_scene_root()
	var undo := EditorInterface.get_editor_undo_redo()
	undo.create_action("Mark Unique")
	for node in nodes:
		if node == scene_root:
			continue
		if not node.unique_name_in_owner:
			undo.add_do_property(node, "unique_name_in_owner", true)
			undo.add_undo_property(node, "unique_name_in_owner", false)
	undo.commit_action()


func _make_define(mark_unique: bool) -> void:
	var nodes := _get_selecting_nodes()

	var eif := get_editor_interface()
	var scene_root := eif.get_edited_scene_root()
	var scr := scene_root.get_script() as GDScript
	if scr == null:
		eif.get_editor_toaster().push_toast(
			"SceneRoot Node has no Script.", EditorToaster.SEVERITY_ERROR
		)
		return

	if mark_unique:
		_mark_unique(nodes)

	var to_add: Array[String] = []
	for node in nodes:
		# Rootを除く
		if node == scene_root:
			if len(nodes) == 1:
				eif.get_editor_toaster().push_toast("No code added.", EditorToaster.SEVERITY_INFO)
				return
			continue

		var name := node.name
		var uni_name := "%" + DGAuxFunc.path_sanitize(name)
		var sc_name := "$" + DGAuxFunc.path_sanitize(str(scene_root.get_path_to(node)))

		var cls_name := node.get_class()
		var scr2 := node.get_script()
		if scr2 != null:
			cls_name = DGAuxFunc.find_class_name(scr2.source_code, cls_name)

		to_add.append(
			"@onready var {}: {} = {}".format(
				[
					DGAuxFunc.name_sanitize(name),
					cls_name,
					uni_name if node.unique_name_in_owner else sc_name
				],
				"{}"
			)
		)

	var code := scr.source_code
	code = code.replace("\r\n", "\n")
	var lines := code.split("\n")
	code = ""

	# 既に記述がある物は省く
	var actual_add: Array[String] = []
	for toadd in to_add:
		var found := false
		for line in lines:
			if toadd == line:
				found = true
				break
		if not found:
			actual_add.append(toadd)

	to_add.clear()

	if actual_add.is_empty():
		eif.get_editor_toaster().push_toast("No code added.", EditorToaster.SEVERITY_INFO)
		return

	var undo_e := EditorInterface.get_editor_undo_redo()
	undo_e.create_action("Make Define Nodes")
	# コード挿入位置の計算
	var insert_pos := _search_insert_position(lines)
	var a := lines.slice(0, insert_pos)
	a.append_array(actual_add)
	a.append_array(lines.slice(insert_pos))
	undo_e.add_do_method(self, "_do_code", "\n".join(a))
	a.clear()
	undo_e.add_undo_method(self, "_undo_code")
	undo_e.commit_action()


static func _search_insert_position(lines: Array[String]) -> int:
	# @onready varで始まってる行を探す
	var idx: int = 0
	for line in lines:
		if line.begins_with("@onready var"):
			return idx
		idx += 1

	# とりあえず先頭3行目に加える
	return 3


func _enter_tree() -> void:
	context_menu = ContextMenu.new()
	context_menu.on_make_define.connect(_make_define)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, context_menu)


func _exit_tree() -> void:
	remove_context_menu_plugin(context_menu)
