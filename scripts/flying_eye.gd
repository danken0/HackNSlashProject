extends CharacterBody2D

class_name EyeEnemy

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var eye_deal_damage: Area2D = $EyeDealDamage


var health = 20
var health_max = 20
var health_min = 0
var dead := false
var taking_damage := false
var is_roaming: bool
var damage_to_deal = 15
const speed = 60.0
var dir: Vector2
var player: CharacterBody2D
var is_chasing:= false
var points_for_kill = 100
var is_dealing_damage:= false

func _ready():
	player = Global.playerBody
	is_chasing = false

func _process(delta):
	Global.EyeDamageAmount = damage_to_deal
	Global.EyeDamageZone = $EyeDealDamage
	
	if Global.playerAlive:
		is_chasing = true
	elif !Global.playerAlive:
		is_chasing = false
	
	
	if is_on_floor() and dead:
		Global.current_score += points_for_kill
		#await get_tree().create_timer(3.0).timeout
		self.queue_free()
		
	move(delta)
	handle_animation()
	
func move(delta):
	player = Global.playerBody
	if !dead:
		is_roaming = true
		if !taking_damage and is_chasing and Global.playerAlive:
			velocity = position.direction_to(player.position) * speed
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knocback_dir = position.direction_to(player.position) * - 40
			velocity = knocback_dir
		else:
			velocity += dir * speed * delta
	elif dead:
		velocity.y += 10 * delta
		velocity.x = 0 
	move_and_slide()

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
		
func choose(array):
	array.shuffle()
	return array.front()
	
func handle_animation():

	if !dead and !taking_damage:
		if dir.x == -1:
			animation.play("fly")
			animation.flip_h = true
		elif dir.x == 1:
			animation.play("fly")
			animation.flip_h = false
	elif !dead and taking_damage:
		animation.play("hurt")
		await get_tree().create_timer(0.6).timeout
		taking_damage = false
	elif dead and is_roaming:
		animation.play("death")
		is_roaming = false
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, false)
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)
	#elif !dead and is_dealing_damage:
		#animation.play("attack")


func _on_eye_hitbox_area_entered(area: Area2D) -> void:
	if area == Global.playerDamageZone:
		var damage = Global.playerDamageAmount
		take_damage(damage)
		
func take_damage(damage):
	health -= damage
	print(str(self), "current health is", health)
	taking_damage = true
	if health <= 0:
		health = 0
		dead = true


#func _on_eye_deal_damage_area_entered(area: Area2D) -> void:
	#if area == Global.playerHitbox:
		#is_dealing_damage = true
		#await get_tree().create_timer(1.0).timeout
		#is_dealing_damage = false
