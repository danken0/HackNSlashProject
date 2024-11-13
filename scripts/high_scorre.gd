extends RichTextLabel




var default_text = "HIGH SCORE: "
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var text = str(default_text, str(Global.high_score))
	self.text = (text)
	
