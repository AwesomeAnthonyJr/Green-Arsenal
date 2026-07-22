@tool
extends Node3D

@export var roots: Array[RootSystem] = []
@export var finalize_build = false

func _process(delta: float) -> void:
	if finalize_build:
		finalize_build = false
		for r in roots:
			r.frozen = true
			
			r.vertices.clear()
			r.normals.clear()
			r.indices.clear()
			r.branches.clear()
			r.uvs.clear()
			r.setup()
