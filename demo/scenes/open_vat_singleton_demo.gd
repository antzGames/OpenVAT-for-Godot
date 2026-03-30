class_name OpenVATSingletonDemo
extends Node3D

@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var demo_mesh: MeshInstance3D = $DemoMesh

@onready var pivot: Node3D = $Pivot
@onready var camera_3d: Camera3D = $Pivot/Camera3D

@onready var shadows_check_button: CheckButton = $UI/MarginContainer/VBox/HBoxShadows/ShadowsCheckButton
@onready var v_sync_check_button: CheckButton = $UI/MarginContainer/VBox/HBoxShadows2/VSyncCheckButton
@onready var title_label: Label = $UI/Title

@export var title: String
@export var next_scene: PackedScene

@export_category("Camera")
@export var rotate_camera: bool
@export var camera_position: Vector3 = Vector3(0,20,55)
@export var camera_lookat: Vector3 = Vector3(0,0,0)

var node3D: Node3D = Node3D.new()
var location: Vector3 = Vector3.ZERO

func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if v_sync_check_button.button_pressed else DisplayServer.VSYNC_DISABLED)
	camera_3d.global_position = camera_position
	camera_3d.look_at(camera_lookat)
	title_label.text = title

func _process(delta: float) -> void:
	if rotate_camera:
		pivot.rotate_y(delta * 0.1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_scene"):
		if next_scene: get_tree().change_scene_to_packed(next_scene)
		else:
			if OS.get_name() != "Web": get_tree().quit()

func _on_shadows_check_button_toggled(toggled_on: bool) -> void:
	shadows_check_button.text = str(toggled_on).capitalize()
	directional_light_3d.shadow_enabled = toggled_on

func _on_v_sync_check_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)

func _on_speed_check_button_value_changed(value: float) -> void:
	demo_mesh.mesh.surface_get_material(0).set_shader_parameter("speed", value)
