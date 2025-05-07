#============================================================
#    Item Node
#============================================================
# - author: zhangxuetu
# - datetime: 2025-05-05 23:51:07
# - version: 4.4.1.stable
#============================================================
class_name MediaFileNode
extends Control


signal loaded


@export var video_load_max_time: float = 5.0
@export_file("*.*") var media_file: String:
	set(v):
		media_file = v.replace("\\", "/")
		tooltip_text = media_file
@export var hover_node: Control
@export var thumbnail_node: TextureRect
@export var file_name_node: Label
@export var type_icon_node: TextureRect

## 缩略图地址
var thumbnail_path: String


static var _cache_files : Dictionary = {}
static var _items : Array = []
static var image_size: Vector2 = Vector2(128, 128):
	set(v):
		image_size = v
		for item:MediaFileNode in _items:
			item.custom_minimum_size = image_size

static func is_loaded(file: String) -> bool:
	return _cache_files.has(file)


func _init():
	_items.append(self)


func _ready():
	self.custom_minimum_size = image_size
	mouse_entered.connect(hover_node.set.bind("visible", true))
	mouse_exited.connect(hover_node.set.bind("visible", false))


func _exit_tree():
	_items.erase(self)


func update_thumbnail():
	if FileAccess.file_exists(thumbnail_path):
		return
	
	match FileType.get_suffix_type(media_file):
		FileType.IMAGE:
			_push(media_file)
			type_icon_node.texture = preload("res://src/assets/icons8-image-48.png")
		
		FileType.VIDEO:
			var fn : String = media_file.get_file()
			type_icon_node.texture = preload("res://src/assets/icons8-video-48.png")
			if not fn.is_valid_filename():
				var new_path = media_file.get_base_dir().path_join(fn.validate_filename()) 
				if media_file != new_path and FileUtil.rename(media_file, new_path) == OK:
					media_file = new_path
			
			# 加载视频缩略图
			thumbnail_path = FFMpegUtil.generate_video_preview_image(media_file)
			var time = Time.get_ticks_msec()
			var MAX_TIME = 1000 * video_load_max_time
			while not FileAccess.file_exists(thumbnail_path) and Time.get_ticks_msec() - time < MAX_TIME:
				await Engine.get_main_loop().process_frame
			_push(thumbnail_path)
			
		_:
			queue_free()
			return


func _push(image_path: String):
	if not FileAccess.file_exists(media_file):
		return
	if FileAccess.file_exists(media_file):
		_cache_files[media_file] = null
	
	thumbnail_path = image_path
	var image : Image = null
	if FileAccess.file_exists(image_path):
		image = FileUtil.load_image(image_path)
	thumbnail_node.texture = ImageTexture.create_from_image(image) if image else preload("res://icon.svg")
	file_name_node.text = media_file.get_file()
	loaded.emit()
