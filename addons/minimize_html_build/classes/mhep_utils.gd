class_name MHEPUtils

const SIZE_KB = 1024
const SIZE_MB = SIZE_KB * 1024
const SIZE_GB = SIZE_MB * 1024

static var _debug: bool = true

var os: String = ""
var _info: MHEPExportInfo


func _init( info: MHEPExportInfo ):
	os = OS.get_name()
	_info = info


static func enable_debug( state: bool ):
	_debug = state


static func warn( text: String ):
	push_warning( "[MHEP] " + text )


static func debug( prefix: String, text: String ):
	if _debug:
		var _pre
		
		match prefix:
			"":
				_pre = " "
			"^":
				_pre = " ^^^"
			_:
				_pre = " [" + prefix + "] "
				
		print( "[MHEP]" + _pre + text )


static func string_size( numeric: int ) -> String:
	if numeric > SIZE_GB:
		return str( numeric / SIZE_GB ) + " GiB"
	elif numeric > SIZE_MB:
		return str( numeric / SIZE_MB ) + " MiB"
	elif numeric > SIZE_KB:
		return str( numeric / SIZE_KB ) + " KiB"
	else:
		return str(numeric) + " B"


func get_file_size( relative: String ) -> int:
	var f = FileAccess.open( _info.in_target_dir( relative ), FileAccess.READ )
	
	if f == null:
		debug( "FATAL", "Cannot open file: " + _info.in_target_dir( relative ))
		return -1
	
	var size = f.get_length()
	f.close()
	return size


func get_files( ext: String ) -> Array:
	var all: Array = _info.get_target_files()
	
	return all.filter(
		func( file: String ):
			return file.get_extension().to_lower() == ext.to_lower()
	)
