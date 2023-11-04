extends Node
class_name LineSpawner

var line = preload("res://2p_line.tscn")
var static_line = preload("res://static_2p_line.tscn")
var scene : Control = null
var point_spawner: PointSpawner = null

func _init(_scene):
	self.scene = _scene
	self.point_spawner = PointSpawner.new(scene)

func from_vectors(pos1: Vector2, pos2: Vector2, is_static=false) -> TwoPLine:
	return from_labeled_vectors(pos1, "", pos2, "", is_static)

func add_from_vectors(pos1: Vector2, pos2: Vector2, is_static=false, add_points_to_tree=true) -> TwoPLine:
	var x = from_vectors(pos1, pos2, is_static)
	scene.add_child(x)
	if add_points_to_tree:
		scene.add_child(x.s)
		scene.add_child(x.t)
	return x

func from_labeled_vectors(pos1: Vector2, s1: String, pos2: Vector2, s2: String, is_static=false) -> TwoPLine:
	var p1 = point_spawner.make_point8(pos1, s1)
	var p2 = point_spawner.make_point8(pos2, s2)
	return self.from_points(p1, p2, is_static)

func add_from_labeled_vectors(pos1: Vector2, s1: String, pos2: Vector2, s2: String, is_static=false, add_points_to_tree=true) -> TwoPLine:
	var x = from_labeled_vectors(pos1, s1, pos2, s2, is_static)
	if add_points_to_tree:
		scene.add_child(x.s)
		scene.add_child(x.t)
	scene.add_child(x)
	return x
	
func from_points(p1: Point2D, p2: Point2D, is_static=false) -> TwoPLine:
	var new_line = StaticTwoPLine.new() if is_static else TwoPLine.new() 
	new_line.attach_to_points(p1, p2)
	return new_line

func add_from_points(p1: Point2D, p2: Point2D, is_static=false, add_points_to_tree=true) -> TwoPLine:
	var x = from_points(p1,p2,is_static)
	if add_points_to_tree:
		scene.add_child(p1)
		scene.add_child(p2)
	scene.add_child(x)
	return x

func in_margins(pos: Vector2, inner_margin: Vector2, outter_margin: Vector2):
	return (pos.x > inner_margin.x and pos.y > inner_margin.y and pos.x < outter_margin.x and pos.y < outter_margin.y)

func draw_random_lines(n: int, rngseed: int, mean_length: float, static_lines=false):
	var rng = RandomNumberGenerator.new()
	rng.seed = rngseed
	# rng.state = 1 # starting here
	var inner_margin = 32*1.5*Vector2.ONE
	var _tmp: Vector2 = scene.size
	var outter_margin = _tmp - inner_margin
	# TODO add coordinate system size to inner margin
	var made = Array()
	var i=0
	while len(made) < n:
		i+=1
		if i>5*n:
			break # error
		var pos1x = rng.randf_range(inner_margin.x + 1, outter_margin.x-1)
		var pos1y = rng.randf_range(inner_margin.y + 1, outter_margin.y-1)
		var pos1 = Vector2(pos1x, pos1y)
		var length_mult = rng.randfn(1, 0.5)
		length_mult = max(length_mult, 0.08)
		var angle = rng.randf()*PI*2
		var direction = Vector2.from_angle(angle)
		var pos2 = pos1 + length_mult * mean_length * direction
		if(not in_margins(pos1, inner_margin, outter_margin) or
		not in_margins(pos2, inner_margin, outter_margin)):
			print("not painting the line")
			continue
		var no1 = len(made)*2+1
		var no2 = no1+1 
		var new_line = add_from_labeled_vectors(pos1, str(no1), pos2,
		 str(no2), static_lines)
		made.append(new_line)
	return made
