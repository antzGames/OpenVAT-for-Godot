@tool
class_name OpenVATMultiMeshInstance3D
extends MultiMeshInstance3D
## Allows [MultiMeshInstance3D] vertex animation functionality that is OpenVAT compatible.


var _rollover_value : float = ProjectSettings.get_setting("rendering/limits/time/time_rollover_secs")

#region Variables and Exports
## Exported [Mesh] from OpenVAT, with [ShaderMaterial] set in surface_0
@export var exported_mesh: ArrayMesh:
	set(value):
		exported_mesh = value
		if !multimesh:
			_create_multimesh()
		multimesh.mesh = exported_mesh

## Total number of instances in the multimesh.
@export var instance_count: int = 10

## Random animation offset on/off. [br]
## Recommend to keep this on.
@export var rand_anim_offset: bool = true

## OpenVAT auto configuration
@export_category("OpenVAT Config")
@export_file("*.json") var openvat_json_config_file: String
@export_tool_button(" Import JSON  ", "FileAccess") var import_json_action = import_json
@export var min_values: Vector3:
	set(value):
		min_values = value
		if !multimesh:
			_create_multimesh()
		if multimesh.mesh:
			multimesh.mesh.surface_get_material(0).set_shader_parameter("min_values", value)
@export var max_values: Vector3:
	set(value):
		max_values = value
		if !multimesh:
			_create_multimesh()
		if multimesh and multimesh.mesh:
			multimesh.mesh.surface_get_material(0).set_shader_parameter("max_values", value)

## Animation tracks: [br]
## The array of animation track with OpenVAT JSON meta data.[br]
## See [OpenVATAnimationTrack][br] for more info.
var animation_tracks: Array[OpenVATAnimationTrack] = []

var frames: int
var custom_data: Color
var custom_color: Color
#endregion

#region Built in Functions
func _enter_tree():
	pass
	
func _exit_tree():
	# Clean-up of the plugin goes here.
	pass

func _init() -> void:
	pass

func _get_configuration_warnings(): # display the warning on the scene dock
	var warnings = []
	if !exported_mesh:
		warnings.push_back('No exported mesh assigned')
	if !openvat_json_config_file:
		warnings.push_back('No OpenVAT JSON file assigned')
	return warnings
	
func _validate_property(property: Dictionary): # update the config warnings
	if property.name == "animation_tracks" or property.name == "multimesh":
		update_configuration_warnings()
	if property.name.begins_with("multimesh"):
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
func _create_multimesh():
	multimesh = MultiMesh.new()
	multimesh.instance_count = 0
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	
func _ready() -> void:
	if multimesh:
		multimesh.instance_count = 0
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_custom_data = true # offsets, start/end frame, alpha
		multimesh.use_colors = true  # isLooping, timestamp
		multimesh.instance_count = instance_count
	else:
		_create_multimesh()
		
	if animation_tracks.size() == 0:
		import_json()
	else:
		print("OpenVATMultiMeshInstance3D: Number of animation tracks defined is: ", animation_tracks.size())

func _process(delta: float) -> void:
	pass
#endregion

#region instanced helper functions

## Updates the current instance_id with the provided animation_offset (0..1),
## unless rand_anim_offset = false, where it sets the animation_offset to 0
func update_instance_animation_offset(instance_id: int, animation_offset: float):
	animation_offset = clamp(animation_offset, 0.0, 1.0)
	custom_data = multimesh.get_instance_custom_data(instance_id)
	if rand_anim_offset:
		custom_data.r = animation_offset
	else:
		custom_data.r = 0.0
	multimesh.set_instance_custom_data(instance_id, custom_data)

## Updates the current instance_id with the provided track_number (0..animation_tracks.size()- 1)
func update_instance_track(instance_id: int, track_number: int):
	if track_number < 0 or track_number > animation_tracks.size() - 1: 
		printerr("[OpenVATMultiMeshInstance3D] -> update_instance_track(instance_id: int, track_number: int)]: track_number is out of bounds.")
		return 
	custom_data = multimesh.get_instance_custom_data(instance_id)
	custom_data.g = animation_tracks[track_number].startFrame 
	custom_data.b = animation_tracks[track_number].endFrame
	multimesh.set_instance_custom_data(instance_id, custom_data)
		
	reset_one_shot(instance_id)

