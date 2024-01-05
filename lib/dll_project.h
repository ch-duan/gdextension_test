#pragma once
// namespace ProjectAPI
// {

typedef void(__stdcall* ProgressCallback)(char* projectId, char* stepId, char* result, void* args);

extern "C" __declspec(dllexport) void Execute(char* projectFullPath, char* stepId, bool toTheEnd, void* args, ProgressCallback callback);
// }