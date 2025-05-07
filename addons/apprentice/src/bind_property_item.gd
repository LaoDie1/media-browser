#============================================================
#    Bind Property Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-29 13:14:59
# - version: 4.3.0.dev5
#============================================================
## 绑定属性项
##
##绑定属性后，设置修改这个项，会自动更新绑定的所有对象的属性。
class_name BindPropertyItem
extends RefCounted


signal value_changed(previous, value)

const META_KEY = &"_PropertyBindItem_value"

var _name: String
var _method_list : Array = []
var _bind_propertys : Array[Array] = []
var _value


#============================================================
#  内置
#============================================================
func _init(name: String, value = null) -> void:
	_name = name
	_value = value


#============================================================
#  自定义
#============================================================
## 获取当前属性名
func get_name() -> String:
	return _name

## 值相同
func equals_value(value) -> bool:
	return typeof(_value) == typeof(value) and _value == value

## 绑定对象属性到当前属性
func bind_property(object: Object, property: StringName, update: bool = false) -> BindPropertyItem:
	assert(property in object, "这个对象没有这个属性")
	_bind_propertys.append([ object, property ])
	if update and typeof(_value) != TYPE_NIL and not equals_value(object[property]):
		object[property] = _value
		#print_debug("修改 ", object, " 的 ", property, " 属性为 ", _value)
	return self

## 绑定方法
func bind_method(method: Callable, update: bool = false):
	_method_list.append(method)
	if update:
		method.call(_value)

## 绑定信号到当前属性。这个信号需要有一个参数，接收改变的值
func bind_signal(_signal: Signal) -> BindPropertyItem:
	_signal.connect(update)
	return self

## 取消绑定属性
func unbind_property(object: Object, property):
	var data = hash([object, property])
	for idx in _bind_propertys.size():
		if hash(_bind_propertys[idx]) == data:
			_bind_propertys.remove_at(idx)
			break

## 断开绑定属性
func unbind_method(method: Callable):
	_method_list.erase(method)

## 更新属性
func update(value) -> void:
	if not equals_value(value):
		var previous = _value
		_value = value
		# 设置属性
		for method:Callable in _method_list:
			if method.is_valid():
				method.call(value)
		var object: Object
		var property
		for arg in _bind_propertys:
			object = arg[0]
			if is_instance_valid(object):
				property = arg[1]
				if typeof(object[property]) != typeof(value) or object[property] != value:
					object.set(property, value)
		value_changed.emit(previous, value)

## 获取属性值
func get_value(default = null):
	if typeof(_value) == TYPE_NIL:
		return default
	return _value

func get_number(default = 0.0) -> float:
	if typeof(_value) == TYPE_NIL:
		return default
	return float(_value)
