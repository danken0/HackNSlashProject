extends Node2D

@onready var scene_transition = $SceneTransition/AnimationPlayer

func _ready():
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	scene_transition.play("fade_out")

func _process(delta):
	if !Global.playerAlive:
		Global.gameStarted = false
		scene_transition.play("fade_in")
		get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_scene_change_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.gameStarted = true
		scene_transition.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/first_stage.tscn")
