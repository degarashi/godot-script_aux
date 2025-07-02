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
	regex.compile(r"^(?:(?:\.+\s+)|(?:))class_name\s+([\w_]+)")
	var res := regex.search(code)
	if res:
		return res.get_string(1)
	return default
