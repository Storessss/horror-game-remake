extends Node2D

@onready var multiplayer_menu: CanvasLayer = $MultiplayerMenu

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene = preload("res://scenes/main/player.tscn")

var can_start_game: bool = true

func _on_host_pressed() -> void:
	peer.create_server(2525)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	multiplayer_menu.visible = false
	
func _on_join_pressed() -> void:
	peer.create_client("127.0.0.1", 2525)
	multiplayer.multiplayer_peer = peer
	multiplayer_menu.visible = false

func add_player(id: int = 1) -> void:
	var player: CharacterBody2D = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func exit_game(id: int) -> void:
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id: int) -> void:
	rpc("_del_player", id)

@rpc("any_peer", "call_local") 
func _del_player(id: int) -> void:
	get_node(str(id)).queue_free()
	
func _process(_delta: float) -> void:
	if GlobalVariables.is_host() and can_start_game and Input.is_action_just_pressed("ui_accept"):
		can_start_game = false
		randomize()
		rpc("set_seed", randi_range(0, 999999))
		rpc("start_game")
	if Input.is_action_just_pressed("ui_accept"):
		$Darkness.visible = not $Darkness.visible
	
@rpc("any_peer", "call_local")
func set_seed(seed: int):
	seed(seed)

@rpc("any_peer", "call_local")
func start_game() -> void:
	var room: Room = GlobalVariables.rooms[0].instantiate()
	add_child(room)
	GlobalVariables.get_local_player().global_position = room.global_position + room.room_size / 2
	var robot: Entity = preload("res://scenes/entities/robot.tscn").instantiate()
	robot.global_position = room.global_position + room.room_size / 2
	add_child(robot)
