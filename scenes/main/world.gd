extends Node2D

@onready var multiplayer_menu: CanvasLayer = $MultiplayerMenu

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene = preload("res://scenes/main/player.tscn")

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
