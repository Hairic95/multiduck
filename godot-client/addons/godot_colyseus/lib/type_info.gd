extends Object
class_name ColyseusTypeInfo

var type: String
var sub_type

func _init(type: String,sub_type = null):
	self.type = type
	self.sub_type = sub_type

func is_schema_type():
	return type == ColyseusTypes.REF or type == ColyseusTypes.MAP or type == ColyseusTypes.ARRAY or type == ColyseusTypes.COLLECTION or type == ColyseusTypes.SET

func _to_string():
	var ret = type
	if sub_type and sub_type.type != ColyseusTypes.REF:
		ret = str(ret, ':', sub_type.type)
	return ret

func create():
	match type:
		ColyseusTypes.REF:
			return sub_type.new()
		ColyseusTypes.MAP:
			var obj = ColyseusCollections.MapSchema.new()
			obj.sub_type = sub_type
			return obj
		ColyseusTypes.ARRAY:
			var obj = ColyseusCollections.ArraySchema.new()
			obj.sub_type = sub_type
			return obj
		ColyseusTypes.SET:
			var obj = ColyseusCollections.SetSchema.new()
			obj.sub_type = sub_type
			return obj
		ColyseusTypes.COLLECTION:
			var obj = ColyseusCollections.CollectionSchema.new()
			obj.sub_type = sub_type
			return obj

func decode(decoder: ColyseusDecoder):
	match type:
		ColyseusTypes.REF:
			var obj = sub_type.new()
			obj.id = decoder.number()
			return obj
		ColyseusTypes.MAP:
			var obj = ColyseusCollections.MapSchema.new()
			obj.id = decoder.number()
			obj.sub_type = sub_type
			return obj
		ColyseusTypes.ARRAY:
			var obj = ColyseusCollections.ArraySchema.new()
			obj.id = decoder.number()
			obj.sub_type = sub_type
			return obj
		ColyseusTypes.SET:
			var obj = ColyseusCollections.SetSchema.new()
			obj.id = decoder.number()
			obj.sub_type = sub_type
			return obj
		ColyseusTypes.COLLECTION:
			var obj = ColyseusCollections.CollectionSchema.new()
			obj.id = decoder.number()
			obj.sub_type = sub_type
			return obj
		ColyseusTypes.STRING:
			return decoder.read_utf8()
		ColyseusTypes.NUMBER:
			return decoder.number()
		ColyseusTypes.BOOLEAN:
			return decoder.reader.get_u8() > 0
		ColyseusTypes.INT8:
			return decoder.reader.get_8()
		ColyseusTypes.UINT8:
			return decoder.reader.get_u8()
		ColyseusTypes.INT16:
			return decoder.reader.get_16()
		ColyseusTypes.UINT16:
			return decoder.reader.get_u16()
		ColyseusTypes.INT32:
			return decoder.reader.get_32()
		ColyseusTypes.UINT32:
			return decoder.reader.get_u32()
		ColyseusTypes.INT64:
			return decoder.reader.get_64()
		ColyseusTypes.UINT64:
			return decoder.reader.get_u64()
		ColyseusTypes.FLOAT32:
			return decoder.reader.get_float()
		ColyseusTypes.FLOAT64:
			return decoder.reader.get_double()
		_:
			assert(true) #,str("Unkown support type:", type))
