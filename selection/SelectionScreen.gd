extends Control

const MAX_PLAYERS = 4
const MIN_PLAYERS = 2
onready var container = $Container
var ordered_species : Array

signal fight

var players_controls : Array
var num_players : int = 0


func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")


func initialize(available_species:Dictionary):
	ordered_species = available_species.keys()
	
	var i = 0
	for child in container.get_children():
		#set all to no
		child.set_controls_by_string("no")
		child.change_species(ordered_species[i])
		child.connect("prev", self, "get_adjacent", [-1, child])
		child.connect("next", self, "get_adjacent", [+1, child])
		child.connect("ready_to_fight", self, "ready_to_fight")
		i +=1
	var controls = assign_controls(2)
	for control in controls:
		print(add_controls(control))
	
func add_controls(key : String) -> bool:
	"""
	Add a controller (keyboard or joypad) as last player
	return false if reach limit of MAX_PLAYERS
	"""
	for child in container.get_children():
		if child.controls == "no":
			child.set_controls_by_string(key)
			return true
	return false

func change_controls(key:String, new_key:String) -> bool:
	for child in container.get_children():
		if child.controls == key:
			child.set_controls_by_string(new_key)
			return true
	return false
	
func assign_controls(num_keyboards : int) -> Array:
	"""
	Depending on how many keyboard want to play
	it puts keyboard control first then eventually disable the rest
	"""
	players_controls = []
	var num_players = 0
	# set for keyboards
	for i in range(num_keyboards):
		num_players +=1
		players_controls.append("kb"+str(i+1))
	
	# check on joypad
	var joypads = Input.get_connected_joypads()
	for i in range(len(joypads)):
		num_players+=1
		players_controls.append("joy"+str(i+1))
		if len(players_controls) >= MAX_PLAYERS:
			break

	# now put NO on the rest of players
	for i in range(num_players, MAX_PLAYERS):
		players_controls.append("no")
	
	return players_controls

# utils
func get_players() -> Array:
	var players = []
	for child in container.get_children():
		if child.controls != "no" and child.selected:
			players.append(child)
	return players
	
func get_adjacent(operator:int, player_selection : Node):
	var current_index = ordered_species.find(player_selection.species) 
	current_index = global.mod(current_index + operator,len(ordered_species))
	player_selection.change_species(ordered_species[current_index])
	
func _on_joy_connection_changed(device_id, connected):
	var joy = "joy"+str(device_id)
	if connected:
		add_controls(joy)
	else:
		change_controls(joy, "no")

func ready_to_fight():
	var players = get_players()
	print(players)
	if len(players) >= MIN_PLAYERS:
		emit_signal("fight", players)
	else:
		print("not enough players")
		