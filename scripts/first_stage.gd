extends Node2D

@onready var scene_transition = $SceneTransition/AnimationPlayer
var current_wave: int 
@export var eye_scene: PackedScene

var starting_nodes: int
var current_nodes: int
var wave_spawn_ended: bool
func _ready():
	scene_transition.get_parent().get_node("ColorRect").color.a = 255
	scene_transition.play("fade_out")
	current_wave = 0 
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()
	
func position_to_next_wave():
	if current_nodes == starting_nodes:
		if current_wave != 0:
			Global.moving_next_wave = true
		wave_spawn_ended = false
		scene_transition.play("change_wave")
		current_wave += 1
		Global.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepare_spawn("eyes", 5.0, 5.0) #type, multiplier, mob_spawns
		print(current_wave)


func prepare_spawn(type, multiplier, mob_spawns):
	var mob_amount = float(current_wave) * multiplier
	var mob_wait_time: float = 2.0
	print (mob_amount)
	var mob_spawn_rounds = mob_amount / mob_spawns
	spawn_type(type, mob_spawn_rounds, mob_wait_time) 
	
func spawn_type(type, mob_spawn_rounds, mob_wait_time):
	if type == "eyes":
		var eye_spawn1 = $EyeSpawnPoint
		var eye_spawn2 = $EyeSpawnPoint2
		var eye_spawn3 = $EyeSpawnPoint3

		if mob_spawn_rounds  >= 1:
			for i in mob_spawn_rounds:
				var eye1 = eye_scene.instantiate()
				eye1.global_position = eye_spawn1.global_position
				var eye2 = eye_scene.instantiate()
				eye2.global_position = eye_spawn2.global_position
				var eye3 = eye_scene.instantiate()
				eye3.global_position = eye_spawn3.global_position
				add_child(eye1)
				add_child(eye2)
				add_child(eye3)

				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
		wave_spawn_ended = true
		
func _process(delta):
	if !Global.playerAlive:
		Global.gameStarted = false
		scene_transition.play("fade_in")
		update_score()
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	current_nodes = get_child_count()
	
	if wave_spawn_ended:
		position_to_next_wave()
		
func update_score():
	Global.prev_score = Global.current_score
	if Global.current_score > Global.high_score:
		Global.high_score = Global.current_score
	Global.current_score = 0
