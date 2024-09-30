extends Node

class_name NetworkManager

static var SINGLETON : NetworkManager

const _PAYLOAD_HEADSIZE := 4 + 1 + 2

enum PAYLOAD_FLAGS {
	ERROR,
	REGULAR_PACKET,
	RPC,
	TASK,
}

"""
PAYLOAD HEAD
	TO : UINT 32 -> 4 bits
	FLAGS : UINT8 -> 1 bits
	EVENT : UINT16 -> 2 bits
"""

static func PYLD(to : int, flags : PAYLOAD_FLAGS, event : int) -> PackedByteArray:
	var payload : PackedByteArray
	payload.resize(_PAYLOAD_HEADSIZE)
	payload.encode_u32(0, to)
	payload.encode_u8(4, flags)
	payload.encode_u16(4 + 1, event)
	
	return payload

static var PAYLOAD_RESPONSE_ISVALID := false
static var PAYLOAD_RESPONSE_TO : int
static var PAYLOAD_RESPONSE_FLAGS : PAYLOAD_FLAGS
static var PAYLOAD_RESPONSE_MESSAGE : PackedByteArray
static var PAYLOAD_RESPONSE_EVENT : int

static func READ(payload : PackedByteArray) -> void:
	PAYLOAD_RESPONSE_ISVALID = false
	PAYLOAD_RESPONSE_FLAGS = PAYLOAD_FLAGS.ERROR
	PAYLOAD_RESPONSE_TO = -1
	PAYLOAD_RESPONSE_MESSAGE = PackedByteArray([])
	PAYLOAD_RESPONSE_EVENT = -1
	
	if not SINGLETON or payload.size() < _PAYLOAD_HEADSIZE:
		return
	
	var getpeer := payload.decode_u32(0)
	
	if SINGLETON.multiplayer.get_peers().has(getpeer) or SINGLETON.multiplayer.get_unique_id() == getpeer:
		var getflags := payload.decode_u8(4)
		
		if getflags != PAYLOAD_FLAGS.ERROR:
			var getevent := payload.decode_u16(4 + 1)
			
			if getevent > -1:
				PAYLOAD_RESPONSE_ISVALID = true
				PAYLOAD_RESPONSE_FLAGS = getflags
				PAYLOAD_RESPONSE_TO = getpeer
				PAYLOAD_RESPONSE_MESSAGE = payload.slice(_PAYLOAD_HEADSIZE)
				PAYLOAD_RESPONSE_EVENT = getevent

const _AUTHORITY_PEER := 1

const _EMIT_MODE_RELIABLE := MultiplayerPeer.TRANSFER_MODE_RELIABLE
const _EMIT_MODE_UNRELIABLE := MultiplayerPeer.TRANSFER_MODE_UNRELIABLE
const _EMIT_MODE_UNRELIABLE_SAFE := MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED

const _EMIT_CHANNEL_REGULAR_PACKETS := 0
const _EMIT_CHANNEL_RPC_PACKETS := 1
const _EMIT_CHANNEL_TASK_PACKETS := 2

static func EMIT(payload : PackedByteArray, mode : MultiplayerPeer.TransferMode, channel : int) -> void:
	if not SINGLETON:
		return
	
	if SINGLETON.multiplayer is SceneMultiplayer:
		(SINGLETON.multiplayer as SceneMultiplayer).send_bytes(payload, _AUTHORITY_PEER, mode, channel)



static func CONN(address : String, port : int) -> void:
	if not SINGLETON:
		return
	
	var enet := ENetMultiplayerPeer.new()
	
	if enet.create_client(address, port) == OK:
		SINGLETON.multiplayer.multiplayer_peer = enet


static func HOST(listen_port : int, capacity : int = 600) -> void:
	if not SINGLETON:
		return
	
	var enet := ENetMultiplayerPeer.new()
	
	if enet.create_server(listen_port, capacity) == OK:
		SINGLETON.multiplayer.multiplayer_peer = enet
		
		GUIManager.ALRT(CSTD.LSTR("HINT.SERVERSTARTED", [listen_port]))
		GUIManager.ALRT(CSTD.LSTR("HINT.SERVERSTARTED", [listen_port]), "Alert!")

func _peer_connected(peer : int) -> void:
	print("[NETWORK] Peer Connected: %s" % peer)

func _peer_disconnected(peer : int) -> void:
	print("[NETWORK] Peer Disconnected: %s" % peer)

func _peer_packet(sender : int, packet : PackedByteArray) -> void:
	READ(packet)
	
	if PAYLOAD_RESPONSE_ISVALID:
		if multiplayer.get_unique_id() == PAYLOAD_RESPONSE_TO:
			GUIManager.WARN(PAYLOAD_RESPONSE_MESSAGE.get_string_from_utf8(), 12.0)

func _client_connected() -> void:
	GUIManager.WARN(CSTD.LSTR("HINT.SERVERCONNECTED"), 3.0)
	
	var message := PYLD(_AUTHORITY_PEER, PAYLOAD_FLAGS.REGULAR_PACKET, 0)
	message.append_array("Hello".to_utf8_buffer())
	
	EMIT(message, _EMIT_MODE_RELIABLE, _EMIT_CHANNEL_REGULAR_PACKETS)

func _client_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	
	GUIManager.WARN(CSTD.LSTR("HINT.SERVERDISCONNECTED"), 3.0)

func _init() -> void:
	SINGLETON = self

func _enter_tree() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	multiplayer.connected_to_server.connect(_client_connected)
	multiplayer.connection_failed.connect(_client_disconnected)
	multiplayer.server_disconnected.connect(_client_disconnected)
	
	if multiplayer is SceneMultiplayer:
		multiplayer.peer_packet.connect(_peer_packet)
		multiplayer.server_relay = false

func _ready() -> void:
	return
