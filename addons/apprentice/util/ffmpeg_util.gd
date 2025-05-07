#============================================================
#    Ffmpeg Util
#============================================================
# - author: zhangxuetu
# - datetime: 2024-12-02 14:56:08
# - version: 4.3.0.stable
#============================================================
class_name FFMpegUtil


## 测试方式，显示执行数据
static var debug : bool = false
## ffmpeg.exe 文件路径 
static var ffmpeg_path: String = ""
## 独立线程
static var independent_thread: bool = false
static var open_console : bool = false


static func _execute_command(params: Array) -> Dictionary:
	params.push_front(ffmpeg_path)
	var p = ["/C"]
	p.append_array(params)
	if debug:
		printt(" ".join(params))
	if independent_thread:
		params.push_front("/C")
		var output = OS.execute_with_pipe("CMD.exe", params, false)
		return {
			"command": " ".join(params),
			"error": OK,
			"output": output,
		}
	else:
		var output: Array = []
		var err = OS.execute("CMD.exe", p, output, true, open_console)
		return {
			"command": " ".join(params),
			"error": err,
			"output": output[0]
		}


## 生成预览图片
static func generate_video_preview_image(video_path: String):
	assert(ffmpeg_path != "", "没有设置 ffmpeg_path 属性")
	var file_name = video_path.md5_text() + ".png"
	var path = OS.get_cache_dir() + "/Temp".path_join(file_name)
	if not FileAccess.file_exists(path):
		var result = _execute_command(["-i", '"%s"' % video_path, "-frames:v", "1", '"%s"' % path])
	return path
