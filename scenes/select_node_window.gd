@tool
class_name NodeTreeWindow
extends Window

signal on_ok_pressed(node: Node)

const WINDOW_TITLE = "Choose Node"

var _node_root: Node
var _sel_nodes: Array[Node]
# Node, int(dummy)
var _ancestor: Dictionary

@onready var node_tree: Tree = %NodeTree
@onready var ok_button: Button = %OK_Button
@onready var cancel_button: Button = %Cancel_Button


static func _get_builtin_icon(icon_name: String) -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon(icon_name, "EditorIcons")


static func _setup_item(node: Node, item: TreeItem) -> void:
	item.set_text(0, node.name)
	item.set_icon(0, _get_builtin_icon(node.get_class()))
	item.set_metadata(0, node)
	if node.get_script() == null:
		item.set_custom_color(0, Color(1, 0.5, 0.5, 0.5))
		item.set_selectable(0, false)


static func _collect_ancestors(nodes: Array[Node]) -> Dictionary:
	var res := {}
	for node in nodes:
		var cur := node
		cur = cur.get_parent()
		while true:
			if cur == null:
				break
			res[cur] = 0
			cur = cur.get_parent()
	return res


func setup(root: Node, sel_nodes: Array[Node]) -> void:
	_node_root = root
	_ancestor = _collect_ancestors(sel_nodes)


func _recursive_get(node: Node, item: TreeItem) -> void:
	for c in node.get_children():
		if c in _ancestor:
			var item_c := node_tree.create_item(item)
			_setup_item(c, item_c)
			_recursive_get(c, item_c)


func _on_item_selected() -> void:
	ok_button.disabled = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	if _node_root == null:
		return

	transient = true
	exclusive = true

	title = WINDOW_TITLE
	ok_button.disabled = true
	close_requested.connect(queue_free)
	cancel_button.pressed.connect(queue_free)
	node_tree.item_selected.connect(_on_item_selected)

	var root_item := node_tree.create_item()
	_setup_item(_node_root, root_item)
	_recursive_get(_node_root, root_item)


func _on_ok_button_pressed() -> void:
	var sel := node_tree.get_selected()
	if sel != null:
		on_ok_pressed.emit(sel.get_metadata(0))
		queue_free()
