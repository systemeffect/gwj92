class_name Direction
extends Node

var move_direction: Card.DIRECTION
var move_amount: int

func _init(direction: Card.DIRECTION, amount: int):
	move_direction = direction
	move_amount = amount
