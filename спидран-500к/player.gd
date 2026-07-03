extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var coins = 0
var is_dead = false

const SPEED = 300.0
const JUMP_FORCE = -400.0
const GRAVITY = 1000.0

func _physics_process(delta):
	if is_dead:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

	if not is_on_floor():
		if anim.sprite_frames.has_animation("jump"):
			if anim.animation != "jump":
				anim.play("jump")
		else:
			if anim.animation != "run":
				anim.play("run")
	else:
		if direction == 0:
			if anim.animation != "idle":
				anim.play("idle")
		else:
			if anim.animation != "run":
				anim.play("run")

	move_and_slide()

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	print("💀 Смерть!")
	
	velocity = Vector2.ZERO
	
	# 🔴 КРАСНЫЙ ЦВЕТ
	if anim:
		anim.modulate = Color.RED
		# ПРИНУДИТЕЛЬНО обновляем спрайт
		anim.update()
		anim.visible = true
		print("🟥 Цвет изменен на КРАСНЫЙ")
	
	# 🔄 Перезапуск через await (с принудительной паузой)
	await _death_effect()

func _death_effect() -> void:
	# Ждем 1 секунду для отображения эффекта
	var elapsed = 0.0
	while elapsed < 1.0:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		# Держим красный цвет
		if anim:
			anim.modulate = Color.RED
	
	print("🔄 Перезапуск!")
	get_tree().reload_current_scene()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not is_dead:
		print("👾 Враг коснулся!")
		die()

func add_coin():
	if is_dead:
		return
	coins += 1
	update_coin_display()

func update_coin_display():
	var label = get_tree().root.find_child("Label", true, false)
	if label:
		label.text = "Монет: " + str(coins)
