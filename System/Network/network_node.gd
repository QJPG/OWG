extends Node

class_name NTNode

enum RPCMessage {
	CHANGE_PROFILE_INFORMATIONS,
}

signal rpc_message_received(_0 : RPCMessage, _1 : Variant, _2 : int)

@rpc("any_peer", "call_remote", "reliable")
func _rpc_message(message : RPCMessage, payload : Variant) -> void:
	rpc_message_received.emit(message, payload, multiplayer.get_remote_sender_id())
