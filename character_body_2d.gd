extends CharacterBody2D

@export var speed: float = 100.0
@export var distance: float = 200.0
@export var is_flying_enemy: bool = false # Поставь галочку в инспекторе, если враг летает!

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox 

var direction: int = 1
var start_x: float
var target_x: float

func _ready() -> void:
	start_x = global_position.x
	target_x = start_x + distance
	if sprite:
		sprite.play("default")
	
	if hitbox and not hitbox.is_connected("body_entered", Callable(self, "_on_hitbox_body_entered")):
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	# Полностью отключаем физические коллизии с окружением
	setup_ghost_mode()

func _physics_process(delta: float) -> void:
	# --- РЕЖИМ ПАТРУЛЯ ---
	velocity.x = speed * direction
	if is_flying_enemy: 
		velocity.y = 0 # Летающий враг не падает
	
	# Проверка границ патруля
	if direction == 1 and global_position.x >= target_x:
		direction = -1
	elif direction == -1 and global_position.x <= start_x:
		direction = 1

	# Двигаем врага без использования физики коллизий
	# Используем move_and_collide или просто перемещаем позицию
	var motion = velocity * delta
	global_position += motion
	# ИЛИ используй move_and_slide() если хочешь сохранить гравитацию
	# move_and_slide()

	if sprite:
		sprite.flip_h = direction < 0

func setup_ghost_mode() -> void:
	# Полностью отключаем все коллизии у CharacterBody2D
	collision_layer = 0
	collision_mask = 0
	
	# Отключаем коллизии у CollisionShape2D если он есть
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = true
	
	# Настраиваем хитбокс только для обнаружения игрока
	if hitbox:
		# Очищаем все маски
		hitbox.collision_layer = 0
		hitbox.collision_mask = 0
		# Включаем только обнаружение игрока (обычно слой 1)
		hitbox.collision_mask = 1 # Игрок на слое 1
		# Если игрок на другом слое, измени цифру
		
		# Включаем обработку для хитбокса
		hitbox.monitoring = true
		hitbox.monitorable = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Игрок пойман и убит врагом!")
		get_tree().reload_current_scene()
