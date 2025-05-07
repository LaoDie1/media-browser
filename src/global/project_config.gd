extends Node


var config_data_path = Global.PROJECT_DIR.path_join("config_data_path.data")
var config_data: Dictionary = {}


func _ready():
	# 项目配置数据
	if FileUtil.file_exists(config_data_path):
		var v = FileUtil.read_as_var(config_data_path)
		if v is Dictionary:
			config_data = v
	
	# 节点配置数据
	load_property_config()
	tree_exiting.connect(save_property_config)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_property_config()


func load_property_config():
	# 节点配置数据
	var node_propertys_dict = Dictionary(config_data.get_or_add("node_propertys", {}))
	if not node_propertys_dict.is_empty():
		#await Engine.get_main_loop().create_timer(0.5).timeout
		await Engine.get_main_loop().process_frame
		var root = Engine.get_main_loop().root
		for property_node_path:NodePath in node_propertys_dict:
			var sub_property_path : NodePath = property_node_path.get_as_property_path()
			var node_path : NodePath = property_node_path.slice(0, str(property_node_path).length()-str(sub_property_path).length())
			var node : Node = root.get_node_or_null(node_path)
			if node:
				var property = str(property_node_path).get_file()
				property = property.substr(property.find(":")+1)
				node[property] = node_propertys_dict[property_node_path]
			else:
				node_propertys_dict.erase(property_node_path)


# 保存加载的文件
func save_property_config():
	FileUtil.write_as_var(config_data_path, config_data)
	print("保存项目数据")


func register_node(node: Node, property: String):
	var node_path = NodePath(str(Engine.get_main_loop().root.get_path_to(node)) + ":" + property)
	var value = node[property]
	var node_propertys_dict = Dictionary(config_data.get_or_add("node_propertys", {}))
	node_propertys_dict[node_path] = value

func add_data(group = "", key = "", value = null) -> void:
	var group_data_dict = Dictionary(config_data.get_or_add(group, {}))
	group_data_dict[key] = value

func get_data(group = "", key = "", default = null):
	var group_data_dict = Dictionary(config_data.get_or_add(group, {}))
	return group_data_dict.get_or_add(key, default)