## Updates the current instance_id with the provided alpha (0..1)
func update_instance_alpha(instance_id: int, alpha: float):
	alpha = clampf(alpha, 0.0, 1.0)
	custom_data = multimesh.get_instance_custom_data(instance_id)
	custom_data.a = alpha
	multimesh.set_instance_custom_data(instance_id, custom_data)

## Update the instance_id with the provided animation_offset, track_number, and alpha
## unless rand_anim_offset = false, where it sets the animation_offset to 0
func update_instance(instance_id: int, animation_offset: float, track_number: int, alpha: float):
	update_instance_animation_offset(instance_id, animation_offset)
	update_instance_track(instance_id, track_number)
	update_instance_alpha(instance_id, alpha)

## Update ALL INSTANCES with the provided animation_offset, track_number, and alpha
## unless rand_anim_offset = false, where it sets the animation_offset to 0
func update_all_instances(animation_offset: float, track_number: int, alpha: float):
	for instance in multimesh.instance_count:
		update_instance_animation_offset(instance, animation_offset)
		update_instance_track(instance, track_number)
		update_instance_alpha(instance, alpha)

# Tweened fades

## Fade out a specific instance.[br][br]
## [param instance_id] is the specific instance to fade.[br]
## [param fade_out_time] the duration of the fade.[br]
## [param start_delay] is the delay before fade starts.
func fade_out_instance(instance_id: int, fade_out_time: float = 1.0, start_delay: float = 0.0):
	if fade_out_time < 0: return
	if instance_id >= multimesh.instance_count: return
	
	var custom_data: Color = multimesh.get_instance_custom_data(instance_id)
	if custom_data.a < 0: return
	
	var fade_tween = create_tween()
	fade_tween.tween_method(
		_do_tween_fade.bind(instance_id),
		multimesh.get_instance_custom_data(instance_id).a,
		0,
		fade_out_time).set_delay(start_delay)

## Fade in a specific instance.[br][br]
## [param instance_id] is the specific instance to fade in.[br]
## [param fade_out_time] the duration of the fade.[br]
## [param start_delay] is the delay before fade starts.
func fade_in_instance(instance_id: int, fade_in_time: float = 1.0, start_delay: float = 0.0):
	if fade_in_time < 0: return
	if instance_id >= multimesh.instance_count: return

	var custom_data: Color = multimesh.get_instance_custom_data(instance_id)
	if custom_data.a >= 1: return
	
	var fade_tween = create_tween()
	fade_tween.tween_method(
		_do_tween_fade.bind(instance_id),
		multimesh.get_instance_custom_data(instance_id).a,
		1,
		fade_in_time).set_delay(start_delay)

func _do_tween_fade(value: float, instance_id: int):
	var custom_data: Color = multimesh.get_instance_custom_data(instance_id)
	custom_data.a = value
	multimesh.set_instance_custom_data(instance_id, custom_data)
	
# Play next track

## Plays the next animation track for the provided instance_id
func play_next_track_instance(instance_id: int):
	var track_number: int = get_track_number_from_instance(instance_id)
	track_number += 1
	if track_number > animation_tracks.size() - 1: track_number = 0
	update_instance_track(instance_id, track_number)
	
## Plays the next animation track for ALL INSTANCES
func play_next_track_all_instances():
	var track_number : int
	for instance in multimesh.instance_count:
		track_number = get_track_number_from_instance(instance)
		track_number += 1
		if track_number > animation_tracks.size() - 1: track_number = 0
		update_instance_track(instance, track_number)

# Get functions

## get [animationOpenVATAnimationTrack] from instance.
## instance must have been initialized. 
## Returns null if instance_id not found
func get_animation_from_instance(instance_id: int) -> OpenVATAnimationTrack:
	custom_data = multimesh.get_instance_custom_data(instance_id)
	
	for track: OpenVATAnimationTrack in animation_tracks:
		if is_equal_approx(custom_data.g, float(track.startFrame)) and is_equal_approx(custom_data.b, float(track.endFrame)):
			return track
			
	return null

## get track_number using an animation object to search animation_tracks.
## Returns -1 if not found or animation object is null.
func get_track_number_from_animation(animation: OpenVATAnimationTrack) -> int:
	if !animation: return -1
	for i in range(animation_tracks.size()):
		if animation == animation_tracks[i]: return i
	
	return -1

