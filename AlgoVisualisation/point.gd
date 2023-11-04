extends TextureRect
class_name Point2D

func _init():
	self.texture = preload("res://assets/whitecircle16x16png.png")
	self.self_modulate = Color.BLACK
	
var circle_size: int = 16
var real_pos : Vector2:
	set(val):
		@warning_ignore("integer_division")
		position = val - circle_size/2 * Vector2.ONE
	get:
		@warning_ignore("integer_division")
		return position + circle_size/2 * Vector2.ONE

func set_label(text):
	get_node("Label").text = text

func get_label():
	return get_node("Label").text
