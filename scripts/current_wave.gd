extends RichTextLabel




var default_text = "CURRENT WAVE: "
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var text = str(default_text, str(Global.current_wave))
	self.text = (text)
	
