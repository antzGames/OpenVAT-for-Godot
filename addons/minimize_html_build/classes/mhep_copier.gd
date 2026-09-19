class_name MHEPCopier

var info: MHEPExportInfo
var aborted: bool


func _init( _info: MHEPExportInfo ):
	info = _info
	if _check_is_full():
		_copy_extra_files()


func _check_is_full() -> bool:
	var full = info.patch_ext.to_lower() == "html"
	
	if not full:
		info.patch = true
		MHEPUtils.debug( "INFO", "Standalone PCK. Only compression will be done" )
	
	return full


func _copy_extra_files():
	copy_and_check( "pako_inflate.min.js", "vendor" )


func copy_from_bin( filename: String ):
	var folder = filename.split(".")[0]
	copy_and_check( filename, info.delimiter.join([ "vendor", "bin", folder ]) )


func copy_and_check( filename: String, subdir = "" ):
	var fullname = filename if subdir == "" else subdir + info.delimiter + filename
	var target = info.in_target_dir( filename )
	
	var error = DirAccess.copy_absolute(
			info.in_addon_dir( fullname ), 
			target,
			511
	)
	
	if error:
		MHEPUtils.debug( "FATAL", "Can't open " + filename + " in project directory. Aborting" )
		aborted = true
		return
	
	if FileAccess.file_exists( target ):
		MHEPUtils.debug( "COPY", filename + " copied" )
	else:
		MHEPUtils.warn( filename + " was not copied. Build may not work as expected" )
