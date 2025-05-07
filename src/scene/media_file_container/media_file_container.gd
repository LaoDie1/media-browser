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
@export var item_container : Container


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
	var file_dict := Dictionary(ProjectConfig.get_data("", "file_dict", {}))
	load_files(file_dict.keys())
	
	var scroll_bar : ScrollBar= %ScrollContainer.get_v_scroll_bar()
	scroll_bar.value_changed.connect(
		func(v): update_item_thumbnail()
	)
	%ScrollContainer.scroll_ended.connect(update_item_thumbnail)


func load_files(files: Array):
	var media_node: MediaFileNode
	for path:String in files:
		path = path.replace("\\", "/")
		if DirAccess.dir_exists_absolute(path):
			var list = FileUtil.scan_file(path, true)
			for i in list:
				media_node = add_item(i)
		else:
			media_node = add_item(path)


func add_item(path: String) -> MediaFileNode:
	if not FileAccess.file_exists(path):
		return null
	if MediaFileNode.is_loaded(path):
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
	if Time.get_ticks_msec() - _last_update_thumbnail_time < 200:
		return
	_last_update_thumbnail_time = Time.get_ticks_msec()
	
	await Engine.get_main_loop().create_timer(0.2).timeout
	_item_pos_dict.clear()
	var list : Array = []
	for child in item_container.get_children():
		if child is Control:
			list = Array(_item_pos_dict.get_or_add(int(child.global_position.y), []))
			list.append(child)
	
	var last_key
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
