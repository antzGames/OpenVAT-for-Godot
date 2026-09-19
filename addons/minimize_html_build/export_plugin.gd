class_name MinimizeHTMLExportPlugin
extends EditorExportPlugin

var _plugin_name = "Minimize HTML Build"
var _export_info: MHEPExportInfo
var _runned: bool = false

func _get_name() -> String:
	return _plugin_name


func _supports_platform( platform: EditorExportPlatform ) -> bool:
	return ( platform is EditorExportPlatformWeb )


func _export_begin( 
		features: PackedStringArray, 
		is_debug: bool, 
		path: String, 
		_flags: int 
):
	_runned = false
	
	if features.has("web"):
		_runned = true
		MHEPUtils.enable_debug( is_debug )
		MHEPUtils.debug( "v 1.1.3", "---- EXPORT STARTED ----" )
		
		_export_info = MHEPExportInfo.new( path )


func _export_end():
	if _runned:
		# Run compression after all project files were created
		var copier = MHEPCopier.new( _export_info )
		
		if copier.aborted:
			MHEPUtils.debug( "", "---- EXPORT COMPRESSION ABORTED ----" )
			return
		
		MHEPCompresser.compress( copier )
		
		if not _export_info.patch:
			MHEPHTML.fix( _export_info )
			MHEPJS.fix( _export_info )
			
		MHEPUtils.debug( "", "---- EXPORT FINISHED ----" )
