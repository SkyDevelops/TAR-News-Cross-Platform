#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>
#include <shlwapi.h>

#include "flutter_window.h"
#include "utils.h"

#pragma comment(lib, "Shlwapi.lib")

// ── Registrasi URI scheme `tarnews://` ke HKCU (tidak butuh admin) ───────────
// Key: HKEY_CURRENT_USER\Software\Classes\tarnews
// Referensi: https://learn.microsoft.com/en-us/windows/win32/shell/app-registration
static void RegisterURIScheme() {
  // Dapatkan path executable saat ini
  wchar_t exePath[MAX_PATH];
  if (!GetModuleFileNameW(nullptr, exePath, MAX_PATH)) {
    return;  // Tidak bisa mendapatkan path, skip registrasi
  }

  // Buat string command untuk open: "<exe>" "%1"
  std::wstring openCmd = L"\"";
  openCmd += exePath;
  openCmd += L"\" \"%1\"";

  // Root key: HKCU\Software\Classes\tarnews
  const wchar_t* schemeKey = L"Software\\Classes\\tarnews";

  // Set (Default) = "URL:TAR News Protocol"
  HKEY hKey = nullptr;
  if (RegCreateKeyExW(HKEY_CURRENT_USER, schemeKey, 0, nullptr,
                      REG_OPTION_NON_VOLATILE, KEY_SET_VALUE | KEY_CREATE_SUB_KEY,
                      nullptr, &hKey, nullptr) == ERROR_SUCCESS) {
    const wchar_t* desc = L"URL:TAR News Protocol";
    RegSetValueExW(hKey, nullptr, 0, REG_SZ,
                   reinterpret_cast<const BYTE*>(desc),
                   static_cast<DWORD>((wcslen(desc) + 1) * sizeof(wchar_t)));

    // Set "URL Protocol" = ""
    RegSetValueExW(hKey, L"URL Protocol", 0, REG_SZ,
                   reinterpret_cast<const BYTE*>(L""),
                   static_cast<DWORD>(sizeof(wchar_t)));

    RegCloseKey(hKey);
  }

  // Set HKCU\Software\Classes\tarnews\shell\open\command = openCmd
  std::wstring cmdKey = schemeKey;
  cmdKey += L"\\shell\\open\\command";

  HKEY hCmdKey = nullptr;
  if (RegCreateKeyExW(HKEY_CURRENT_USER, cmdKey.c_str(), 0, nullptr,
                      REG_OPTION_NON_VOLATILE, KEY_SET_VALUE | KEY_CREATE_SUB_KEY,
                      nullptr, &hCmdKey, nullptr) == ERROR_SUCCESS) {
    RegSetValueExW(hCmdKey, nullptr, 0, REG_SZ,
                   reinterpret_cast<const BYTE*>(openCmd.c_str()),
                   static_cast<DWORD>((openCmd.size() + 1) * sizeof(wchar_t)));

    RegCloseKey(hCmdKey);
  }
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // Daftarkan URI scheme tarnews:// agar OAuth redirect kembali ke app.
  // Registrasi ke HKCU (per-user), tidak membutuhkan admin privilege.
  RegisterURIScheme();

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"tar_news", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
