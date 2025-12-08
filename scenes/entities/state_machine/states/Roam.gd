extends State

class_name Roam

@onready var entity: Entity = get_parent().get_parent()

@export var speed: int
@export var animation: String
@export var footstep_sounds: Array[AudioStream]
@export var on_player_spotted: State

var move_point: Node2D

func Enter() -> void:
	await get_tree().process_frame
	move_point = GlobalVariables.move_points.pick_random()
	entity.nav.target_position = move_point.global_position

func Update(delta: float) -> void:
	if entity.target_player:
		Transitioned.emit(self, on_player_spotted)
		
	if animation:
		entity.animations.play(animation)

func Physics_Update(_delta: float) -> void:
	if entity.nav.is_navigation_finished():
		Transitioned.emit(self, self)
	else:
		var next_position = entity.nav.get_next_path_position()
		entity.direction = (next_position - entity.global_position).normalized()
		entity.velocity = entity.direction * speed
