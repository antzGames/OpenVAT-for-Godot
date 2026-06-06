# Visual Shader version of openvat_instanced.gdshader
# Allows for more advanced visuals while still being VAT-compatible.
# Instructions:
# - Inside Vertex mode, create an OpenVatApplier node.
# - Use the vertex and normal outputs as the basis for the vertex shader.
# Now you can also freely apply your own shader logic while still having VAT animations!
# Albedo textures can still be used like the original shader, just use the Fragment mode like normal.
# Original Source (credit): https://github.com/antzGames/OpenVAT-for-Godot
# Fork Source: https://github.com/RakkenTi/OpenVAT-for-Godot-Extended
@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeOpenVAT

func _get_name() -> String:
	return "OpenVATApplier"

func _get_category() -> String:
	return "OpenVAT"

func _get_description() -> String:
	return "Integrates OpenVAT animation textures natively. All parameter controls are automatically added to the inspector!"

func _get_return_icon_type() -> PortType:
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count() -> int:
	return 0

func _get_output_port_count() -> int:
	return 2

func _get_output_port_name(port: int) -> String:
	match port:
		0: return "vat_vertex"
		1: return "vat_normal"
	return ""

func _get_output_port_type(port: int) -> PortType:
	match port:
		0: return PORT_TYPE_VECTOR_3D
		1: return PORT_TYPE_VECTOR_3D
	return PORT_TYPE_VECTOR_3D

func _get_global_code(mode: Shader.Mode) -> String:
	return """
	group_uniforms OpenVAT;
	uniform sampler2D vertex_animation_texture;
	uniform vec3 min_values;
	uniform vec3 max_values;
	group_uniforms;
	"""

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	return """
	// from openvat_instanced.gdshader
	bool is_looping = COLOR.r > 0.5;
	float timestamp = COLOR.g;

	float start_frame = INSTANCE_CUSTOM.g;
	float end_frame = INSTANCE_CUSTOM.b;
	float num_frames = end_frame - start_frame;
	float frame_offset = num_frames * INSTANCE_CUSTOM.r;
	float speed = max(1.0, COLOR.b);

	ivec2 resolution = textureSize(vertex_animation_texture, 0);

	if (abs(num_frames) < 0.0001) num_frames = 0.0001;

	float frame_time;
	float current_frame;
	float next_frame;
	float time_scale_normalized = (TIME - timestamp) * (speed / num_frames);
	
	if (is_looping) {
		frame_time = mod(time_scale_normalized, 1.0);
		current_frame = start_frame + mod((frame_time * num_frames) + frame_offset, num_frames);
		next_frame = current_frame + 1.0;
		if (next_frame > end_frame) next_frame = start_frame;
	} else {
		frame_time = time_scale_normalized;
		current_frame = start_frame + (frame_time * num_frames) + frame_offset;
		next_frame = current_frame + 1.0;
		if (next_frame >= end_frame){
		current_frame = end_frame;
			next_frame = end_frame;
		} 
	}

	float blend = fract(frame_time);

	float frame_step = 1.0 / float(resolution.y);
	vec2 current_offset_uv = UV2 + vec2(0.0, current_frame * frame_step);
	vec2 next_offset_uv = UV2 + vec2(0.0, next_frame * frame_step);

	vec3 pos_curr = texture(vertex_animation_texture, current_offset_uv).rgb;
	vec3 pos_next = texture(vertex_animation_texture, next_offset_uv).rgb;
	vec3 pos_interp = mix(pos_curr, pos_next, blend);
	vec3 pos_rescaled = min_values + pos_interp * (max_values - min_values);
	vec3 pos_b2g = vec3(pos_rescaled.x, pos_rescaled.z, -pos_rescaled.y);

	%s = VERTEX + pos_b2g;

	vec2 normals_uv_shift = vec2(0.0, 0.5);
	vec3 norm_curr = texture(vertex_animation_texture, current_offset_uv + normals_uv_shift).rgb;
	vec3 norm_next = texture(vertex_animation_texture, next_offset_uv + normals_uv_shift).rgb;
	vec3 norm_interp = mix(norm_curr, norm_next, blend);
	vec3 norm_rescaled = 2.0 * norm_interp - 1.0;
	vec3 norm_b2g = vec3(norm_rescaled.x, norm_rescaled.z, -norm_rescaled.y);

	%s = normalize(norm_b2g);
	""" % [output_vars[0], output_vars[1]]
