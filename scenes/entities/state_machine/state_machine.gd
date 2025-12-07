extends Node

@export var initial_state: State

var current_state: State
var states: Array[State] = []

func _ready() -> void:
	for child in get_children():
		if child is State:
			states.append(child)
			child.Transitioned.connect(_on_child_transition)
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
			
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)
		
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)
	#print(current_state)

func _on_child_transition(state: State, new_state: State) -> void:
	if state != current_state:
		return
	if new_state == null or not states.has(new_state):
		return
	if current_state:
		current_state.Exit()
	current_state = new_state
	current_state.Enter()

func play_state(state: State) -> void:
	state.Enter()
	current_state = state
