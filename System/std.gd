extends Object

class_name CSTD

static var TEXTLANG : Dictionary

static func _static_init() -> void:
	return

static func CSETG(f : String) -> void:
	var conf := ConfigFile.new()
	
	conf.load(f)
	
	if not conf.has_section("general"):
		return
	
	LOPEN(conf.get_value("general", "textlang", ""))

static func LOPEN(f : String) -> void:
	var lfile := FileAccess.open(f, FileAccess.READ)
	
	if lfile:
		TEXTLANG = JSON.parse_string(lfile.get_as_text())
		return
	
	push_error("%s NOT FOUND!" % f)

const _LSTR_LFILEREAD := "LF"
const _LSTR_LFILEKEYW := ":"

const _LSTR_FMT_PREFX := "$"
const _LSTR_FMT_SUFIX := "@"

static func LSTR(s : String, args := Array()) -> String:
	if s.begins_with(_LSTR_LFILEREAD):
		var rstr := s.trim_prefix(_LSTR_LFILEREAD).split(_LSTR_LFILEKEYW)
		
		if rstr.size() == 2:
			var f := FileAccess.get_file_as_string(rstr[0])
			
			
			if f.length() > 0:
				var data := JSON.parse_string(f) as Dictionary
				
				if data and data.has(rstr[1]):
					return data[rstr[1]]
		
		return "ERROR ON PARSE TEXT (%s)" % s
	
	var lstrf := TEXTLANG.get(s, "(TEXT NOT FOUND) -> %s" % [s]) as String
	
	if args.size() > 0:
		var ocurrences : int
		
		for i in range(lstrf.length()):
			if i + 1 < lstrf.length() and lstrf[i] == _LSTR_FMT_PREFX and lstrf[i + 1] == _LSTR_FMT_SUFIX:
				lstrf[i + 1] = str(ocurrences)
				ocurrences += 1
		
		if ocurrences <= args.size():
			for i in range(ocurrences):
				lstrf = lstrf.replace("%s%s" % [_LSTR_FMT_PREFX, i], str(args[i]))
				
				continue
	
	return lstrf
