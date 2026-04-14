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
	
func has(item: Card):
	return queue.has(item)
	
func size() -> int:
	return queue.size()
	
#iterable support
func _should_continue(current):
	return queue._should_continue(current)

func _iter_init(iter) -> bool:
	return queue._iter_init(iter)

func _iter_next(iter):
	return queue._iter_next(iter)
	
func _iter_get(iter):
	return queue.iter_get(iter)
