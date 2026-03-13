extends Area2D 

@export var weapon_name: String = "Sword"
@export var damage: int = 10

# 1. Create a flag to track the weapon's state
var has_been_picked_up: bool = false

func _on_body_entered(body: Node2D): 
	# 2. Add the flag check to your condition
	if not has_been_picked_up and body.is_in_group("player"):
		if body.has_method("pick_up_weapon"):
			
			# 3. Immediately lock it down so it can't be picked up again!
			has_been_picked_up = true 
			
			# 4. Do the deferred call
			body.call_deferred("pick_up_weapon", weapon_name, damage, self)
			
			# (Optional) If the sword should disappear from the ground:
			# queue_free()
