#pragma once

extern "C" __declspec(dllexport) typedef void(__stdcall* ProgressCallback)(char* projectId, char* stepId, char* result);
extern "C" __declspec(dllexport) void Execute(char* projectFullPath, char* stepId, bool toTheEnd, ProgressCallback callback);
