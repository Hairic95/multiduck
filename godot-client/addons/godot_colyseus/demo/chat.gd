extends Control

var room: ColyseusRoom

func _ready():
	var client = ColyseusClient.new("ws://localhost:2567")
	var promise = client.join_or_create(ColyseusSchema, "chat")
	await promise.completed
	if promise.get_state() == promise.State.Failed:
		print("Failed")
		return
	var room: ColyseusRoom = promise.get_data()
	room.on_message("messages").on(Callable(self, "_on_messages"))
	$label.text += "Connected"
	self.room = room
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_messages(data):
	$label.text += "\n" + data


func _on_send_pressed():
	if $input.text.is_empty():
		return
	room.send("message", $input.text)
	$input.text = ""
