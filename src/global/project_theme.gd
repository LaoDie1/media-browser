extends Node

var prompt_color : Color = Color.WHITE


func _ready():
	update_theme.call_deferred()


## 主题
func update_theme():
	var window : Window = get_viewport()
	var type : SystemUtil.ThemeType = SystemUtil.get_theme_type()
	if type == SystemUtil.ThemeType.DARK:
		window.theme = FileUtil.load_file("res://src/assets/dark_theme.tres")
		RenderingServer.set_default_clear_color(Color(0.2, 0.2, 0.2))
	else:
		window.theme = FileUtil.load_file("res://src/assets/light_theme.tres")
		RenderingServer.set_default_clear_color(Color(0.95, 0.95, 0.95))


#func get_theme_type() -> SystemUtil.ThemeType:
	#var type
	#if Config.Project.theme.get_number(0) == 0:
		#type = SystemUtil.get_theme_type()
	#else:
		#type = SystemUtil.ThemeType.LIGHT if Config.Project.theme.get_number(0) == 1 else SystemUtil.ThemeType.DARK
	#return type
