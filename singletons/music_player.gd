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
