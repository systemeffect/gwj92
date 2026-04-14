extends Resource
class_name CardQueue

var queue: DoublyLinkedList

func _init():
	queue = DoublyLinkedList.new()

func enqueue(item: Card):
	queue.enqueue(item)

func dequeue():
	return queue.dequeue()

func removeAt(index: int):
	queue.removeAt(index)
	
func removeCard(item: Card):
	queue.removeCard(item)
	
func clear():
	queue.clear()
