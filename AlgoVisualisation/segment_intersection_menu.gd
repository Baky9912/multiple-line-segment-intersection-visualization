extends Node2D


func _ready():
	$ColorRect/LinesCountTbx.text = str(Global.random_line_count)
	$ColorRect/MeanLineLenTbx.text = str(Global.line_mean_length)
	$ColorRect/RngSeedTbx.text = str(Global.rng_seed)
