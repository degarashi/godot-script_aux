class_name DGAuxFunc extends Object

const INVALID_CHAR_FOR_NAME = ["-", "=", "+", "*", "?", ";"]


static func path_sanitize(name_str: String) -> String:
	var ret := name_str
	var has_invalid_ch: bool = false
	for ch in INVALID_CHAR_FOR_NAME:
		has_invalid_ch = has_invalid_ch or ret.contains(ch)
	if has_invalid_ch:
		return '"{}"'.format([ret], "{}")
	return ret


static func name_sanitize(name_str: String) -> String:
	for ch in INVALID_CHAR_FOR_NAME:
		name_str = name_str.replace(ch, "")
	return name_str.to_snake_case()


static func _store_string_to_file(path: String, s: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(s)
		file.close()
		return true
	return false


static func rewrite_script(scr: GDScript) -> bool:
	var ret := _store_string_to_file(scr.resource_path, scr.source_code)
	scr.reload()
	return ret


static func find_class_name(code: String, default: String) -> String:
	var regex = RegEx.new()
	regex.compile(r"(?m)^(?:(?:\.+\s+)|(?:))class_name\s+([\w_]+)")
	var res := regex.search(code)
	if res:
		return res.get_string(1)
	return default


static func get_window_rect(id: int) -> Rect2i:
	var size := DisplayServer.window_get_size(id)
	var pos := DisplayServer.window_get_position(id)
	return Rect2i(pos, size)


static func calc_center_position(rect0: Rect2i, size1: Vector2i) -> Vector2i:
	var size0 := rect0.size
	if size0.x < size1.x or size0.y < size1.y:
		return Vector2i.ZERO

	return rect0.position + size0/2 - size1/2
