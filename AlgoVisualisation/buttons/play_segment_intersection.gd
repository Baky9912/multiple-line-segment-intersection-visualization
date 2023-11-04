extends Button


func _on_pressed():
	# TODO change values
	var line_count_text: String = get_node("../LinesCountTbx").text
	var mean_line_text: String = get_node("../MeanLineLenTbx").text
	var rng_seed_text: String = get_node("../RngSeedTbx").text
	var line_count = int(line_count_text)
	var mean_line = float(mean_line_text)
	var rng_seed: int
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(rng_seed_text)
	if result and len(result.get_string())==len(rng_seed_text):
		rng_seed = int(result.get_string())
	else:
		rng_seed = hash(rng_seed_text)
	
	var err_lbl = get_node("../ErrorLabel")
	if mean_line < 10:
		err_lbl.text = "mean_line < 10"
		return
	if line_count < 2:
		err_lbl.text = "line_count < 2"
		return
	
	Global.line_mean_length = mean_line
	Global.rng_seed = rng_seed
	Global.random_line_count = line_count
	get_tree().change_scene_to_file("res://segment_intersection.tscn")
