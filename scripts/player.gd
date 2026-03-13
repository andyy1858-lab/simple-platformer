extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0
const ACCELERATION = 3000.0
const FRICTION = 1000.0

# --- Weapon & Combat ---
var current_weapon: String = "None"
var attack_damage: int = 0
var has_weapon: bool = false
var is_attacking: bool = false 

# FIXED: We need to update our paths since we moved them inside the Pivot!
@onready var pivot = $Pivot
@onready var animation_sprite = $Pivot/AnimatedSprite2D
@onready var weapon_attachment = $Pivot/WeaponAttachment
@onready var jump_sound = $JumpSound
@onready var anim = $AnimationPlayer
@onready var sword_att: Sprite2D = $Pivot/sword_att
@onready var sword_woosh: AudioStreamPlayer2D = $SwordWoosh


func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)
	sword_att.visible = false # <--- Make sure it starts hidden

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Check Attack State
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		move_and_slide()
		return 

# 3. Handle Attack Input
	if Input.is_action_just_pressed("attack") and has_weapon and is_on_floor():
		is_attacking = true
		weapon_attachment.visible = false # <--- HIDE carried sword
		sword_att.visible = true          # <--- SHOW attacking sprite
		anim.play("attack_sword")
		return

	# 4. Handle Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# 5. Handle Movement & Ground Animations
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		
		# THE FIX: Flip the entire Pivot (Sprite AND Marker mirror together!)
		if direction < 0:
			pivot.scale.x = -1
		else:
			pivot.scale.x = 1
			
		if is_on_floor():
			anim.play("walk") 
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		if is_on_floor():
			anim.play("idle") 

	# 6. Apply Movement
	move_and_slide()


# --- Custom Functions ---

func _on_anim_finished(anim_name: String) -> void:
	if anim_name == "attack_sword":
		is_attacking = false
		weapon_attachment.visible = true  # <--- BRING BACK carried sword
		sword_att.visible = false         # <--- HIDE attacking sprite

func pick_up_weapon(weapon_name: String, damage: int, sword_node: Node2D):
	current_weapon = weapon_name
	attack_damage = damage
	has_weapon = true
	
	var parent = sword_node.get_parent()
	if parent:
		parent.remove_child(sword_node)
	
	weapon_attachment.add_child(sword_node)
	sword_node.position = Vector2.ZERO 
	sword_node.rotation = 0
	
	for child in sword_node.get_children():
		if child is AnimatedSprite2D or child is AnimationPlayer:
			child.stop()
	
	print("Player picked up: ", weapon_name, " with ", damage, " damage!")
	
	#SWORD HITBOX
	# Triggered when the sword's Area2D touches something
func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if the thing we hit has the take_damage function (like our enemy does!)
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
