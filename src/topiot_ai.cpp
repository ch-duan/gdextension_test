#include "topiot_ai.h"

#include <gdextension_interface.h>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include "dll_project.h"
#include "godot-cpp/include/godot_cpp/core/object.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

Topiot_ai::Topiot_ai() {}
Topiot_ai::~Topiot_ai() {}

void Topiot_ai::_bind_methods() {
  godot::ClassDB::bind_method(godot::D_METHOD("test_aaa"), &Topiot_ai::test_aaa);
  godot::ClassDB::bind_method(godot::D_METHOD("test_bbb"), &Topiot_ai::test_bbb);
  godot::ClassDB::bind_method(godot::D_METHOD("test_excute"), &Topiot_ai::test_excute);
  ADD_SIGNAL(MethodInfo(Signal_Excute_Result, PropertyInfo(Variant::STRING, "projectID"), PropertyInfo(Variant::STRING, "stepID"),
                        PropertyInfo(Variant::STRING, "result")));
}

void project_execute_cb(char* projectId, char* stepId, char* result, void* args) {
  Topiot_ai* topiot_ai = (Topiot_ai*) args;
  godot::String projectId1 = projectId;
  godot::String result2 = result;
  godot::String stepId3 = stepId;
  topiot_ai->emit_signal(Signal_Excute_Result, projectId1, stepId3, result2);
}

void Topiot_ai::test_aaa() {
  godot::UtilityFunctions::print("test 11\r\n");
}

void Topiot_ai::test_excute(godot::String projectFullPath, godot::String stepId, bool toTheEnd) {
  godot::UtilityFunctions::print("test 22\r\n");
  Execute((char*) projectFullPath.utf8().get_data(), (char*) stepId.utf8().get_data(), toTheEnd, this, project_execute_cb);
}

int Topiot_ai::test_bbb(int a, int b) {
  return a + b;
}