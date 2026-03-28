class_name OpenVATInstanceDemo
extends Node3D

@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D

@onready var vat_multi_mesh_instance_3d: OpenVATMultiMeshInstance3D = $OpenVATMultiMeshInstance3D
@onready var mesh_floor: MeshInstance3D = $Floor
@onready var pivot: Node3D = $Pivot
@onready var camera_3d: Camera3D = $Pivot/Camera3D

@onready var title_label: Label = $UI/Title
@onready var instance_count: Label = $UI/MarginContainer/VBox/HBoxCount/InstanceCount
@onready var shadows_check_button: CheckButton = $UI/MarginContainer/VBox/HBoxShadows/ShadowsCheckButton
@onready var v_sync_check_button: CheckButton = $UI/MarginContainer/VBox/HBoxShadows2/VSyncCheckButton

@export var title: String
@export var next_scene: PackedScene

@export_category("Instance Rotation")
@export var randomize_rotation: bool

@export_category("Instance Scale")
@export var randomize_scale: bool
@export var base_scale: float = 1.0
@export var max_scale: float = 1.5

@export_category("Camera")
@export var rotate_camera: bool
@export var camera_position: Vector3 = Vector3(0,20,55)
@export var camera_lookat: Vector3 = Vector3(0,0,0)

var node3D: Node3D = Node3D.new()
var location: Vector3 = Vector3.ZERO

func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if v_sync_check_button.button_pressed else DisplayServer.VSYNC_DISABLED)
	instance_count.text = str(vat_multi_mesh_instance_3d.multimesh.instance_count)
	title_label.text = title
	camera_3d.global_position = camera_position
	camera_3d.look_at(camera_lookat)
	
	# setup all instances
	setupInstances()
		
func setupInstances():
	# change floor size based on instance count
	var s: float = sqrt(vat_multi_mesh_instance_3d.multimesh.instance_count) * 5
	mesh_floor.mesh.size = Vector2(s,s) 
	
	var a: int = 0 # animation track number
	for instance in vat_multi_mesh_instance_3d.multimesh.instance_count:
		# randomize the animation offset
		vat_multi_mesh_instance_3d.update_instance_animation_offset(instance, randf())
		# set the animation track number
		vat_multi_mesh_instance_3d.update_instance_track(instance, a)
		# set alpha to 1.0 -> you can fade out a specific instance by setting alpha to 0
		vat_multi_mesh_instance_3d.update_instance_alpha(instance, 1.0)
		# randomize scale, rotation, and location
		randomizeInstance(instance)
		
		# Unit tests for helper functions - you can comment this out
		#print("Instance: ", instance, "   Track: ", vat_multi_mesh_instance_3d.get_track_number_from_instance(instance), \
			#"   Frame Start/End:", vat_multi_mesh_instance_3d.get_start_end_frames_from_instance(instance), \
			#"   Test Vector2i: ", vat_multi_mesh_instance_3d.get_start_end_frames_from_track_number(a) == vat_multi_mesh_instance_3d.get_start_end_frames_from_instance(instance), \
			#"   Test Track: ", vat_multi_mesh_instance_3d.get_track_number_from_track_vector(vat_multi_mesh_instance_3d.get_start_end_frames_from_track_number(a)) == vat_multi_mesh_instance_3d.get_track_number_from_instance(instance))

		# this cycles threw each animation track number
		a += 1
		if a > vat_multi_mesh_instance_3d.number_of_animation_tracks - 1:
			a = 0
		
func randomizeInstance(i: int):
	var x = mesh_floor.mesh.size.x / 2
	var y = mesh_floor.mesh.size.y / 2
	
	node3D.scale = Vector3(base_scale,base_scale,base_scale)
	
	if randomize_scale:
		node3D.scale = Vector3(randf_range(base_scale, max_scale),randf_range(base_scale, max_scale),randf_range(base_scale, max_scale))
		
	location.x = randf_range(-x,x)
	location.z = randf_range(-y,y)
	location.y = 0
	
	if randomize_rotation:
		node3D.rotation.y = randf_range(0,TAU)
	
	node3D.position = location
	vat_multi_mesh_instance_3d.multimesh.set_instance_transform(i, node3D.transform)

func _process(delta: float) -> void:
	if rotate_camera:
		pivot.rotate_y(delta * 0.1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if next_scene: get_tree().change_scene_to_packed(next_scene)

func _on_shadows_check_button_toggled(toggled_on: bool) -> void:
	shadows_check_button.text = str(toggled_on).capitalize()
	directional_light_3d.shadow_enabled = toggled_on

func _on_v_sync_check_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)
