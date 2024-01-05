#pragma once
#include <godot_cpp/classes/ref.hpp>

#define Signal_Excute_Result "topiot_ai_excute_result"
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
  template <class... Args>
  void send_app(const godot::String signal, Args... args) {
    call_deferred("emit_signal", godot::Array::make(signal, args...));
  }
  void test_aaa();
  int test_bbb(int a, int b);
  void test_excute(godot::String projectFullPath, godot::String stepId, bool toTheEnd);
};
