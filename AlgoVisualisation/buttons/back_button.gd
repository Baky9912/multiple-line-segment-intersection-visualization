extends TextureButton

func _on_pressed():
	get_tree().change_scene_to_file("res://segment_intersection_menu.tscn")
