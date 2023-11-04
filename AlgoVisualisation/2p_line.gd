extends Line2D
class_name TwoPLine

@export var s: Point2D = null
@export var t: Point2D = null
var line_eq: LineEquation = LineEquation.new()

func _init():
	width = 1
	self.default_color = Color.BLACK

func _to_string():
	return "{Line(" + s.get_label() + ","+ t.get_label() + ")}"
	#return "[ points: " + s.get_label() + ", " + t.get_label() + " | " + str(line_eq) + " ]"

func line_intersection_point(o: TwoPLine):
	var p = line_eq.intersects_line(o.line_eq)
	if p is bool:
		return false
	var x11 = min(s.real_pos.x, t.real_pos.x)
	var x12 = max(s.real_pos.x, t.real_pos.x)
	var x21 = min(o.s.real_pos.x, o.t.real_pos.x)
	var x22 = max(o.s.real_pos.x, o.t.real_pos.x)
	if x11 <= p.x and p.x <= x12 and x21 <= p.x and p.x <= x22:
		return p
	else:
		return false 

func update_line_eq():
	line_eq.calculate_from_line(self)

func attach_to_points(p1: Point2D, p2: Point2D):
	s = p1
	t = p2
	update_line_eq()
	
func update_line():
	points = PackedVector2Array([s.real_pos, t.real_pos])
	update_line_eq()

func _ready():
	update_line()

func init_siblings():
	add_sibling(s)
	add_sibling(t)

func _process(_delta):
	if(points.size() != 2 or s.real_pos != points[0] or t.real_pos != points[1]):
		update_line()


