@tool
extends EditorScript

func _run():
	
	var path = r"C:\Users\z\Downloads\社媒助手\小红书"
	var files = FileUtil.scan_file(path, false)
	for file:String in files:
		if file.get_file().contains("C__Users_z_Downloads_社媒助手_小红书_"):
			file = file.replace("\\", "/")
			file = file.replace("C__Users_z_Downloads_社媒助手_小红书_", "")
			var new_path = file.get_base_dir().path_join(file.get_file())
			FileUtil.rename(file, new_path)
			print(new_path)
	