## get track_number from animation track name
## Returns -1 if not found.
func get_track_number_from_name(name: String) -> int:
	for i in range(animation_tracks.size()):
		if animation_tracks[i].name.to_lower() == name.to_lower():
			return i
	
	return -1
	
## get track_number from start/end frames.[br]
## However [get_track_number_from_animation] is a better option.
## Returns -1 if not found.
func get_track_number_from_start_end_frames(start: int, end: int) -> int:
	for i in range(animation_tracks.size()):
		if Vector2i(start,end) == Vector2i(animation_tracks[i].startFrame, animation_tracks[i].endFrame): return i
	
	return -1

## get current track_number from instance_id
## Returns -1 if not found.
func get_track_number_from_instance(instance_id: int) -> int:
	return get_track_number_from_animation(get_animation_from_instance(instance_id))
	
#endregion


## Restarts the one shot animation for a specific instance_id.[br][br]
## Only valid if instanced animation track  [is_looping] is true
func reset_one_shot(instance_id: int):
	custom_color = multimesh.get_instance_color(instance_id)
	
	if get_animation_from_instance(instance_id).isLooping:
		custom_color.r = 1.0
	else:
		custom_color.r = 0.0
		custom_color.g = get_current_timestamp()
	
	multimesh.set_instance_color(instance_id, custom_color)

func get_current_timestamp() -> float:
	return fmod((float(Time.get_ticks_msec()) / 1000.0), _rollover_value) - 0.5


#region JSON config file import

func import_json():
	if !multimesh:
		_create_multimesh()
		print_rich("Multimesh instance created.")
	elif !exported_mesh:
		printerr("No exported mesh assigned.")
		return

	if !openvat_json_config_file or openvat_json_config_file.length() == 0:
		printerr("No JSON file set. Select the OpenVAT JSON file.")
		return

	print_rich("\n[color=cyan]Beginning OpenVAT JSON config file import...")

	var file = FileAccess.open(openvat_json_config_file, FileAccess.READ)
	var content = file.get_as_text()

	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data_received = json.data
		print_rich("OpenVAT JSON file: [color=yellow]" + openvat_json_config_file + "[/color] contents: ")
		print_rich(str("[color=green]"), data_received, "[/color]")
		var j = JSON.parse_string(content)
		var os_remap = j["os-remap"]
		
		# Min/Max vectors
		var min_array = os_remap["Min"]
		min_values = Vector3(float(min_array[0]), float(min_array[1]), float(min_array[2]))
		print_rich(str("✅Minimum values parsed: [color=yellow]",min_values,"[/color]"))
		
		var max_array = os_remap["Max"]
		max_values = Vector3(float(max_array[0]), float(max_array[1]), float(max_array[2]))
		print_rich(str("✅Maximum values parsed: [color=yellow]",max_values,"[/color]"))
		frames = int(os_remap["Frames"])
		
		# Animations
		var anim_dict = j["animations"]
		if anim_dict.is_empty():
			animation_tracks.clear()
			var track: OpenVATAnimationTrack = OpenVATAnimationTrack.new()
			track.set_track("Default", 0, frames-1 , 24 , true)
			animation_tracks.append(track)
			print_rich(str("❌[color=orange]No animation meta data found.[/color]  Creating one track with ", frames, " frames."))
			print_rich(str("  🎞️Animation track 1: [color=yellow]", track.name, "[/color] Start/End Frames: [color=yellow]", track.startFrame , "-", track.endFrame, "[/color]"))			
		else:
			animation_tracks.clear()
			var i: int = 0
			# Loop through animation dictionary
			for key in anim_dict:
				var track: OpenVATAnimationTrack = OpenVATAnimationTrack.new()
				track.set_track(key, int(anim_dict[key]["startFrame"])-1, int(anim_dict[key]["endFrame"])-1, int(anim_dict[key]["framerate"]), bool(int(anim_dict[key]["looping"])))
				print_rich(str("  🎞️Animation track ", i, ": [color=yellow]", key, "[/color] Start/End Frames: [color=yellow]", track.startFrame , "-", track.endFrame, "[/color]"))
				animation_tracks.append(track)
				i += 1
			print_rich(str("✅Total animation tracks parsed: [color=yellow]",animation_tracks.size(),"[/color]"))			
			
		print_rich(str("✅Frames parsed: [color=yellow]",frames,"[/color]"))
		print_rich("[color=cyan]OpenVAT import completed.[/color]")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())
#endregion
