extends Node2D

var movementDirection = Vector2(0, 0)
var movementSpeedMultiplier = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	self.position += movementDirection

func _on_Area2D_area_entered(area: Area2D) -> void:
	var potentialBloon = area.get_parent()
	if(potentialBloon.has_method("on_bloon_hit")):
		potentialBloon.on_bloon_hit()
		queue_free()

func _on_DespawnTimer_timeout() -> void:
	queue_free()
