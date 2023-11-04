extends TextureButton

func _on_toggled(button_pressed):
	Global.pause_on_event = button_pressed
	if not Global.pause_on_event:
		Global.play = true
