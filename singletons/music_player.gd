extends Node

var sound_players: Array

func create_sound_player(streams: Array[AudioStream], audio_position: Vector2, \
max_distance: int = 500, db: int = 0, spatial: bool = true):
	var sound_player
	if spatial:
		sound_player = AudioStreamPlayer2D.new()
	else:
		sound_player = AudioStreamPlayer.new()
	sound_player.stream = streams.pick_random()
	sound_player.volume_db = db
	sound_player.max_distance = max_distance
	sound_players.append(sound_player)
	sound_player.global_position = audio_position
	get_tree().current_scene.add_child(sound_player)
	sound_player.play()
	return sound_player

func _process(_delta: float) -> void:
	for sound_player in sound_players:
		if not sound_player.playing:
			sound_players.erase(sound_player)
			sound_player.queue_free()

func _ready() -> void:
	var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
	music_player.stream = preload("res://sounds/droning1.mp3")
	music_player.volume_db = -35
	add_child(music_player)
	music_player.play()
