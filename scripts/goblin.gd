extends CharacterBody2D

class_name GoblinEnemy 

const speed = 15
var is_chasing:= false
var health = 100
var health_max = 100
var health_min = 0

var dead := false
var taking_damage := false
var damage_to_deal = 20
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 900
var knockback_force = -20
var is_roaming := false 

var player: CharacterBody2D
var player_in_area:= false

func _process(delta):
	Global.goblinDamageAmount = damage_to_deal
	Global.goblinDamageZone	= $DealDamage
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	player = Global.playerBody
	move(delta)
	handle_animation()
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_chasing:
			velocity += dir * speed * delta
		elif is_chasing and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knocback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knocback_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation():
	var animation = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		animation.play ("walk")
		if dir.x == -1:
			animation.flip_h = true
		elif dir.x == 1:
			animation.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		animation.play("hurt")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		animation.play("death")
		await get_tree().create_timer(0.8).timeout
		handle_death()
		
func handle_death():
	self.queue_free()
			
			
func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([1.5,2.0,2.5])
	if !is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
	
func choose(array):
	array.shuffle()
	return array.front()


func _on_hit_box_area_entered(area: Area2D) -> void:
	var damage = Global.playerDamageAmount 
	if area == Global.playerDamageZone:
		take_damage(damage)
		
		
func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
