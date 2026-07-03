extends Node2D
var coins = 0
@onready var label = $CanvasLayer/Label
func add_coin():
	coins += 1 
	label.text = "Монеты: " + str(coins)
