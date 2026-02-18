extends Node2D

const colyseus = preload("res://addons/godot_colyseus/lib/colyseus.gd")
const Char = preload("./char.tscn")

class Player extends ColyseusSchema:
	static func define_fields():
		return [
			ColyseusSchema.Field.new("x", ColyseusTypes.NUMBER),
			ColyseusSchema.Field.new("y", ColyseusTypes.NUMBER)
		]
	
	var node
	
	func _to_string():
		return str("(",self.x,",",self.y,")")

class RoomState extends ColyseusSchema:
	static func define_fields():
		return [
			ColyseusSchema.Field.new("players", ColyseusTypes.MAP, Player),
		]

var room: ColyseusRoom

# Called when the node enters the scene tree for the first time.
func _ready():
	var client = ColyseusClient.new("ws://pangolin.lostpages.co.uk:2567/")
	var promise = client.join_or_create(RoomState, "squares_room")
	await promise.completed
	if promise.get_state() == promise.State.Failed:
		print("Failed")
		return
	print("SUCCESS")
	var room: ColyseusRoom = promise.get_data()
	var state: RoomState = room.get_state()
	state.listen('players:add').on(_on_players_add)
	room.on_state_change.on(_on_state)
	room.on_message("move").on(_on_message)
	self.room = room
	
func _on_message(data):
	print(str("move:", data))

func _on_state(state):
	pass

func _on_players_add(target, value, key):
	print("Add:", " key:", key, " ", value)
	var ch = Char.instantiate()
	ch.position = Vector2(value.x, value.y)
	add_child(ch)
	value.node = ch
	value.listen(":change").on(_on_player)

func _on_player(target):
	print("Change ", target)
	var ch = target.node
	ch.position = Vector2(target.x, target.y)

func _physics_process(delta):
	if room != null:
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		
		if velocity != Vector2.ZERO:
			print(velocity)
			velocity.normalized()
			room.send("move", { "x": velocity.x, "y": velocity.y })
