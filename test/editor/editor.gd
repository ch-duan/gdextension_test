extends Node

func test(projectID: String, stepID: String, result: String):
  print("test")
  print(projectID)
  print(stepID)
  print(result)

# Called when the node enters the scene tree for the first time.
func _ready():
  for n in $"%left".get_children():
    print(n.name)
  var s = Topiot_ai.new()
  s.topiot_ai_excute_result.connect(test.bind())
  s.test_aaa()
  s.test_excute("test_file/s1891.xml", "2", true)
  print(s.test_bbb(2, 3))

func _node_selected(node_name):
  print(node_name)

func _node_focused(node_name):
  print(node_name)
