extends Node

var map := preload("res://Game Assets/Scenes/map.tscn")

func _server_error() -> void:
	get_tree().reload_current_scene()

func _init() -> void:
	return

"""
Before Scene Load
"""


func _enter_tree() -> void:
	multiplayer.server_disconnected.connect(_server_error)
	
	add_child(map.instantiate())
	
	var gltf := GLTFDocument.new()
	var state := GLTFState.new()
	
	var err := gltf.append_from_file("Game Assets/Models/post_a.gltf", state)
	
	if err == OK:
		var root := gltf.generate_scene(state)
		
		add_child(root)


"""
After Scene Load
"""


func _ready() -> void:
	return

"""
Application Closed
"""


func _exit_tree() -> void:
	return
