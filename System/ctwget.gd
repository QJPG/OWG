extends Control

class_name ctwidget

var widgets : Array[Control]
var index : int = -1

func _add_control(_control : Control, _index : int, _bind_callback : Callable, _id : int, _rect : Rect2) -> void:
	var added : bool
	
	if _index < 0:
		add_child(_control)
		added = true
	else:
		if _index < widgets.size():
			widgets[_index].add_child(_control)
			added = true
	
	if added == true:
		if _bind_callback.is_valid():
			_control.tree_entered.connect(func():
				_bind_callback.call(_control, _id))
		
		_control.tree_exited.connect(func():
			widgets.erase(_control))
		
		_control.size = _rect.size
		_control.position = _rect.position
		
		_control.set_meta("id", _id)
		_control.set_meta("uuid", randi())
		
		widgets.append(_control)
		index = widgets.size() - 1

func _init() -> void:
	return

func clear() -> void:
	for widget in widgets:
		widget.queue_free()
	
	widgets.clear()

func get_widgets_id(id : int) -> Array[ctwidget]:
	var _arr : Array[ctwidget]
	
	for _ctrl in widgets:
		if _ctrl.get_meta("id") == id:
			_arr.append(_ctrl)
	
	return _arr

func container(index := -1, rect := Rect2(), bind := Callable(), id := 0) -> ctwidget:
	var _container := PanelContainer.new()
	
	_add_control(_container, index, bind, id, rect)
	
	return self

func button(index := -1, rect := Rect2(), text := String("Click Here"), bind := Callable(), id := 0) -> ctwidget:
	var _button := Button.new()
	_button.text = text
	
	_add_control(_button, index, bind, id, rect)
	
	return self

func rect(index := -1, rect := Rect2(), color := Color.BLACK, bind := Callable(), id := 0) -> ctwidget:
	var _color := ColorRect.new()
	_color.color = color
	
	_add_control(_color, index, bind, id, rect)
	
	return self

func box(index := -1, rect := Rect2(), vertical := false, aligment := BoxContainer.AlignmentMode.ALIGNMENT_BEGIN, separation := 0.0, bind := Callable(), id := 0) -> ctwidget:
	var _box := BoxContainer.new()
	_box.vertical = vertical
	_box.alignment = aligment
	
	_add_control(_box, index, bind, id, rect)
	
	return self

func label(index := -1, rect := Rect2(), text := String(), haligment := HORIZONTAL_ALIGNMENT_LEFT, valigment := VERTICAL_ALIGNMENT_TOP, bind := Callable(), id := 0) -> ctwidget:
	var _label := Label.new()
	_label.text = text
	_label.horizontal_alignment = haligment
	_label.vertical_alignment = valigment
	
	_add_control(_label, index, bind, id, rect)
	
	return self

func rich(index := -1, rect := Rect2(), text := String(), bind := Callable(), id := 0) -> ctwidget:
	var _rich := RichTextLabel.new()
	_rich.bbcode_enabled = true
	_rich.text = text
	
	_add_control(_rich, index, bind, id, rect)
	
	return self

func margin(index := -1, rect := Rect2(), margins := Vector4i.ZERO, bind := Callable(), id := 0) -> ctwidget:
	var _margin := MarginContainer.new()
	_margin.add_theme_constant_override("margin_left", margins.x)
	_margin.add_theme_constant_override("margin_top", margins.y)
	_margin.add_theme_constant_override("margin_right", margins.z)
	_margin.add_theme_constant_override("margin_bottom", margins.w)
	
	_add_control(_margin, index, bind, id, rect)
	
	return self
