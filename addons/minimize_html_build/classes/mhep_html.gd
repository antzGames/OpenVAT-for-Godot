class_name MHEPHTML


static func fix( info: MHEPExportInfo ):
	_fix_main_html( info )


static func _debug( text: String ):
	MHEPUtils.debug( "HTML", text )


static func _fix_main_html( info: MHEPExportInfo ):
	var path = _get_exist_file( info )
	var content = _get_content( path )
	
	_save_content( path, _insert_pako( content ))


static func _get_exist_file( info: MHEPExportInfo ) -> String:
	var exts = [ ".html", ".htm"]
	
	for ext in exts:
		var path = info.in_target_dir( info.name + ext )
		
		if FileAccess.file_exists( path ):
			return path
			
	return ""


static func _get_content( path: String ) -> String:
	var file = FileAccess.open( path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	return content


static func _save_content( path: String, content: String ):
	var modified = FileAccess.open( path, FileAccess.WRITE)
	
	modified.store_string(content)
	modified.close()


# [ error, result ]
static func _insert_before( data: String, search: String, insert: String ) -> Array:
	if ( data.contains( search )):
		return [ true, data.replacen( search, insert + search ) ]
		
	return [ false, data ]


static func _insert_batch( data: String, variants: Array, insert: String ) -> Array:
	var res = []
	
	for v in variants:
		res = _insert_before( data, v, insert )
		
		if res[0]:
			_debug( "Placed pako before \"" + v + "\"" )
			return res
			
	return [ false, data ]


static func _insert_pako( raw: String ) -> String:
	var pakojs = "<script type=\"text/javascript\" src=\"pako_inflate.min.js\"></script>"
	var res = _insert_batch( raw, [ "</head>", "<body", "<canvas", "</body>", "</html>" ], pakojs )
	
	if res[0]:
		return res[1]
	
	_debug( "No points to insert pako found. Placed at the end of the HTML file." )
	return raw + pakojs
	
