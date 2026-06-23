@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Object:
	var glb_path := get_source_file()
	var output_directory := glb_path.get_base_dir()

	_find_and_save_meshes(scene, output_directory)

	return scene

func _find_and_save_meshes(scene: Node, output_directory: String) -> void:
	if scene is MeshInstance3D and scene.mesh:
		var mesh_copy: ArrayMesh = scene.mesh.duplicate()

		var mesh_name: String = scene.name.validate_filename()
		var save_path: String = output_directory.path_join(mesh_name + ".res")

		var err := ResourceSaver.save(mesh_copy, save_path)
		if err == OK:
			print("Saved mesh to: ", save_path)
		else:
			push_error("Failed to save mesh to: ", save_path)

	for child in scene.get_children():
		_find_and_save_meshes(child, output_directory)
