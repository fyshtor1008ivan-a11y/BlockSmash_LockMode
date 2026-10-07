extends Node

var score: int = 0
var level: int = 1
var combo: int = 0

func add_points(amount: int) -> void:
    score += amount

func next_level() -> void:
    level += 1

func reset() -> void:
    score = 0
    level = 1
    combo = 0
