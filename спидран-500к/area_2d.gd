extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Проверяем, что это игрок
	if body.name == "Player" or body.is_in_group("player"):
		# ✅ ИСПРАВЛЕНО: убрал аргумент, так как add_coin() теперь без параметров
		body.add_coin()
		queue_free()
