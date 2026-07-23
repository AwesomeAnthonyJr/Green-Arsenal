@tool
extends Node3D
class_name RootSystem

var branches = []
@export var rebuild = false
@export var auto_rebuild = false
@export var sides = 16
@export var build_collision = false
var dont_collision = false
#@export var radius = 0.5

var frozen = false

var vertices: PackedVector3Array = []
var normals: PackedVector3Array = []
var indices: PackedInt32Array = []
var uvs: PackedVector2Array = []

signal roots_gone

func _process(delta: float) -> void:
	if rebuild:
		rebuild = false
		vertices.clear()
		normals.clear()
		indices.clear()
		branches.clear()
		uvs.clear()
		setup()
	else:
		if Engine.is_editor_hint() and auto_rebuild:
			#this is dumb but it works LMAO
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

func delayed_setup():
	await get_tree().process_frame
	vertices.clear()
	normals.clear()
	indices.clear()
	branches.clear()
	uvs.clear()
	setup()

func setup():
	for c in get_children():
		if c is RootPoint:
			walk(c, [])
	
	for b in branches:
		generate_tube(b)
	build_mesh()
	if !dont_collision:
		if !Engine.is_editor_hint() or frozen or build_collision:
			generate_collision()
	if branches.size() <= 0:
		roots_gone.emit()

func _ready() -> void:
	if !frozen:
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

###commented for kai
func generate_tube(branch: Array):
	var curve = Curve3D.new()
	var radii = []
	for p in branch:
		if is_instance_valid(p):
			curve.add_point(to_local(p.global_position))
			radii.append(p.radius)
	#adding this extra one for some later radii shenaniganry; basically assumes roots end in a point
	radii.append(0.01)
	#could probably have been an @export variable but like who cares
	curve.bake_interval = 0.5
	var points = curve.get_baked_points()
	#this "start index" is for later
	var start_index = vertices.size()
	#if we initialize this to zero it can just crash the engine over and over so lets not do that please
	var accumulated_length = 0.00000001
	#iterates over all the points
	for i in points.size():
		var point = points[i]
		
		if i > 0:
			accumulated_length += points[i].distance_to(points[i-1])
		
		#this bit calculates the "local forward" of the point
		var forward: Vector3
		if i == points.size() - 1:
			forward = (points[i] - points[i-1]).normalized()
		else:
			forward = (points[i+1] - points[i]).normalized()
		
		#this bit calculates up, you get some weird artifacts without this check so google says to do it i guess
		var up = Vector3.UP
		if abs(forward.dot(up)) > 0.5:
			up = Vector3.RIGHT
		#3d math stuff
		var right = forward.cross(up).normalized()
		up = right.cross(forward).normalized()
		
		#iterate over sides to generate the actual points of the mesh
		for j in sides:
			#uses math to make a circle basically
			var angle = TAU * float(j) / sides
			var direction = (right * cos(angle) + up * sin(angle))
			#basically a fancy way to interpolate between set radii
			
			var temp_ind = (float(i) / float(points.size()-1)) * float(radii.size()-2)
			var temp_perc = temp_ind
			temp_ind = int(temp_ind)
			temp_perc -= temp_ind
			var local_radius = 0.01
			if radii.size() > 2:
				local_radius = lerp(radii[temp_ind], radii[temp_ind + 1], temp_perc)
			#adds a point offset by the circle direction and radius
			vertices.append(point + direction * local_radius)
			normals.append(direction)
			#this part is for uvs to have textures!
			uvs.append(Vector2(float(j) / sides, accumulated_length))
	
	#this part just basically labels the points for the arraymesh to use
	for i in range(points.size() - 1):
		for j in sides:
			var current = start_index + i * sides + j
			var next = start_index + i * sides + ((j + 1) % sides)
			var next_ring = start_index + (i + 1) * sides + j
			var next_ring_next = start_index + (i + 1) * sides + ((j + 1) % sides)
			#if you change this order it can flip it inside out i discovered!
			indices.append(current)
			indices.append(next)
			indices.append(next_ring)
			
			indices.append(next)
			indices.append(next_ring_next)
			indices.append(next_ring)

func build_mesh():
	var mesh := ArrayMesh.new()
	if vertices.size() <= 0:
		$MeshInstance3D.mesh = mesh
		return
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
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
	
