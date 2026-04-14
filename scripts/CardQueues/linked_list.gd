extends RefCounted
class_name DoublyLinkedList

var head: DoublyLinkedListNode

func enqueue(item: Card):
	var new_node = DoublyLinkedListNode.new(item)
	if not head:
		head = new_node
	else:
		var current = head
		while current.next:
			current = current.next
		current.link(new_node)
		
func dequeue() -> Card:
	var ret = head
	head = head.next
	return ret
	
func removeAt(index: int):
	var idx = 0
	var current = head
	while idx < index:
		current = current.next
		idx += 1
	current.prev.link(current.next)
	
func removeItem(item: Card):
	var current = head
	if current.value.id == item.id:
		head = head.next
	else:
		while current.value.id != item.id:
			current = current.next
		current.prev.link(current.next)
		
func has(item: Card) -> bool:
	var current = head
	while is_instance_valid(current):
		if current.value.id == item.id:
			return true
		current = current.next
	return false
	
func size() -> int:
	var idx = 0
	var current = head
	while is_instance_valid(current):
		current = current.next
		idx += 1
	return idx

func clear():
	head = null
