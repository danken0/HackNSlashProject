extends CharacterBody2D

class_name Player

const speed = 200.0
const jump_power = -350.0
@onready var animation = $AnimatedSprite2D
var attack_type: String
var current_attack: bool
@onready var dealdamage = $DealDamage

var health = 100
var health_max = 100
var health_min = 0
var can_take_damage: bool
var dead := false

func _ready():
	Global.playerBody = self
	current_attack = false
	Global.playerAlive = true
	can_take_damage = true
func _physics_process(delta: float) -> void:
	Global.playerDamageZone = dealdamage
	Global.playerHitbox = $PlayerHitBox
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if !dead:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_power

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

		if is_on_floor() and !current_attack:
			if Input.is_action_just_pressed("left_mouse"):
				animation.play("attack")
				current_attack = true
				attack_type = "single"
				toggle_collisions()
			elif Input.is_action_just_pressed("right_mouse"):
				current_attack = true
				animation.play("double_attack")
				attack_type = "double"
				toggle_collisions()
			setdamage(attack_type)
			#elif Input.is_action_just_pressed("left_mouse") and !is_on_floor():
				#current_attack = true
				#animation.play("air_attack")
		handle_movement_animation(direction)
		check_hitbox()
	move_and_slide()

func check_hitbox():
	var hitbox_areas = $PlayerHitBox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is EyeEnemy:
			damage = Global.EyeDamageAmount
			
	if can_take_damage:
		take_damage(damage)
		
		
func take_damage(damage):
	if damage != 0:
		if health > 0:
			health -= damage
			animation.play('hurt')
			print("player health:" , health)
			if health <= 0:
				health = 0
				dead = true
				handle_death_animation()
			take_damage_cooldown(1.0)
			
			
func handle_death_animation():
	#$CollisionShape2D.position.y = 5
	animation.play("death")
	velocity.x = 0
	await get_tree().create_timer(0.5).timeout
	$Camera2D.zoom.x = 3
	$Camera2D.zoom.y = 3
	await get_tree().create_timer(4.5).timeout
	Global.playerAlive = false
	self.queue_free()
	
	
func take_damage_cooldown(wait_time):
	can_take_damage = false
	await get_tree().create_timer(wait_time).timeout
	can_take_damage = true
	
func handle_movement_animation(dir):
	if is_on_floor() and !current_attack and !dead:
		if !velocity:
			animation.play("idle")
		if velocity:
			animation.play("run")
			toggle_flip_sprite(dir)
	elif !is_on_floor() and !current_attack and !dead:
		animation.play("fall")
		
		
func toggle_flip_sprite(dir):
	if dir == 1:
		animation.flip_h = false
		dealdamage.scale.x = 1
	if dir == -1:
		animation.flip_h = true
		dealdamage.scale.x = -1
		
func toggle_collisions():
	var damage_zone = dealdamage.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "single":
		wait_time = 0.75
	elif attack_type =="double":
		wait_time = 1.0
	damage_zone.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone.disabled = true
	
func _on_animated_sprite_2d_animation_finished():
	current_attack = false

func setdamage(attack_type):
	var damage_to_deal : int
	if attack_type == "single":
		damage_to_deal = 8
	elif attack_type == "double":
		damage_to_deal = 16
	Global.playerDamageAmount = damage_to_deal
