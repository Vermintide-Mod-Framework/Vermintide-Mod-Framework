local dmf = get_mod("DMF")

-- Note(Siku): This file could definitely use the hooking system if we could figure out a way.
-- It would requires hooks to be pushed higher in the loading order, but then we lose hooks printing to console
-- Unless we find a way to store our logging messages in memory before the console is loaded.

-- Global backup of the ffi library
local _ffi = Mods.lua.ffi

local _console_data = dmf:persistent_table("dev_console_data")
if not _console_data.enabled then _console_data.enabled = false end
if not _console_data.original_print then _console_data.original_print = print end

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function open_dev_console()

  if not _console_data.enabled then

    local print_hook_function = function(func, ...)
      if _console_data.enabled then
        CommandWindow.print(...)
        func(...)
      else
        func(...)
      end
    end

    print = function(...)
      print_hook_function(_console_data.original_print, ...)
    end

    CommandWindow.open("Developer console")
    _console_data.enabled = true
  end
end

local function close_dev_console()

  if _console_data.enabled then

    print = _console_data.original_print

    CommandWindow.close()

    -- CommandWindow won't close by itself, so it have to be closed manually
    dmf:pcall(function()
      _ffi.cdef([[
        void* FindWindowA(const char* lpClassName, const char* lpWindowName);
        int64_t SendMessageA(void* hWnd, unsigned int Msg, uint64_t wParam, int64_t lParam);
      ]])
      local WM_CLOSE = 0x10;
      local hwnd = _ffi.C.FindWindowA("ConsoleWindowClass", "Developer console")
      _ffi.C.SendMessageA(hwnd, WM_CLOSE, 0, 0)
    end)

    _console_data.enabled = false
  end
end

-- ####################################################################################################################
-- ##### DMF internal functions and variables #########################################################################
-- ####################################################################################################################

dmf.toggle_developer_console = function ()

  if dmf:get("developer_mode") then

    local show_console = not dmf:get("show_developer_console")
    dmf:set("show_developer_console", show_console)

    dmf.load_dev_console_settings()

    if show_console then
      dmf:echo(dmf:localize("dev_console_opened"))
    else
      dmf:echo(dmf:localize("dev_console_closed"))
    end
  end
end

dmf.load_dev_console_settings = function()

  if dmf:get("developer_mode") and dmf:get("show_developer_console") then
    open_dev_console()
  else
    close_dev_console()
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

dmf.load_dev_console_settings()
