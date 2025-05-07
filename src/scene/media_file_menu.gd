#============================================================
#    Media File Menu
#============================================================
# - author: zhangxuetu
# - datetime: 2025-05-06 01:28:14
# - version: 4.4.1.stable
#============================================================
extends PopupMenu


@export var media_file_container: MediaFileContainer:
	set(v):
		media_file_container = v
		media_file_container.added_item.connect(
			func(item):
				item.gui_input.connect(item_event.bind(item))
		)

var last_item: MediaFileNode

func item_event(event, item: MediaFileNode):
	if InputUtil.is_click_right(event, true):
		last_item = item
		popup(Rect2(item.get_global_mouse_position(), Vector2.ZERO))
	elif InputUtil.is_double_click(event):
		FileUtil.shell_open(item.media_file)


func _init():
	for item:String in [
		"打开",
		"重新加载缩略图",
		"-",
		"复制文件名",
		"复制文件地址",
		"复制缩略图地址",
		"-",
		"在文件管理器中显示",
	]:
		if item.begins_with("-"):
			add_separator()
		else:
			add_item(item)
	
	id_pressed.connect(
		func(id):
			var file = last_item.media_file
			match get_item_text(id):
				"打开":
					FileUtil.shell_open(file)
				"复制文件名":
					DisplayServer.clipboard_set(file.get_file())
				"复制文件地址":
					DisplayServer.clipboard_set(file)
				"复制缩略图地址":
					DisplayServer.clipboard_set(last_item.thumbnail_path)
				"重新加载缩略图":
					last_item.update_thumbnail()
				"在文件管理器中显示":
					FileUtil.show_in_explorer(file)
	)


func _unhandled_input(event):
	if visible:
		if event is InputEventMouseButton:
			if event.pressed:
				self.hide()
