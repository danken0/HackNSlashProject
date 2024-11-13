extends RichTextLabel




var default_text = "PREVIOUS SCORE: "
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var text = str(default_text, str(Global.prev_score))
	self.text = (text)
	
