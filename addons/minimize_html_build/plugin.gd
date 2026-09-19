@tool
extends EditorPlugin

var _exporter: MinimizeHTMLExportPlugin


func _enter_tree():
	_exporter = MinimizeHTMLExportPlugin.new()
	add_export_plugin( _exporter )


func _exit_tree():
	remove_export_plugin( _exporter )
	_exporter = null
