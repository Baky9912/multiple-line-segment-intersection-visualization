extends TextureButton

func _on_pressed():
	Global.speed = max(Global.speed-10, 10)
