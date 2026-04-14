extends RefCounted
class_name DoublyLinkedListNode

var value: Card
var next: DoublyLinkedListNode
var prev: DoublyLinkedListNode

func _init(item: Card):
	value = item

func link(item: DoublyLinkedListNode):
	next = item
	item.prev = self
