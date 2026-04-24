class_name CFOEFileSet

var source: String
var dest: String
var features: PackedStringArray


static func create(new_source: String, new_dest: String, new_features: PackedStringArray) -> CFOEFileSet:
	var instance: CFOEFileSet = CFOEFileSet.new()
	instance.source = new_source
	instance.dest = new_dest
	instance.features = new_features
	return instance
