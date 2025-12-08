extends State

class_name Chase

@onready var entity: Entity = get_parent().get_parent()

@export var speed: int
@export var pursue_time: float
@export var animation: String
@export var footstep_sounds: Array[AudioStream]
@export var on_player_lost: State

var pursue_timer: float

func Enter() -> void:
	pursue_timer = pursue_time

func Update(delta: float) -> void:
	if not entity.line_of_sight(entity.target_player):
		pursue_timer -= delta
		if pursue_timer <= 0:
			entity.target_player = null
	else:
		pursue_timer = pursue_time
	if not entity.target_player:
		Transitioned.emit(self, on_player_lost)
		
	if animation:
		entity.animations.play(animation)

func Physics_Update(_delta: float) -> void:
	entity.nav.target_position = entity.target_player.global_position
	var next_position = entity.nav.get_next_path_position()
	entity.direction = (next_position - entity.global_position).normalized()
	entity.velocity = entity.direction * speed
