extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		print("Игрок наступил на шипы!")
		get_tree().reload_current_scene()
