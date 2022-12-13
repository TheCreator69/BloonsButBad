extends Node2D

const Monke = preload("res://Scenes/Monke.tscn")
const Bloon = preload("res://Scenes/Bloon.tscn")
const AMOABus = preload("res://Scenes/AMOABus.tscn")
const Musak = preload("res://Audio/SUBWAY SURFERS (Main Theme).mp3")
const AmogusMusak = preload("res://Audio/AmogusDrip.mp3")

var currentRound = 1
var money = 100
var health = 50

var bloonsPopped = 0
var bloonVariants = [
	[1, 1, Color(1.0, 0, 0)],	# [first round to appear at, health, color]
	[3, 2, Color(0.3, 0.3, 1.0)],
	[6, 3, Color(0.3, 1.0, 0.3)],
	[11, 4, Color(1.0, 1.0, 0.0)],
	[20, 11, Color(0.0, 0.0, 0.0)],
	[30, 15, Color(1.0, 1.0, 1.0)],
	]

var amogusSeen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("place_monke")):
		var mousePos = get_viewport().get_mouse_position()
		var tileMap = get_node("TileMap")
		
		var tilePos = Vector2(mousePos.x / tileMap.cell_size.x, mousePos.y / tileMap.cell_size.y)
		var tileIndex = tileMap.get_cellv(tilePos)
		
		if(tileIndex != 0 and money >= 50):
			var newMonke = Monke.instance()
			add_child(newMonke)
			newMonke.position = mousePos
			money -= 50
	
	# Remove all bloons if round win condition is met
	if(bloonsPopped >= currentRound * 20):
		currentRound += 1
		var children = get_children()
		for child in children:
			if(child.is_class(Bloon.get_class())):
				child.queue_free()
	
	# Lose condition: health <= 0
	if(health <= 0):
		get_tree().quit()
	
	# Update UI text
	get_node("GUI/VBoxContainer/HBoxContainer/MonehCounter").set_text(str(money))
	get_node("GUI/VBoxContainer/HBoxContainer2/HealfCounter").set_text(str(health))
	get_node("GUI/VBoxContainer/HBoxContainer3/RoundCounter").set_text(str(currentRound))

func _on_BloonSpawnTimer_timeout() -> void:
	var newBloon = null
	var isAmogus = false
	
	# Low change to spawn AMOABus starting at round 40 with 0.001 chance every spawn
	if(currentRound > 40 && randf() <= 0.001):
		newBloon = AMOABus.instance()
		isAmogus = true
		amogus_seen()
	else:
		newBloon = Bloon.instance()
	
	# Spawn new bloon
	add_child(newBloon)
	
	newBloon.position = get_node("BloonSpawnLocation").position
	newBloon.endLocation = get_node("BloonEndLocation").position
	
	newBloon.connect("BloonDestroyed", self, "on_bloon_destroyed")
	newBloon.connect("BloonReachedEnd", self, "on_bloon_reached_end")
	
	# Randomize bloon attributes based on currentRound
	if(isAmogus):
		newBloon.set_health(100)
		var amogusAnnouncement = get_node("AmogusAnnouncement")
		if(!amogusAnnouncement.is_playing()):
			amogusAnnouncement.play()
	else:
		var possibleVariants = []
		for variant in bloonVariants:
			if(currentRound >= variant[0]):
				possibleVariants.append(variant)
	
		possibleVariants.shuffle()
		var chosenVariant = possibleVariants[0]
	
		newBloon.set_health(chosenVariant[1])
		newBloon.set_color(chosenVariant[2])
	
	# Add new random time
	var medianTime = 1.0/(currentRound*2)
	var minTime = clamp(medianTime - 0.05, 0.05, 1)
	var maxTime = clamp(medianTime + 0.05, 0.1, 1)
	get_node("BloonSpawnTimer").wait_time = rand_range(minTime, maxTime)

func amogus_seen():
	if(amogusSeen):
		return
	
	var backgroundMusic = get_node("BackgroundMusic")
	backgroundMusic.stream = AmogusMusak
	backgroundMusic.volume_db = -5
	backgroundMusic.play()
	
	amogusSeen = true

func on_bloon_destroyed(moneyToAward):
	money += moneyToAward
	bloonsPopped += 1
	var popPlayer = get_node("PopPlayer")
	if(!popPlayer.is_playing()):
		popPlayer.play()

func on_bloon_reached_end(bloon):
	health -= 1
