class_name OpenVATAnimationTrack
extends RefCounted

var name: String
var startFrame: int
var endFrame: int
var framerate: int
var isLooping: bool

func set_track(n: String, s: int, e: int, f: int, loop: bool):
	name = n
	startFrame = s
	endFrame = e
	framerate = f
	isLooping = loop
	
	
