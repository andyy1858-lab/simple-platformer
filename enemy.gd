extends CharacterBody2D

# --- CONSTANTS ---
const SPEED: float = 30.0

# --- NODES ---
# It's good practice to grab all your nodes at the top using @onready
@onready var e_hurt: AudioStreamPlayer2D = $e_hurt
@onready var timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- STATS ---
var max_health: int = 40 
var current_health: int = max_health

# --- STATE ---
var player: Node2D = null
var chase: bool = false


# --- BUILT-IN FUNCTIONS ---
func _ready() -> void:
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float) -> void:
	# Add gravity so the enemy stays on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle chasing logic
	if chase and player:
		# Calculate the direction from Enemy to Player
		var direction = (player.position - position).normalized()
		
		# Move toward the player horizontally
		velocity.x = direction.x * SPEED
		
		# Flip sprite to face player
		animated_sprite.flip_h = direction.x < 0
	else:
		# Stop moving if not chasing
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


# --- CUSTOM FUNCTIONS ---
func take_damage(amount: int) -> void:
	current_health -= amount
	print("Enemy hit for ", amount, "! Health remaining: ", current_health)
	
	# Add a slight pitch variation, then play the sound!
	e_hurt.pitch_scale = randf_range(0.8, 1.2)
	e_hurt.play()	
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy defeated!")
	# You can add a death animation or sound here later!
	queue_free() # This deletes the enemy from the game entirely


# --- SIGNAL CALLBACKS ---
func _on_timer_timeout() -> void:
	if player:
		chase = true

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		timer.start(0.1)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false
		player = null
		timer.stop()
