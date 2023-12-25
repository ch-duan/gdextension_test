#include "topiot_ai.h"

#include <gdextension_interface.h>

#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include <godot_cpp/core/class_db.hpp>

Topiot_ai::Topiot_ai() {}
Topiot_ai::~Topiot_ai() {}

void Topiot_ai::_bind_methods() {
  godot::ClassDB::bind_method(godot::D_METHOD("test_aaa"), &Topiot_ai::test_aaa);
}

void Topiot_ai::test_aaa() {
  printf("test 11 \r\n");
}