extends CharacterBody2D

class_name Entity

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: int
@export var sight_cone_width: int
var direction: Vector2
var target_player: Player

func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

func _process(_delta: float) -> void:
	for player: Player in get_tree().get_nodes_in_group("players"):
		if line_of_sight(player) and is_in_cone(player) and not target_player:
			target_player = player

func line_of_sight(player: Player) -> bool:
	var space_state = get_tree().current_scene.get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.new()
	params.from = global_position
	params.to = player.global_position
	params.exclude = []
	params.collision_mask = 1
	var result = space_state.intersect_ray(params)
	if result:
		return false
	return true

func is_in_cone(player: Player) -> bool:
	var to_target_diretion: Vector2 = (player.global_position - global_position).normalized()
	var half_angle: float = sight_cone_width * 0.5
	var dot: float = direction.normalized().dot(to_target_diretion)
	dot = clamp(dot, -1.0, 1.0)
	var angle_between: float = rad_to_deg(acos(dot))
	return angle_between <= half_angle
