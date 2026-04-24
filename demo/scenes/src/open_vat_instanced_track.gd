class_name OpenVATInstancedTrackChangeDemo
extends OpenVATInstancedDemo

@onready var track_select: OptionButton = $UI/MarginContainer/VBox/HBoxTrack/TrackSelect

func _ready() -> void:
	super._ready()
	for track in vat_multi_mesh_instance_3d.animation_tracks:
		track_select.add_item(track.name)

func _on_track_select_item_selected(index: int) -> void:
	vat_multi_mesh_instance_3d.update_all_instances(0,index,1)
