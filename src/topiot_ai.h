#pragma once
#include <godot_cpp/classes/ref.hpp>

using namespace godot;

class Topiot_ai : public Object {
  GDCLASS(Topiot_ai, Object);

 private:
  double time_passed;

 protected:
  static void _bind_methods();

 public:
  Topiot_ai();
  ~Topiot_ai();
  void test_aaa();
};
