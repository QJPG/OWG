"""

DEPRECATED

"""


extends Node

class_name Application

static var SINGLETON : Application = Application.new()

enum NETWORK_CHANNEL {
	CHANNEL_EVENT,
}

enum EVENT {
	SPACE_ENTER,
	SPACE_EXIT,
}

class NetworkTransport extends RefCounted:
	var is_server : bool
	var address : String
	var port : int
	var max_connections : int
	var auth : PackedByteArray
	
	func get_enet_transport() -> ENetMultiplayerPeer:
		var enet := ENetMultiplayerPeer.new()
		
		if is_server:
			if enet.create_server(port, max_connections) == OK:
				return enet
		else:
			if enet.create_client(address, port, ) == OK:
				return enet
	
		return null

signal MULTIPLAYER_ENTERED_SPACE(_space : StringName)
signal MULTIPLAYER_REMOVED_SPACE(_space : StringName)

@rpc("authority", "call_remote", "reliable", NETWORK_CHANNEL.CHANNEL_EVENT)
func multiplayer_receive_event(event : EVENT, payload : Variant) -> void:
	match event:
		EVENT.SPACE_ENTER:
			MULTIPLAYER_ENTERED_SPACE.emit(payload)
		
		EVENT.SPACE_EXIT:
			MULTIPLAYER_REMOVED_SPACE.emit(payload)

func _client_connection_failed() -> void:
	multiplayer.multiplayer_peer = null

func _client_connection_success() -> void:
	return

func application_create_network(transport : NetworkTransport) -> void:
	multiplayer.multiplayer_peer = transport.get_enet_transport()
	
	if multiplayer is SceneMultiplayer:
		if transport.is_server:
			multiplayer.server_relay = false
		else:
			multiplayer.server_disconnected.connect(_client_connection_failed)
			multiplayer.connection_failed.connect(_client_connection_failed)
			multiplayer.connected_to_server.connect(_client_connection_success)

func _init() -> void:
	return

func _ready() -> void:
	lstr.open("Game Assets/Texts/en.json")
	
	var _args := OS.get_cmdline_args()
	var _transport := Application.NetworkTransport.new()
	
	_transport.address = "127.0.0.1"
	_transport.port = 22023
	_transport.max_connections = 600
	
	for _argstr in _args:
		if (_argstr as String) == "@":
			_transport.is_server = true
			
			DisplayServer.window_set_title("(Run Program in Headless Mode)Server[%s" % _transport.port)
	
	application_create_network(_transport)
