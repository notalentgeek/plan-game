class_name Deck
extends Resource

var cards: Array[Card] = []

func _init(p_cards: Array[Card] = []):
	cards = p_cards

func add_card(card: Card) -> void:
	cards.append(card)

func add_cards(new_cards: Array[Card]) -> void:
	cards.append_array(new_cards)

func remove_card(index: int) -> Card:
	if index >= 0 and index < cards.size():
		var card = cards[index]
		cards.remove_at(index)
		return card
	return null

func draw_card() -> Card:
	if cards.size() > 0:
		return remove_card(0)
	return null

func shuffle() -> void:
	randomize()
	cards.shuffle()

func size() -> int:
	return cards.size()

func is_empty() -> bool:
	return cards.size() == 0

func clear() -> void:
	cards.clear()

func _to_string() -> String:
	return "[Deck: %d cards]" % size()
