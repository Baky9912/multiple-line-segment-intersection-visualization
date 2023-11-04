extends Node
class_name LineEquation

var vertical: bool
var k: float
var n: float

# vertical x=n
# else y=kx+n

func _init():
	pass
	
func signchar(x: float):
	return "+" if x>=0 else "-"

func _to_string():
	# first quadrant (0,0)->(+,+) equation line
	return "y = " + str("%.2f" % k) + "x " + signchar(n) + " " + str("%.1f" % (abs(n)))

func set_parameters(_vertical: bool, _k:float, _n:float):
	self.vertical = _vertical
	self.k = _k
	self.n = _n

func solve_y(x: float):
	return k*x+n 

func solve_x(y: float):
	return (y-n)/k

func calculate_from_vectors(a: Vector2, b: Vector2):
	# ab
	if a==b:
		push_error("can't pass 2 same points to calculate_from_vector")
	if a.x==b.x:
		vertical = true
		k = INF
		n = a.x
	else:
		vertical = false
		var dx = b.x-a.x
		var dy = b.y-a.y
		k = dy/dx
		# y = kx+n
		# n = y - kx
		n = a.y-k*a.x
		
func calculate_from_line(l: Line2D):
	return calculate_from_vectors(l.s.real_pos, l.t.real_pos)

func get_angle():
	return atan(k)

func intersects_vertical(v: LineEquation):
	# from non-vertical
	return Vector2(v.n, k*v.n+n)
	
func intersects_line(o: LineEquation):
	if vertical and o.vertical:
		return n==o.n
	if vertical and not o.vertical:
		pass
	if not vertical and o.vertical:
		pass
	# y1 = y2 = y
	# x1 = x2 = x
	# k1*x+n1 = k2*x+n2
	# k1*x-k2*x = n2-n1
	# x = (n2-n1)/(k1-k2)
	# y = k1*x+n1
	if k==o.k:
		if n==o.n: return true # same line
		else: return false # parallel
	var xi = (o.n-n)/(k-o.k)
	var yi = k*xi+n
	return Vector2(xi, yi)

#func intersects_line_in_segment(o: LineEquation, x1: float, x2: float):
#	# works for non vertical
#	var p = intersects_line(o)
#	if p is bool and p==true: return true
#	if p is bool and p==false: return false
#	if x1 <= p.x and p.x <= x2:
#		return p

#func intersects_line_between_points(o: LineEquation, p1: Vector2, p2: Vector2):
#	var x1 = min(p1.x, p2.x)
#	var x2 = max(p1.x, p2.x)
#	return intersects_line_in_segment(o, x1, x2)
