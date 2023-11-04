extends Node
class_name PointSpawner

var point16 = preload("res://point.tscn")
var point8 = preload("res://small_point.tscn")
var scene : Control = null

func _init(_scene):
	self.scene = _scene

func make_point16_nolabel(pos: Vector2) -> Point2D:
	return make_point16(pos, "")

func add_point16_nolabel(pos: Vector2) -> Point2D:
	var x = make_point16_nolabel(pos)
	scene.add_child(x)
	return x
	
func make_point16(pos: Vector2, label: String) -> Point2D:
	var p: Point2D = point16.instantiate()
	p.real_pos = pos
	p.set_label(label)
	return p
	
func add_point16(pos: Vector2, label: String) -> Point2D:
	var point = make_point16(pos, label)
	scene.add_child(point)
	return point

func make_point8_nolabel(pos: Vector2) -> Point2D:
	return make_point8(pos, "")

func add_point8_nolabel(pos: Vector2) -> Point2D:
	var x = make_point8_nolabel(pos)
	scene.add_child(x)
	return x
	
func make_point8(pos: Vector2, label: String) -> Point2D:
	var p: SmallPoint2D = point8.instantiate()
	p.circle_size = 8
	p.real_pos = pos
	p.set_label(label)
	return p
	
func add_point8(pos: Vector2, label: String) -> Point2D:
	var point = make_point8(pos, label)
	scene.add_child(point)
	return point
