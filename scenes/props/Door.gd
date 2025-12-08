extends StaticBody2D

class_name Door

var can_interact: bool
var closed: bool = true

func switch_states() -> void:
	if closed:
		$AnimatedSprite2D.play("opening")
	else:
		$AnimatedSprite2D.play("closing")
		
	$AirlockSound.play()
		
func _process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact"):
		switch_states()
	
	$CollisionShape2D.disabled = not closed
	$LightOccluder2D.visible = closed
	
	if $AnimatedSprite2D.animation == "opening" and $AnimatedSprite2D.frame == 4:
		$AnimatedSprite2D.play("open")
		closed = false
	if $AnimatedSprite2D.animation == "closing" and $AnimatedSprite2D.frame == 4:
		$AnimatedSprite2D.play("closed")
		closed = true

func open() -> void:
	if closed:
		$AnimatedSprite2D.play("opening")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		can_interact = true
	elif body.is_in_group("robots"):
		start_opening(7.5)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		can_interact = false

func _on_opening_timer_timeout() -> void:
	open()
	
func start_opening(time: float) -> void:
	$OpeningTimer.wait_time = time
	$OpeningTimer.start()
