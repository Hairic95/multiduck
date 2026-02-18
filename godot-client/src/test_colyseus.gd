extends Node2D

func _ready() -> void:
	var client = ColyseusClient.new("ws://localhost:2567")
	var promise = client.join_or_create(ColyseusRoomState, "state_handler")
	await promise.completed
	if promise.get_state() == promise.State.Failed:
		print("Failed")
		return
	var room: ColyseusRoom = promise.get_result()
	var state: ColyseusRoomState = room.get_state()
	state.listen('players:add').on(_on_players_add)
	room.on_state_change.on(_on_state)
	room.on_message("hello").on(_on_message)

func _on_players_add():
	pass

func _on_state():
	pass

func _on_message():
	pass
