extends Object

class_name lstr

static var data : Dictionary

static func open(filepath : String) -> void:
	var f := FileAccess.open(filepath, FileAccess.READ)
	
	if not f:
		push_error("Text File Not Found!")
		return
	
	var j := JSON.parse_string(f.get_as_text()) as Dictionary
	data = j

static func Lstr(s : String) -> String:
	return data.get(s, "[%s value.error $data.len %s" % [s, data.size()])
