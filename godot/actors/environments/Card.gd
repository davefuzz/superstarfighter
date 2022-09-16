extends Area2D

class_name Card

@onready var outline = $Ground/Outline
@onready var border = $Ground/Front/Border
@onready var background = $Ground/Front/Background
@onready var monogram = $Ground/Front/Wrapper/Monogram
@onready var timer = $Timer

@export (String) var content = null :
	get:
		return content # TODOConverter40 Copy here content of get_content
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_content

@export var auto_flip_back = false :
	get:
		return auto_flip_back # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_auto_flip_back
@export var take_ownership = false
@export var multiple_owners := false
@export var float_when_selected := true
@export var instant_reveal := false

signal revealing_while_undetermined
signal taken
signal revealed

var selected = false
var flipping = false
var face_down = true

var player = null :
	get:
		return player # TODOConverter40 Copy here content of get_player
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_player
var players := []
var ship
var character_player

func set_player(v):
	var previous_player = player
	player = v
	
	if multiple_owners:
		if player != null and not players.has(player):
			players.append(player)
	
	if take_ownership:
		if multiple_owners:
			if len(players) == 0:
				blur()
			else:
				var ids = ''
				for p in players:
					ids += '[color=#' + p.get_color().to_html() + ']' + p.get_id().to_upper() + '[/color]  '
				ids = ids.strip_edges()
				monogram.text = "[center]" + ids + "[/center]"
				monogram.visible = true
				
				self.select()
		else:
			if player == null:
				blur()
			else:
				monogram.text = "[center]" + player.get_id().to_upper() + "[/center]"
				monogram.modulate = player.species.color
				monogram.visible = true
				
				self.select()
				border.modulate = player.species.color # override color
	
	# this should be emitted here, after the value is updated correctly
	if player != previous_player and player != null:
		emit_signal('taken', self, v, ship)
	
func get_player():
	return player

func set_content(v):
	content = v
	refresh_texture()
	
func get_content():
	return content
	
func set_character_player(v):
	character_player = v
	if character_player != null:
		$Ground/Front/Character.visible = true
		$Ground/Front/Circle.visible = true
		$Ground/Front/Border.visible = true
		$Ground/Front/TopLeft.visible = true
		
		$Ground/Front/Background.self_modulate = Color(0.7,0.7,0.7)
		$Ground/Front/TopLeft/Monogram.self_modulate = Color(0.7,0.7,0.7)
		
		$Ground/Front/Background.modulate = character_player.species.color
		$Ground/Front/TopLeft/Monogram.modulate = character_player.species.color
		
		$Ground/Front/Character.texture = character_player.species.character_ok
		$Ground/Front/TopLeft/Monogram.text = character_player.get_id().to_upper()
		
func get_character_player():
	return character_player
	
func _ready():
	refresh_texture()
	
func refresh_texture():
	if content:
		$Ground/Front/Figure.texture = load('res://assets/sprites/' + content + '.png')
	else:
		$Ground/Front/Figure.texture = null

func tap(author):
	# no retaking if single owner
	if (not face_down or flipping) and not multiple_owners:
		return
		
	flipping = true
	if author is Ship:
		ship = author
		set_player(author.get_player())
	
	if face_down:
		reveal()

func reveal():
	face_down = false
	if content == null:
		emit_signal('revealing_while_undetermined', self)
	$AnimationPlayer.play("Reveal")
	if instant_reveal:
		$AnimationPlayer.seek(0.3)
	await $AnimationPlayer.animation_finished
	flipping = false
	emit_signal("revealed")
	if not selected or float_when_selected:
		$AnimationPlayer.play("Float")
	
	if auto_flip_back:
		# reflip after 6 seconds
		timer.start(6)
	
func select():
	selected = true
	border.modulate = Color(1.2,1.2,1.2)
	$'%Background'.modulate = Color(1.07,1.07,1.07)
	border.visible = true
	if not float_when_selected:
		$AnimationPlayer.play("Stand")
	
func deselect():
	selected = false
	$AnimationPlayer.play("Float")
	
func blur():
	border.visible = false
	monogram.visible = false
	
func hide():
	timer.stop()
	if face_down:
		return
		
	flipping = true
	face_down = true
	self.set_player(null)
	self.players = []
	selected = false
	$AnimationPlayer.play_backwards("Reveal")
	await $AnimationPlayer.animation_finished
	flipping = false

func equals(other_card):
	return content == other_card.content
	
func set_tint(color):
	$Ground/Front/Background.self_modulate = color
	
func _on_Card_body_entered(body):
	if body is Ship:
		Events.emit_signal("tappable_entered", self, body)
		
func show_tap_preview(ship : Ship):
	outline.visible = true
	outline.modulate = ship.species.color
	
func _on_ExitArea_body_exited(body):
	if body is Ship:
		Events.emit_signal("tappable_exited", self, body)
		
func hide_tap_preview():
	outline.visible = false
	
func _on_Timer_timeout():
	hide()

func set_auto_flip_back(v):
	auto_flip_back = v
	if not auto_flip_back:
		$Timer.stop()
		
func show_mark(v):
	$Ground/Front/Wrapper/Monogram.visible = true
	$Ground/Front/Wrapper/Monogram.text = "[center]" + str(v).to_upper() + "[/center]"
	
