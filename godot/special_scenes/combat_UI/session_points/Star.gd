extends Node2D

class_name StarIcon

@export var won : bool = false :
	get:
		return won # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_won
@export var perfect : bool = false :
	get:
		return perfect # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_perfect

@onready var won_anim = $Wrapper/WonAnimationPlayer
@onready var float_anim = $Wrapper/FloatAnimationPlayer
@onready var sprite = $Wrapper/Sprite2D
@onready var label = $Wrapper/Label

func floating_star(wait_time):
	await get_tree().create_timer(wait_time*0.2).timeout
	float_anim.play('float')
	
func score():
	won_anim.play("won")
	z_index = 100
	label.text = 'PERFECT!' if perfect else ''

func set_won(value):
	won = value
	if is_inside_tree():
		refresh()
		
func set_perfect(value):
	perfect = value
	if perfect:
		sprite.modulate = Color(1.3,0,1.3,1)
	else:
		sprite.modulate = Color(1.1,1.1,1.1,1)
		
	$Wrapper/P.visible = perfect
	
	if is_inside_tree():
		refresh()
	
func _ready():
	refresh()
	
func refresh():
	sprite.play('full' if won else 'empty')
	sprite.visible = won
