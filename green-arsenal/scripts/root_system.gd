@tool
extends Node3D

var branches = []
@export var rebuild = false
@export var auto_rebuild = false
@export var sides = 16
#@export var radius = 0.5

var vertices: PackedVector3Array = []
var normals: PackedVector3Array = []
var indices: PackedInt32Array = []

func _process(delta: float) -> void:
	if rebuild:
		rebuild = false
		vertices.clear()
		normals.clear()
		indices.clear()
		branches.clear()
		setup()
	else:
		if Engine.is_editor_hint() and auto_rebuild:
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			rebuild = true
		pass

func setup():
	for c in get_children():
		if c is RootPoint:
			walk(c, [])
	
	for b in branches:
		generate_tube(b)
	build_mesh()
	if !Engine.is_editor_hint():
		generate_collision()

func _ready() -> void:
	setup()

func walk(point: RootPoint, path: Array):
	
	path = path.duplicate()
	path.append(point)
	
	var next: Array[RootPoint] = []
	
	for c in point.get_children():
		if c is RootPoint:
			next.append(c)
	
	if next.size() < 1:
		branches.append(path)
		return
	
	for c in next:
		walk(c, path)

func generate_tube(branch: Array):
	var curve = Curve3D.new()
	var radii = []
	for p in branch:
		curve.add_point(to_local(p.global_position))
		radii.append(p.radius)
	curve.bake_interval = 0.5
	var points = curve.get_baked_points()
	
	if points.size() < 2:
		return
	var start_index = vertices.size()
	for i in points.size():
		var point = points[i]
		
		var forward: Vector3
		if i == points.size() - 1:
			forward = (points[i] - points[i-1]).normalized()
		else:
			forward = (points[i+1] - points[i]).normalized()
		
		var up = Vector3.UP
		
		if abs(forward.dot(up)) > 0.99:
			up = Vector3.RIGHT
		var right = forward.cross(up).normalized()
		up = right.cross(forward).normalized()
		
		for j in sides:
			var angle = TAU * float(j) / sides
			var direction = (
				right * cos(angle) +
				up * sin(angle)
			)
			var local_radius = lerp(radii[0], radii[radii.size()-1],float(i) / float(points.size()-1))
			vertices.append(
				point + direction * local_radius
			)
			normals.append(direction)
	
	for i in range(points.size() - 1):
		for j in sides:
			var current = start_index + i * sides + j
			var next = start_index + i * sides + ((j + 1) % sides)
			var next_ring = start_index + (i + 1) * sides + j
			var next_ring_next = start_index + (i + 1) * sides + ((j + 1) % sides)
			
			indices.append(current)
			indices.append(next)
			indices.append(next_ring)
			
			indices.append(next)
			indices.append(next_ring_next)
			indices.append(next_ring)

func build_mesh():
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays
	)
	
	$MeshInstance3D.mesh = mesh

func generate_collision():
	var shape = ConcavePolygonShape3D.new()
	var faces = PackedVector3Array()
	
	for i in range(0, indices.size(), 3):
		var a = vertices[indices[i]]
		var b = vertices[indices[i + 1]]
		var c = vertices[indices[i + 2]]
		faces.append(a)
		faces.append(b)
		faces.append(c)
	shape.set_faces(faces)
	$StaticBody3D_L1/CollisionShape3D.shape = shape

	$StaticBody3D_L2/CollisionShape3D.shape = $MeshInstance3D.mesh.create_convex_shape()
	
