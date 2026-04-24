@tool
extends EditorExportPlugin

var _path: String = ""
var _features: PackedStringArray

const html_dir_path = "res://addons/easy_web_loader/html/"

@export_file_path() var click_me_image

func _get_name() -> String:
	return "Easy Web Export"


func _export_begin(features: PackedStringArray, _is_debug: bool, path: String, _flags: int) -> void:
	var path_lower: String = path.to_lower()
	var is_macos: bool = "macos" in features
	var is_zip: bool = path_lower.ends_with(".zip")

	_features = features

	if (is_zip and not is_macos) or path_lower.ends_with("pck"):
		# "Export PCK/ZIP..." option, ignore, unless its MacOS, then
		# we can't really tell that option apart
		return

	_path = path
	var export_path: String = path.get_base_dir()

	if not len(export_path):
		return

	for file_set: CFOEFileSet in _get_image_files():
		var dest_path: String = export_path.path_join(file_set.dest)
		var base: String = dest_path.get_base_dir()
		var file_set_features: PackedStringArray = file_set.features

		if len(file_set_features) and not _feature_match(features, file_set_features):
			continue

		if not DirAccess.dir_exists_absolute(base):
			var err: int = DirAccess.make_dir_recursive_absolute(base)
			if err != OK:
				push_error("Error creating destination path \"%s\". Skipping." % base)
				continue

		var source_data: PackedByteArray = FileAccess.get_file_as_bytes(file_set.source)

		if not len(source_data):
			_push_err("Error reading or file empty - \"%s\"! Skipping." % file_set.source)
			continue

		var dest: FileAccess = FileAccess.open(dest_path, FileAccess.WRITE)

		if not dest:
			_push_err("Error opening destination for \"%s\" writing! Skipping." % dest_path)
			continue

		dest.store_buffer(source_data)
		dest.close()


func _export_end() -> void:
	pass

func _get_image_files() -> Array[CFOEFileSet]:
	var files: Array[CFOEFileSet]
	
	# Get all files in html directory
	var dir := DirAccess.open(html_dir_path)
	if not dir: printerr("Could not open HTML folder: " + html_dir_path); return files
	
	dir.list_dir_begin()
	var html_files := dir.get_files()
	
	# Get the mandatory clickme and loading images
	if html_files.has("clickme.png"):
		files.append(CFOEFileSet.create(html_dir_path + "clickme.png","clickme.png", PackedStringArray(["web"])))
		print_rich("Added [color=yellow]clickme.png[/color] to the web export.")
	else:
		printerr("clickme.png not found in " + html_dir_path)
	if html_files.has("loading.png"):
		files.append(CFOEFileSet.create(html_dir_path + "loading.png","loading.png", PackedStringArray(["web"])))
		print_rich("Added [color=yellow]loading.png[/color] to the web export.")
	else:
		printerr("loading.png not found in " + html_dir_path)
	
	for file: String in html_files:
		# filter out html and .import files 
		if file.contains("clickme.png"): continue
		if file.contains("loading.png"): continue
		if file.contains(".import"): continue
		if file.contains(".html"): continue
		files.append(CFOEFileSet.create(html_dir_path + file, file, PackedStringArray(["web"])))
		print_rich("Added [color=yellow]" + file + "[/color] to the web export.")

	return files

func _push_err(error: String) -> void:
	push_error("[easywebloader] %s" % error)


func _feature_match(requested_features: PackedStringArray, limited_features: PackedStringArray) -> bool:
	for feature: String in limited_features:
		if feature in requested_features:
			return true
	return false
