#============================================================
#    Media File Container
#============================================================
# - author: zhangxuetu
# - datetime: 2025-05-05 23:59:39
# - version: 4.4.1.stable
#============================================================
class_name MediaFileContainer
extends Control


signal added_item(item: MediaFileNode)

@export var media_file_node: PackedScene
@export var scroll_container : ScrollContainer
@export var item_container : Container

@onready var last_scroll_v = ProjectConfig.get_data("", "item_scroll_value", 0)


func _init():
	Engine.get_main_loop().root.files_dropped.connect(
		func(files):
			var file_dict := Dictionary(ProjectConfig.get_data("", "file_dict", {}))
			for file in files:
				file_dict[file] = null
			await load_files(files)
			ProjectConfig.save_property_config()
			update_item_thumbnail()
	)


func _ready():
	scroll_container.get_v_scroll_bar().value_changed.connect(
		func(v): 
			update_item_thumbnail()
			ProjectConfig.add_data("", "item_scroll_value", v)
	)
	scroll_container.scroll_ended.connect(update_item_thumbnail)
	resized.connect(update_item_thumbnail)
	
	# 加载上次的文件
	var file_dict := Dictionary(ProjectConfig.get_data("", "file_dict", {}))
	load_files(file_dict.keys())
	
	while true:
		if last_scroll_v == 0:
			break
		
		scroll_container.get_v_scroll_bar().value = last_scroll_v
		if scroll_container.get_v_scroll_bar().value == last_scroll_v:
			break
		if Time.get_ticks_msec() > 5000:
			break
		await Engine.get_main_loop().process_frame


func load_files(files: Array):
	for path:String in files:
		path = path.replace("\\", "/")
		if DirAccess.dir_exists_absolute(path):
			var list = FileUtil.scan_file(path, true)
			await load_files(list)
		else:
			add_item(path)
		
		if item_container.get_child_count() % 20 == 0:
			await Engine.get_main_loop().process_frame


func add_item(path: String) -> MediaFileNode:
	if not FileAccess.file_exists(path):
		return null
	if MediaFileNode.is_loaded(path):
		return null
	if FileType.get_suffix_type(path) not in [FileType.IMAGE, FileType.VIDEO]:
		return null
	
	var item := media_file_node.instantiate() as MediaFileNode
	item.custom_minimum_size = MediaFileNode.image_size
	item_container.add_child(item)
	item.media_file = path
	added_item.emit(item)
	return item


var _item_pos_dict = {}
var _last_update_thumbnail_time = 0
func update_item_thumbnail():
	# 懒加载图片，防止一打开就显示所有图片
	if Time.get_ticks_msec() - _last_update_thumbnail_time < 200:
		return
	_last_update_thumbnail_time = Time.get_ticks_msec()
	
	# 节点分行
	await Engine.get_main_loop().create_timer(0.2).timeout
	_item_pos_dict.clear()
	var list : Array = []
	for child in item_container.get_children():
		if child is Control:
			list = Array(_item_pos_dict.get_or_add(int(child.global_position.y), []))
			list.append(child)
	
	# 加载当前屏幕中显示的节点
	var last_key = null
	for key in _item_pos_dict.keys():
		if key >= 0:
			list = _item_pos_dict[last_key if last_key else key]
			if not list.is_empty():
				var max_y = self.size.y
				var start_node : Control = list[0]
				var current: MediaFileNode
				for i in range(start_node.get_index(), item_container.get_child_count()):
					current = item_container.get_child(i)
					if not current:
						return
					if current.global_position.y >= max_y or current.global_position.y < -500:
						return
					await current.update_thumbnail()
					await Engine.get_main_loop().process_frame
				return
		last_key = key
