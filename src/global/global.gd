#============================================================
#    Global
#============================================================
# - author: zhangxuetu
# - datetime: 2025-05-06 03:00:22
# - version: 4.4.1.stable
#============================================================
extends Node

var PROJECT_DIR: String = FileUtil.get_real_path("user://picture_browser/")

func _ready():
	FFMpegUtil.debug = true
	FFMpegUtil.ffmpeg_path = r"C:\Users\z\Downloads\ffmpeg-7.0.2-full\ffmpeg-7.0.2-full_build\bin\ffmpeg.exe"
	FFMpegUtil.independent_thread = true
