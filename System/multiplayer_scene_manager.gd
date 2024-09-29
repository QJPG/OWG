extends Node

func _init() -> void:
	add_space(preload("res://Game Assets/Scenes/main_menu.tscn"), &"TestMenu")

func add_space(scene : PackedScene, spacename : StringName ) -> void:
	var world_view := SubViewport.new()
	world_view.own_world_3d = true
	world_view.disable_3d = true
	world_view.unique_name_in_owner = true
	world_view.name = spacename
	
	var space_scene := scene.instantiate()
	world_view.add_child(space_scene)
	
	add_child(world_view)

@rpc("any_peer", "call_remote", "reliable")
func multiplayer_task_enter_space(spacename : StringName) -> void:
	var player := multiplayer.get_remote_sender_id()

@rpc("any_peer", "call_remote", "reliable")
func multiplayer_task_exit_space(space : StringName) -> void:
	var player := multiplayer.get_remote_sender_id()
