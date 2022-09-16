extends ScrollContainer

@export var DeckListItemScene : PackedScene
@export var show_locked : bool = false
const DECK_PATH = "res://map/draft/decks/"

func _ready():
	Events.connect("starting_deck_selected",Callable(self,"deck_chosen"))
	var decks = global.get_resources(DECK_PATH)
	var unlocked_decks = TheUnlocker.get_unlocked_list("starting_decks")
	var i = 0
	for key in decks:
		if not show_locked and not unlocked_decks.has(key):
			continue
			
		var deck = decks[key]#global.get_actual_resource(decks, unlocked_decks[i])
		var item = DeckListItemScene.instantiate()
		item.set_deck(deck, unlocked_decks.has(key))
		if i % 2:
			item.color = Color(0,0,0,0.2)
		$VBoxContainer.add_child(item)
		i += 1
	await get_tree().create_timer(1).timeout
	for child in $VBoxContainer.get_children():
		var deck: StartingDeck = (child as DeckListItem).deck
		if global.starting_deck == deck.get_id():
			(child as DeckListItem).grab_focus()
			break
		
func deck_chosen(starting_deck: StartingDeck):
	global.starting_deck = starting_deck.get_id()
	Events.emit_signal("selection_starting_deck_over")
