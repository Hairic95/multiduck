extends ColyseusSchema
class_name ColyseusRoomState

static func define_fields():
	return [ColyseusSchema.Field.new("players", ColyseusTypes.MAP, null)]
