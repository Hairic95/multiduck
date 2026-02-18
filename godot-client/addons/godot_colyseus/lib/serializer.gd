extends RefCounted
class_name ColyseusSerializer

class Serializer:
	
	func set_state(decoder):
		pass
		
	func get_state():
		pass
	
	func patch(decoder):
		pass
	
	func teardown():
		pass
	
	func handshake(decoder):
		pass
	

class NoneSerializer extends Serializer:
	pass

class ReflectionField extends ColyseusSchema:
	
	static func define_fields():
		return [
			ColyseusSchema.Field.new("name", ColyseusTypes.STRING),
			ColyseusSchema.Field.new("type", ColyseusTypes.STRING),
			ColyseusSchema.Field.new("referenced_type", ColyseusTypes.NUMBER),
		]
	
	func test(field, reflection: Reflection) -> bool:
		if self.type != field.current_type.to_string() or self.name != field.name:
			var str1 = str(field.name, '-', self.name)
			var str2 = str(field.current_type, '-', self.type)
			printerr("Field not match ", str1, " : ", str2)
			return false
		if self.type == ColyseusTypes.REF:
			var type = reflection.types.at(self.referenced_type)
			return type.test(field.schema_type, reflection)
		return true

class ReflectionType extends ColyseusSchema:
	
	static func define_fields():
		return [
			ColyseusSchema.Field.new("id", ColyseusTypes.NUMBER),
			ColyseusSchema.Field.new("extendsId", ColyseusTypes.NUMBER),
			ColyseusSchema.Field.new("fields", ColyseusTypes.ARRAY, ReflectionField),
		]
	
	func test(schema_type, reflection: Reflection) -> bool:
		if not schema_type is GDScript:
			printerr("Type schema_type not match ", self.id)
			return false
		var fields = schema_type.define_fields()
		var length = fields.size()
		if length != self.fields.size():
			printerr("Type fields count not match ", self.id)
			return false
		for i in range(length):
			var field = self.fields.at(i)
			if not field.test(fields[i], reflection):
				return false
		return true

class Reflection extends ColyseusSchema:
	
	static func define_fields():
		return [
			ColyseusSchema.Field.new("types", ColyseusTypes.ARRAY, ReflectionType),
			ColyseusSchema.Field.new("root_type", ColyseusTypes.NUMBER),
		]
	
	func test(schema_type: GDScript) -> bool:
		return self.types.at(self.root_type).test(schema_type, self)

class SchemaSerializer extends Serializer:
	var state
	var schema_type: GDScript
	
	func _init(schema_type):
		self.schema_type = schema_type
		self.state = schema_type.new()
	
	func handshake(decoder):
		var reflection = Reflection.new()
		reflection.decode(decoder)
		assert(reflection.test(schema_type),"Can not detect schema type")
	
	func set_state(decoder):
		state.decode(decoder)
	
	func get_state():
		return state
	
	func patch(decoder):
		state.decode(decoder)
	

static func getSerializer(id: String, schema_type: GDScript = null) -> Serializer:
	match id:
		"schema":
			return SchemaSerializer.new(schema_type)
		"none":
			return NoneSerializer.new()
	return null
