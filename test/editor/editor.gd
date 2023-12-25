extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
  for n in $"%left".get_children():
    print(n.name)
  var s = Topiot_ai.new()
  s.test_aaa()

func _node_selected(node_name):
  print(node_name)

func _node_focused(node_name):
  print(node_name)