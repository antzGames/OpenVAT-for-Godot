@tool
extends EditorPlugin

var export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	export_plugin = (load(_get_path("copy_files_on_export.gd")) as GDScript).new()
	add_export_plugin(export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(export_plugin)

func _get_path(sub_path: String) -> String:
	@warning_ignore("unsafe_method_access")
	return get_script().resource_path.get_base_dir().path_join(sub_path)
