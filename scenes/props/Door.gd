extends StaticBody2D

class_name Door

var can_interact: bool
var closed: bool = true

var players_in_area: Array[Player]

func switch_states() -> void:
	if closed:
		$AnimatedSprite2D.play("opening")
	else:
		$AnimatedSprite2D.play("closing")
		
	$AirlockSound.play()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		rpc("request_interact")
	
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
	if body.is_in_group("players") and body not in players_in_area:
		players_in_area.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("players") and body in players_in_area:
		players_in_area.erase(body)

func _on_opening_timer_timeout() -> void:
	open()
	
func start_opening(time: float) -> void:
	$OpeningTimer.wait_time = time
	$OpeningTimer.start()

@rpc("any_peer", "call_local", "reliable")
func request_interact():
	var sender_id: int = multiplayer.get_remote_sender_id()
	for player in players_in_area:
		if player.get_multiplayer_authority() == sender_id:
			switch_states()
			break
