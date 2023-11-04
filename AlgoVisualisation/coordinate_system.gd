extends Line2D

@export var step = 50
@export var ruler_length = 7
func _ready():
	var bottom_left = points[1] 
	var rect: Vector2i = get_parent().size
	print("RECT SIZE ", rect)
	for y in range(bottom_left.y, points[0].y, -step):
		var points_arr = PackedVector2Array([Vector2(bottom_left.x - ruler_length, y),
		Vector2(bottom_left.x + ruler_length, y)])
		var line = Line2D.new()
		line.width = self.width
		line.self_modulate = Color.BLACK
		line.points = points_arr
		add_child(line)
	for x in range(bottom_left.x, points[2].x, step):
		var points_arr = PackedVector2Array([Vector2(x, bottom_left.y - ruler_length),
		Vector2(x, bottom_left.y + ruler_length)])
		var line = Line2D.new()
		line.width = self.width
		line.self_modulate = Color.BLACK
		line.points = points_arr
		add_child(line)

