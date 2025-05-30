#============================================================
#    Scirpt Util
#============================================================
# - datetime: 2022-07-17 17:25:00
#============================================================
## 处理脚本的工具
class_name ScriptUtil


const NAME_TO_DATA_TYPE = {
	&"null": TYPE_NIL,
	&"bool": TYPE_BOOL,
	&"int": TYPE_INT,
	&"float": TYPE_FLOAT,
	&"String": TYPE_STRING,
	&"Rect2": TYPE_RECT2,
	&"Vector2": TYPE_VECTOR2,
	&"Vector2i": TYPE_VECTOR2I,
	&"Vector3": TYPE_VECTOR3,
	&"Vector3i": TYPE_VECTOR3I,
	&"Transform2D": TYPE_TRANSFORM2D,
	&"Vector4": TYPE_VECTOR4,
	&"Vector4i": TYPE_VECTOR4I,
	&"Plane": TYPE_PLANE,
	&"Quaternion": TYPE_QUATERNION,
	&"AABB": TYPE_AABB,
	&"Basis": TYPE_BASIS,
	&"Transform3D": TYPE_TRANSFORM3D,
	&"Projection": TYPE_PROJECTION,
	&"Color": TYPE_COLOR,
	&"StringName": TYPE_STRING_NAME,
	&"NodePath": TYPE_NODE_PATH,
	&"RID": TYPE_RID,
	&"Object": TYPE_OBJECT,
	&"Callable": TYPE_CALLABLE,
	&"Signal": TYPE_SIGNAL,
	&"Dictionary": TYPE_DICTIONARY,
	&"Array": TYPE_ARRAY,
	&"PackedByteArray": TYPE_PACKED_BYTE_ARRAY,
	&"PackedInt32Array": TYPE_PACKED_INT32_ARRAY,
	&"PackedInt64Array": TYPE_PACKED_INT64_ARRAY,
	&"PackedStringArray": TYPE_PACKED_STRING_ARRAY,
	&"PackedVector2Array": TYPE_PACKED_VECTOR2_ARRAY,
	&"PackedVector3Array": TYPE_PACKED_VECTOR3_ARRAY,
	&"PackedFloat32Array": TYPE_PACKED_FLOAT32_ARRAY,
	&"PackedFloat64Array": TYPE_PACKED_FLOAT64_ARRAY,
	&"PackedColorArray": TYPE_PACKED_COLOR_ARRAY,
}


static var _global_data : Dictionary = {}
##  获取 Dictionary 数据
static func _singleton_dict(meta_key: StringName, default: Dictionary = {}) -> Dictionary:
	if _global_data.has(meta_key):
		return _global_data.get(meta_key)
	else:
		_global_data[meta_key] = default
		return default


static func _get_script_data_cache(script: Script) -> Dictionary:
	return _singleton_dict("ScriptUtil__get_script_data_cache")


## 获取字典的值，如果没有，则获取并设置默认值
##[br]
##[br][code]dict[/code]  获取的字典
##[br][code]key[/code]  key 键
##[br][code]not_exists_set[/code]  没有则返回值设置这个值。这个回调方法返回要设置的数据
static func _get_value_or_set(dict: Dictionary, key, not_exists_set: Callable = Callable()):
	if dict.has(key) and not typeof(dict[key]) == TYPE_NIL:
		return dict[key]
	else:
		if not_exists_set.is_valid():
			dict[key] = not_exists_set.call()
			return dict[key]

## 获取这个类名的类型
static func get_type_of(_class_name: StringName) -> int:
	return NAME_TO_DATA_TYPE.get(_class_name, -1)

## 是否是基础数据类型
static func is_base_data_type(_class_name: StringName) -> bool:
	return NAME_TO_DATA_TYPE.has(_class_name)


##  获取属性列表
##[br]
##[br]返回类似如下格式的数据
##[codeblock]
##{ 
##    "name": "RefCounted", 
##    "class_name": &"", 
##    "type": 0, 
##    "hint": 0, 
##    "hint_string": "", 
##    "usage": 128 
##}
##[/codeblock]
static func get_property_data_list(script: Script) -> Array[Dictionary]:
	if is_instance_valid(script):
		return script.get_script_property_list()
	return Array([], TYPE_DICTIONARY, "Dictionary", null)


