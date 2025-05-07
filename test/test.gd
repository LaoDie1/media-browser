@tool
extends EditorScript

func _run():
	pass
	
	var bytes = FileAccess.get_file_as_bytes('C:/Users/z/Pictures/素材/旧/yun2.png')
	var type = FileType.get_type(bytes)
	print(type)
	
	
