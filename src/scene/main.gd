#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2025-05-05 19:42:53
# - version: 4.4.1.stable
#============================================================
extends Node


@export var image_size_slider : Slider
@export var image_size_label: Label
@export var media_container: MediaFileContainer


func _enter_tree():
	image_size_label.text = str(int(image_size_slider.value))


func _ready():
	await Engine.get_main_loop().create_timer(0.5).timeout
	media_container.update_item_thumbnail()


func _exit_tree():
	ProjectConfig.register_node(image_size_slider, "value")


func update_image_size():
	var value = image_size_slider.value
	image_size_label.text = str(int(value))
	MediaFileNode.image_size = Vector2(value, value) 


func _on_h_slider_value_changed(value):
	update_image_size()

func _on_h_slider_drag_ended(value_changed):
	update_image_size()
