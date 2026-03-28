extends OpenVATInstanceDemo

var timer: float
var isFadeOut: bool = true
var x: float = -30
var z: float = 0

func _process(delta: float) -> void:
	timer += delta
	
	if isFadeOut: # fade out
		for instance in vat_multi_mesh_instance_3d.multimesh.instance_count:
			if timer > instance: # start fading one instance every second
				if (1 - (timer-instance)) > 0.0: # fade out
					vat_multi_mesh_instance_3d.update_instance_alpha(instance, (1 - (timer-instance)))
				else: # already faded out
					vat_multi_mesh_instance_3d.update_instance_alpha(instance, 0.0)
	else: # fade In
		for instance in vat_multi_mesh_instance_3d.multimesh.instance_count:
			if timer > instance: # start fading in instance every second
				if (1 - (timer-instance)) <= 1.0: # fade in
					vat_multi_mesh_instance_3d.update_instance_alpha(instance, (timer-instance))
				else: # already faded in
					vat_multi_mesh_instance_3d.update_instance_alpha(instance, 1.0)
	
	# reset after all have faded out
	if timer > vat_multi_mesh_instance_3d.multimesh.instance_count + 1:
		x = -30
		z = 0
		timer = 0
		isFadeOut = !isFadeOut

func setupInstances():
	var a: int = 0 # animation track number
	for instance in vat_multi_mesh_instance_3d.multimesh.instance_count:
		# randomize the animation offset
		vat_multi_mesh_instance_3d.update_instance_animation_offset(instance, randf())
		# sets the animation track number
		vat_multi_mesh_instance_3d.update_instance_track(instance, a)
		# set alpha to 1.0 -> you can fade out a specific instance by setting alpha to 0
		vat_multi_mesh_instance_3d.update_instance_alpha(instance, 1.0)
		# randomize scale, rotation, and location
		randomizeInstance(instance)
		
		# this cycles threw each animation track number
		a += 1
		if a > vat_multi_mesh_instance_3d.number_of_animation_tracks - 1:
			a = 0
			
func randomizeInstance(i: int):
	node3D.scale = Vector3(randf_range(base_scale, max_scale), randf_range(base_scale, max_scale), randf_range(base_scale, max_scale))

	
	location.x = x
	location.z = z
	location.y = 0
	
	x += 10
	if x > 30:
		x = -30
		z += 10
	
	node3D.rotation.x = 0
	node3D.rotation.z = 0
	node3D.rotate_y(randf_range(0, TAU))
	node3D.position = location
	vat_multi_mesh_instance_3d.multimesh.set_instance_transform(i, node3D.transform)			
