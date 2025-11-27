extends CharacterBody2D

@export var walk_speed: int = 120
@export var sprint_speed: int = 230
@export var max_stamina: float = 6.0
var stamina: float = max_stamina
var tired: bool
var stop_sprinting: bool

var direction: Vector2

var previous_frame: int = -1

var deadzone: float = 0.1
var look_vector: Vector2

var record_bus_index: int
var capture_effect: AudioEffectCapture
var generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback
var mic_enabled: bool = true

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if mic_enabled:
		$Sprite2D.visible = true
	else:
		$Sprite2D.visible = false
	$Camera2D.enabled = is_multiplayer_authority()
	
	InputMap.action_set_deadzone("look_up", deadzone)
	InputMap.action_set_deadzone("look_down", deadzone)
	InputMap.action_set_deadzone("look_left", deadzone)
	InputMap.action_set_deadzone("look_right", deadzone)
	
	record_bus_index = AudioServer.get_bus_index("Microphone")
	capture_effect = AudioServer.get_bus_effect(record_bus_index, 0)
	generator = AudioStreamGenerator.new()
	generator.mix_rate = AudioServer.get_mix_rate()
	if not is_multiplayer_authority():
		$Voice.stream = generator
		$Voice.play()
		playback = $Voice.get_stream_playback()

func _process(delta: float) -> void:
	if not (is_multiplayer_authority() and get_window().has_focus()):
		return
	direction = Input.get_vector("left", "right", "up", "down")

	if Input.is_action_pressed("sprint") and stamina > 0 and not tired and not stop_sprinting:
		velocity = direction * sprint_speed
		stamina -= delta
	else:
		velocity = direction * walk_speed
		if stamina <= max_stamina:
			stamina += delta
			
	move_and_slide()
			
	# STAMINA BAR ----------------------------------------------------------------------------------
	if stamina <= 0:
		stop_sprinting = true
		tired = true
		$StaminaBar.modulate = Color.RED
	elif stamina >= max_stamina / 2:
		tired = false
		$StaminaBar.modulate = Color.GREEN
		
	if Input.is_action_just_released("sprint"):
		stop_sprinting = false
		
	if stamina >= max_stamina:
		$StaminaBar.visible = false
	else:
		$StaminaBar.visible = true
		
	$StaminaBar.value = stamina * 100 / max_stamina
	
	# FLASHLIGHT -----------------------------------------------------------------------------------
	if Input.is_action_just_pressed("switch_flashlight"):
		$TorchLight.visible = not $TorchLight.visible
		
	look_vector = Vector2.ZERO
	look_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	look_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	$TorchLight.rotation = look_vector.angle()
	
	# ANIMATIONS -----------------------------------------------------------------------------------
	if direction != Vector2(0,0):
		if Input.is_action_pressed("sprint") and stamina > 0 and not tired and not stop_sprinting:
			$AnimatedSprite2D.play("sprint")
		else:
			$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
		previous_frame = -1
		
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
		
	# SOUNDS ---------------------------------------------------------------------------------------
	if $AnimatedSprite2D.animation == "sprint" or $AnimatedSprite2D.animation == "walk":
		var current_frame = $AnimatedSprite2D.frame
		if current_frame != previous_frame:
			rpc("play_footsteps", global_position)
			previous_frame = current_frame
		
		
	if capture_effect and mic_enabled:
		var frames: PackedVector2Array = capture_effect.get_buffer(512)
		if frames.size() > 0:
			rpc("send_voice_chunk", frames, $Voice)
			
@rpc("any_peer")
func send_voice_chunk(frames: PackedVector2Array, voice_player: AudioStreamPlayer2D) -> void:
	for frame in frames:
		playback.push_frame(frame)
	if GlobalVariables.line_of_sight(get_tree().current_scene.get_node(str(get_multiplayer_authority())).\
	global_position, voice_player.global_position):
		voice_player.bus = "MuffledVoice"
	else:
		voice_player.bus = "Voice"

@rpc("any_peer", "call_local")
func play_footsteps(audio_position: Vector2) -> void:
	var sound_player: AudioStreamPlayer2D = MusicPlayer.create_sound_player([
			preload("res://sounds/footsteps-1.wav"),
			preload("res://sounds/footsteps-2.wav"),
			preload("res://sounds/footsteps-3.wav"),
			preload("res://sounds/footsteps-4.wav"),
			preload("res://sounds/footsteps-5.wav"),
			preload("res://sounds/footsteps-6.wav"),
			preload("res://sounds/footsteps-7.wav"),
			preload("res://sounds/footsteps-8.wav"),
			preload("res://sounds/footsteps-9.wav"),
			preload("res://sounds/footsteps-10.wav"),
			preload("res://sounds/footsteps-11.wav"),
		], audio_position, 500, -5)
