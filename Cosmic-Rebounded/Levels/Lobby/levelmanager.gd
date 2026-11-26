extends Node2D

var pyrax = true
var cryax = true
var aquarius = true

func toggle_pyrax():
	pyrax = false
	
	
func toggle_cryax():
	pass
	
func toggle_aquarius():
	pass
	
var max = 100.0
var level = 0
var value = 0.0

func init_xp():
	return value

func init_levels():
	return level
	
func add_xp(amount):
	value += amount
	if value >= 100.0:
		value = (value - 100)
		level += 1
	return [level, value]
	
func reset_xp():
	value = 0.0
	level = 0
	
