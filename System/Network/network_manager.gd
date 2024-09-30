extends NTNode

class_name NetworkManager2

class PeerProxy extends RefCounted:
	var identity_profile_name : StringName
	var identity_profile_skin : int	#bits = 0 + 5 + 32
	
	var storage_inventory : PackedInt32Array
	
	func _init() -> void:
		return

var proxy : Dictionary

func _create_proxy(peer : int) -> void:
	proxy[peer] = PeerProxy.new()

func _remove_proxy(peer : int) -> void:
	proxy.erase(peer)

func _read_rpc_message(message : RPCMessage, payload : Variant, peer : int) -> void:
	match message:
		RPCMessage.CHANGE_PROFILE_INFORMATIONS:
			#offset   |   value
			#     0   :   username
			#     1   :   skin
			
			(proxy[peer] as PeerProxy).identity_profile_name = payload[0]
			(proxy[peer] as PeerProxy).identity_profile_skin = payload[1]

func _ready() -> void:
	multiplayer.peer_connected.connect(_create_proxy)
	multiplayer.peer_disconnected.connect(_remove_proxy)
	
	rpc_message_received.connect(_read_rpc_message)