## 获取属性名称列表
static func get_property_name_list(script: Script) -> Array[String]:
	var list : Array[String] = []
	if script != null:
		for data in get_property_data_list(script):
			if data["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE == PROPERTY_USAGE_SCRIPT_VARIABLE:
				list.append(data["name"])
	return list


##  获取方法列表
static func get_method_data_list(script: Script) -> Array[Dictionary]:
	if is_instance_valid(script):
		return script.get_script_method_list()
	return Array([], TYPE_DICTIONARY, "Dictionary", null)


## 获取方法的参数列表数据
static func get_method_arguments_list(script: Script, method_name: StringName) -> Array[Dictionary]:
	var data = get_method_data(script, method_name)
	if data:
		return data.get("args", Array([], TYPE_DICTIONARY, "Dictionary", null))
	return Array([], TYPE_DICTIONARY, "Dictionary", null)


##  获取信号列表
static func get_signal_data_list(script: Script) -> Array[Dictionary]:
	if is_instance_valid(script):
		return script.get_script_signal_list()
	return Array([], TYPE_DICTIONARY, "Dictionary", null)


## 获取这个属性名称数据
static func get_property_data(script: Script, property: StringName) -> Dictionary:
	var data = _get_script_data_cache(script)
	var p_cache_data : Dictionary = _get_value_or_set(data, "propery_data_cache", func():
		var property_data : Dictionary = {}
		for i in script.get_script_property_list():
			property_data[i['name']] = i
		return property_data
	)
	return p_cache_data.get(property, {})


## 获取这个名称的方法的数据
static func get_method_data(script: Script, method_name: StringName) -> Dictionary:
	var data = _get_script_data_cache(script)
	var m_cache_data : Dictionary = _get_value_or_set(data, "method_data_cache", func():
		var method_data : Dictionary = {}
		for i in script.get_script_method_list():
			method_data[i['name']]=i
		return method_data
	)
	return m_cache_data.get(method_name, {})


## 获取这个名称的信号的数据
static func get_signal_data(script: Script, signal_name: StringName):
	var data = _get_script_data_cache(script)
	var s_cache_data : Dictionary = _get_value_or_set(data, "script_data_cache", func():
		var signal_data : Dictionary = {}
		for i in script.get_script_signal_list():
			signal_data[i['name']]=i
		return signal_data
	)
	return s_cache_data.get(signal_name, {})


##  获取方法数据
## [br]
## [br]- [code]script[/code]  脚本
## [br]- [code]method[/code]  要获取的方法数据的方法名
## [br]- [code]return[/code]  返回脚本的数据信息.
##  包括的 key 有 [code]name[/code], [code]args[/code], [code]default_args[/code]
## , [code]flags[/code], [code]return[/code], [code]id[/code]
func find_method_data(script: Script, method: String) -> Dictionary:
	var method_data = script.get_script_method_list()
	for m in method_data:
		if m['name'] == method:
			return m
	return {}


##  获取扩展脚本链（扩展的所有脚本）
##[br]
##[br][code]script[/code]  Object 对象或脚本
##[br][code]return[/code]  返回继承的脚本路径列表
static func get_extends_link(script: Script) -> PackedStringArray:
	var list := PackedStringArray()
	while script:
		if FileUtil.file_exists(script.resource_path):
			list.push_back(script.resource_path)
		script = script.get_base_script()
	return list


##  获取基础类型继承链类列表
##[br]
##[br]- [code]_class[/code]  基础类型类名
##[br]- [code]return[/code]  返回基础的类名列表
static func get_extends_link_base(_class) -> PackedStringArray:
	if _class is Script:
		_class = _class.get_instance_base_type()
	elif _class is Object:
		_class = _class.get_class()
	
	var c = _class
	var list = []
	while c != "":
		list.append(c)
		c = ClassDB.get_parent_class(c)
	return PackedStringArray(list)


##  生成方法代码
##[br]
##[br]- [code]method_data[/code]  方法数据
##[br]- [code]return[/code]  返回生成的代码
static func generate_method_code(method_data: Dictionary) -> String:
	var temp := method_data.duplicate(true)
	var args := ""
	for i in temp['args']:
		var arg_name = i['name']
		var arg_type = ( type_string(i['type']) if i['type'] != TYPE_NIL else "")
		if arg_type.strip_edges() == "":
			arg_type = str(i['class_name'])
		if arg_type.strip_edges() != "":
			arg_type = ": " + arg_type
		args += "%s%s, " % [arg_name, arg_type]
	temp['args'] = args.trim_suffix(", ")
	if temp['return']['type'] != TYPE_NIL:
		temp['return_type'] = type_string(temp['return']['type'])
	
	if temp.has('return_type') and temp['return_type'] != "":
		temp['return_type'] = " -> " + str(temp['return_type'])
		temp['return_sentence'] = "pass\n\treturn super." + temp['name'] + "()"
	else:
		temp['return_type'] = ""
		temp['return_sentence'] = "pass"
	
	return "func {name}({args}){return_type}:\n\t{return_sentence}\n".format(temp)


##  获取对象的脚本
static func get_object_script(object: Object) -> Script:
	if object == null:
		return null
	if object is Script:
		return object
	return object.get_script() as Script


##  对象是否是 tool 状态
##[br]
##[br]- [code]object[/code]  返回这个对象的脚本是否是开启 tool 的状态
static func is_tool(object: Object) -> bool:
	var script = get_object_script(object)
	return script.is_tool() if script else false


## 获取对象的脚本路径，如果不存在脚本，则返回空的字符串
static func get_object_script_path(object: Object) -> String:
	var script = get_object_script(object)
	return script.resource_path if script else ""


##  获取这个对象的这个方法的信息
##[br]
##[br]- [code]object[/code]  对象
##[br]- [code]method_name[/code]  方法名
##[br]- [code]return[/code]  返回方法的信息
static func get_object_method_data(object: Object, method_name: StringName) -> Dictionary:
	if not is_instance_valid(object):
		return {}
	var script = get_object_script(object)
	if script:
		return get_method_data(script, method_name)
	return {}


## 获取这个信号的数据
static func get_object_signal_data(object: Object, signal_name: StringName) -> Dictionary:
	if not is_instance_valid(object):
		return {}
	var script = get_object_script(object)
	if script:
		return get_signal_data(script, signal_name)
	return {}


## 获取对象的属性数据
static func get_object_property_data(object: Object, proprety_name: StringName) -> Dictionary:
	if not is_instance_valid(object):
		return {}
	var script = get_object_script(object)
	if script:
		return get_property_data(script, proprety_name)
	return {}


##  获取内置类名称转为对象。比如将 "Node" 字符串转为 [Node] 这种 GDScriptNativeClass 类型数据
##[br]
##[br]- [code]_class[/code]  类名称
static func get_built_in_class (_class: StringName):
	if not ClassDB.class_exists(_class):
		return null
	var _class_db = _singleton_dict("ScriptUtil_get_built_in_class")
	return _get_value_or_set(_class_db, _class, func():
		var script = GDScript.new()
		script.source_code = "var type = " + _class
		if script.reload() == OK:
			var obj = script.new()
			_class_db[_class] = obj.type
			return _class_db[_class]
		else:
			push_error("错误的类名：", _class)
		return null
	)


## 根据类名返回类对象，比如
##[codeblock]
##var _class = ScriptUtil.get_script_class("Player") # 类对象
##var player = _class.new()
##[/codeblock]
static func get_script_class(_class: StringName):
	if ClassDB.class_exists(_class):
		return null
	var _class_db = _singleton_dict("ScriptUtil_get_script_class")
	return _get_value_or_set(_class_db, _class, func():
		var script = GDScript.new()
		script.source_code = "var type = " + _class
		if script.reload() == OK:
			var obj = script.new()
			_class_db[_class] = obj.type
			return _class_db[_class]
		else:
			push_error("错误的类名：", _class)
		return null
	)


## 获取这个类的场景。这个场景的位置和名称需要和脚本一致，只有后缀名不一样。这个类不能是内部类
static func get_script_scene(script: GDScript) -> PackedScene:
	var data = _singleton_dict("ScriptUtil_get_script_scene")
	if data.has(script):
		return data[script]
	else:
		var path := script.resource_path
		if path == "":
			return null
		
		var ext := path.get_extension()
		var file = path.substr(0, len(path) - len(ext))
		
		var scene: PackedScene
		if FileUtil.file_exists(file + "tscn"):
			scene = ResourceLoader.load(file + "tscn", "PackedScene") as PackedScene
		elif FileUtil.file_exists(file + "scn"):
			scene = ResourceLoader.load(file + "scn", "PackedScene") as PackedScene
		else:
			printerr("这个类目录下没有相同名称的场景文件！")
			return null
		data[script] = scene
		return scene


## 字符串转为类对象
static func str_to_class(_class: StringName):
	if ClassDB.class_exists(_class):
		return get_built_in_class(_class)
	else:
		return get_script_class(_class)


##  获取对象的 Class 对象。如果是自定义类返回 [GDScript] 类；如果是内置类，则返回 [GDScriptNativeClass] 类
static func get_class_object(value):
	if value is Script:
		return value
	
	elif value is String or value is StringName:
		return str_to_class(value)
	
	elif value is Object:
		if value.get_script() != null:
			return value.get_script()
		return get_built_in_class(value.get_class())
	
	return null


## 是否有这个类
static func has_class(_class: StringName) -> bool:
	if ClassDB.class_exists(_class):
		return true
	else:
		var script = GDScript.new()
		script.source_code = "var type = " + _class
		return script.reload() == OK


## 获取对象类名 
static func get_class_name(value, cache: bool = true) -> StringName:
	if value is Object:
		if value is Script:
			var script := value as Script
			var data = _get_script_data_cache(script)
			if not cache:
				data.erase(script)
			return _get_value_or_set(data, script, func():
				if script.has_source_code():
					var reg = RegEx.new()
					reg.compile(
						"([^#]*)" # 前面不能有“#”
						+ "(^class_name|\n\\w*\\s*class_name)\\s+" # class_name 格式
						+ "(\\w+)" # 类名
					)
					var class_name_result = reg.search(script.source_code)
					if class_name_result:
						return StringName(class_name_result.get_string(3))
					else:
						return script.get_instance_base_type()
						
				return script.get_instance_base_type()
			)
			
		else:
			if value.get_script():
				return get_class_name(value.get_script(), cache)
			else:
				return value.get_class()
			
	else:
		return type_string(typeof(value))


## 获取这个类名称的实例对象
static func get_instance(_class_name: StringName) -> Object:
	var _class = str_to_class(_class_name)
	if _class:
		return _class.new()
	else:
		push_error("没有这个名称的类")
		return null

static func get_base_path(script:Script) -> String:
	return script.resource_path.get_base_dir()


##  属性是否存在 Setter 或 Getter 方法
##[br]
##[br]- [code]script[/code]  脚本
##[br]- [code]propertys[/code]  属性列表
##[br]- [code]return[/code]  返回结果会是以
##[codeblock]
##{
##    "property": {
##        "setter": true,
##        "getter": false,
##    }
##}
##[/codeblock]
##的结构返回
static func has_getter_or_setter(script: Script, propertys: PackedStringArray) -> Dictionary:
	var tmp_script = GDScript.new()
	tmp_script.source_code = script.source_code
	var map : Dictionary = {}
	for data in get_method_data_list(tmp_script):
		map[data["name"]] = null
	
	var result : Dictionary = {}
	for property in propertys:
		result[property] = {
			"setter": map.has("@%s_setter" % property) or map.has("set_%s" % property),
			"getter": map.has("@%s_getter" % property) or map.has("get_%s" % property),
		}
	return result


#============================================================
#  初始化类静态变量数据
#============================================================

##初始化类的静态变量值为自身的名称。用于方便添加静态属性，作为配置 key 使用。导出时需要设置脚本为“文本”的格式
##[br]
##[br]- [code]script[/code]  注入的脚本或脚本类 
##[br]- [code]handle_method[/code]  处理注入的方式。不传入这个参数默认设置值为对应的属性名字符串。
##这个方法需要接收 3 个参数:
##[br]      - [code]script[/code] : 接收对应类的脚本
##[br]      - [code]class_path[/code] : 类的路径
##[br]      - [code]property[/code] : 属性名
##[br]- [code]return[/code]  返回注入的属性名路径
##[br]
##[br]比如添加一个 [code]ConfigKey[/code] 类里面添加静态变量作为配置属性
##[codeblock]
##class_name ConfigKey
##
##class Path:
##    static var current_dir
##    static var opened_files
##[/codeblock]
##可以方便的通过传入 [code]ConfigKey.Path.current_dir[/code] 作为 key 获取配置属性值
static func init_class_static_value(script: GDScript, handle_method: Callable = Callable()) -> Array[String]:
	if not handle_method.is_valid():
		handle_method = func(_script:GDScript, path:String, property:String):
			_script.set(property, property)
	# 处理
	var data = ScriptUtil.analyze_class_and_static_var(script)
	if data.is_empty() and not OS.has_feature("editor"):
		push_error("导出时的脚本格式不是“文本”")
	var propertys : Array[String] = []
	__init_class_static_value(script, "", data, propertys, handle_method)
	return propertys

static func __init_class_static_value(script: GDScript, class_path: String, items: Array, propertys: Array, handle_method: Callable = Callable()):
	var script_map = script.get_script_constant_map()
	for item:Dictionary in items:
		if item["type"] == "var":
			handle_method.call(script, class_path, item["name"])
			propertys.append(class_path + "/" + item["name"])
		elif item["type"] == "class":
			var sub_class_script = script_map[item["name"]]
			__init_class_static_value(sub_class_script, class_path + "/" + item["name"], item["items"], propertys, handle_method)

static var __analy_class_data : Dictionary = {}
## 分析类中的静态变量
static func analyze_class_and_static_var(script: GDScript):
	if not __analy_class_data.has(script):
		# 分析
		var data = []
		var lines = script.source_code.split("\n")
		__analyze_class_and_static_var(lines, 0, -1, data, "")
		__analy_class_data[script] = data
	return __analy_class_data[script]

static var class_regex : RegEx:
	get:
		if class_regex == null:
			class_regex = RegEx.new()
			class_regex.compile("(?<indent>\\s*)class\\s+(?<class_name>\\w+)\\s*:")
		return class_regex
static var var_regex : RegEx:
	get:
		if var_regex == null:
			var_regex = RegEx.new()
			var_regex.compile("(?<indent>\\s*)static\\s+var\\s+(?<var_name>[^:\\s]+)")
		return var_regex

static func __analyze_class_and_static_var(code_lines: Array, p_line: int, parent_indent: int, data: Array, parent_class: String) -> int:
	var class_result: RegExMatch
	var class_indent: int
	var _class_name : String
	var var_result: RegExMatch
	var var_indent: int 
	var var_name: String
	var line : String
	while p_line < code_lines.size():
		line = code_lines[p_line]
		var_result = var_regex.search(line)
		if var_result:
			var_indent = var_result.get_string("indent").length()
			if var_indent < parent_indent:
				return p_line - 1
			var_name = var_result.get_string("var_name")
			data.append({
				"type": "var",
				"name": var_name,
				"line": p_line,
			})
			
		else:
			class_result = class_regex.search(line)
			if class_result:
				class_indent = class_result.get_string("indent").length()
				_class_name = class_result.get_string("class_name")
				
				if parent_indent < class_indent:
					# 这个类的信息
					var items : Array = []
					data.append({
						"type": "class",
						"name": _class_name,
						"items": items,
						"line": p_line,
					})
					# 继续向下执行
					p_line = __analyze_class_and_static_var(code_lines, p_line + 1, class_indent, items, _class_name)
				else:
					# 必须在父级缩进之后，返回执行到的位置，让上级继续执行这一行
					return p_line - 1
					
		p_line += 1
	return p_line
