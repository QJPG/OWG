extends Resource

class_name StorageSpace

@export var space_name : StringName
@export var space_scene : PackedScene
@export var space_max_players : int

var players_in_space : PackedInt32Array

func insert_player(player : int) -> SharedConstants.OUTPUT:
	if not players_in_space.has(player):
		if players_in_space.size() < space_max_players:
			players_in_space.append(player)
			
			return SharedConstants.OUTPUT.CONFIRMED
	
	return SharedConstants.OUTPUT.UNAUTHORIZED

func remove_player(player : int) -> void:
	if players_in_space.has(player):
		var find_player_index := players_in_space.find(player)
		
		if find_player_index > -1:
			players_in_space.remove_at(player)
