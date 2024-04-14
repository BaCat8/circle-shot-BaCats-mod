class_name Shooter
extends Node

## Shooter core class. Manages networking.
##
## [b]Note[/b]: Connection must be closed with [method close_connection] only
## on server, because it will be automatically closed when disconnected.

signal game_created(error: int)
signal game_joined(error: int)
signal connection_closed
const PORT := 14889
const MAX_CLIENTS := 10
const items_db: ItemsDB = preload("uid://pwq1e7l2ckos")
static var HEADLESS := false
static var is_in_network := false
static var game: Game


func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _process(_delta: float) -> void:
	if is_in_network:
		if multiplayer.multiplayer_peer:
			if multiplayer.multiplayer_peer.get_connection_status() != \
					MultiplayerPeer.CONNECTION_CONNECTED:
				close_connection()
		else:
			close_connection()


static func _static_init() -> void:
	if DisplayServer.get_name() == "headless":
		print("Detected headless platform")
		HEADLESS = true


func create_game() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CLIENTS - int(not HEADLESS))
	if error:
		game_created.emit(error)
		return
	multiplayer.multiplayer_peer = peer
	is_in_network = true
	game_created.emit(0)


func join_game(ip: String) -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(ip, PORT)
	if error:
		game_joined.emit(error)
		return
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		game_joined.emit(-1)
		return
	multiplayer.multiplayer_peer = peer


func close_connection() -> void:
	multiplayer.multiplayer_peer = null
	is_in_network = false
	connection_closed.emit()


func _on_connected_to_server() -> void:
	game_joined.emit(0)
	is_in_network = true


func _on_connection_failed() -> void:
	game_joined.emit(-1)
