extends Label
var counter:int
var totalcounter:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("item_interact", _updateLabel)
	totalcounter = get_tree().get_nodes_in_group("Sprite").size()
	text = "sprites Obtained: " + str(counter) + "/" + str(totalcounter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _updateLabel(Collectible: item):
	if Collectible.item_name == "Sprite":
		counter += 1
		text = "sprites Obtained: " + str(counter) + "/" + str(totalcounter)
		print("Sprite Obtained")
