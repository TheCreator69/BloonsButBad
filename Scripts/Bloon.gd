extends Node2D

signal BloonDestroyed
signal BloonReachedEnd

var movementDirection = Vector2(0, 1)

var bloonMovementChanges = [
	[880, -50, Vector2(0, 1)], 
	[880, 145, Vector2(-1, 0)], 
	[145, 145, Vector2(0, 1)], 
	[145, 497, Vector2(1, 0)], 
	[497, 497, Vector2(0, -1)], 
	[497, 305, Vector2(1, 0)], 
	[880, 305, Vector2(0, 1)]
]
var endLocation = Vector2(0, 0)

var totalHealth = 1
var health = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	for changePos in bloonMovementChanges:
		if(self.position.distance_to(Vector2(changePos[0], changePos[1])) < 1.0):
			self.movementDirection = changePos[2]
	
	self.position += self.movementDirection
	
	if(self.position.distance_to(endLocation) < 1.0):
		emit_signal("BloonReachedEnd", self)

func on_bloon_hit():
	health -= 1
	if(health <= 0):
		emit_signal("BloonDestroyed", totalHealth)
		queue_free()

func set_health(newHealth):
	totalHealth = newHealth
	health = newHealth

func set_color(color: Color):
	get_node("Bloon").modulate = color
