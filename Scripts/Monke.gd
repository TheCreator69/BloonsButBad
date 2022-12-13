extends Node2D

var Fart = preload("res://Scenes/FartProjectile.tscn")

var fartCooldown = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	fartCooldown -= delta
	
	if(fartCooldown <= 0.0):
		var overlappingAreas = get_node("BloonTrigger").get_overlapping_areas()
		if(!overlappingAreas.empty()):
			fart(overlappingAreas[0])

func _on_BloonTrigger_area_entered(area: Area2D) -> void:
	if(fartCooldown > 0.0):
		return
	
	fart(area)

func fart(area: Area2D) -> void:
	var angle = self.global_position.angle_to_point(area.global_position)
	
	var newFart = Fart.instance()
	call_deferred("add_child", newFart)
	newFart.movementDirection = Vector2(cos(angle) * -1, sin(angle) * -1) * newFart.movementSpeedMultiplier
	
	var facingAngle = angle + (3.1415/2)
	get_node("Monke").rotation = facingAngle
	newFart.rotation = facingAngle
	
	fartCooldown = 0.5
	
	var fartPlayer = get_node("FartPlayer")
	if(!fartPlayer.is_playing()):
		fartPlayer.play()
