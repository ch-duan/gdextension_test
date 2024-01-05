class_name My_custom_node

extends Node

@export var node_title: String:
 set = set_title

@onready var tips: Label = $"VBoxContainer/Label"

func set_title(new_title):
  node_title = new_title
  if tips != null:
    tips.text = new_title

# Called when the node enters the scene tree for the first time.
func _ready():
  set_title(node_title)