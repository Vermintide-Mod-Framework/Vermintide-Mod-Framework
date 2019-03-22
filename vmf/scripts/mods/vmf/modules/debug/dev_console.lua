local vmf = get_mod("VMF")

-- Note(Siku): This file could definitely use the hooking system if we could figure out a way.
-- It would requires hooks to be pushed higher in the loading order, but then we lose hooks printing to console
-- Unless we find a way to store our logging messages in memory before the console is loaded.

local _console_data = vmf:persistent_table("dev_console_data")
if not _console_data.enabled then _console_data.enabled = false end
if not _console_data.original_print then _console_data.original_print = print end

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function open_dev_console()

  -- Forbid using dev console in official realm. Hopefully, temporarily restriction. So no localization.
  if not VT1 and not script_data["eac-untrusted"] then
    vmf:echo("You can't use developer console in official realm.")
    return
  end

  if not _console_data.enabled then

    local print_hook_function = function(func, ...)
      if _console_data.enabled then
        if VT1 then
          CommandWindow.print(...)
        else
          local console_message = {...}
          for i, element in ipairs(console_message) do
            console_message[i] = tostring(element)
          end
          table.insert(console_message, '\n')
          CommandWindow.print(table.concat(console_message, " "))
        end
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
    vmf:pcall(function()
      local ffi = require("ffi")
      ffi.cdef([[
        void* FindWindowA(const char* lpClassName, const char* lpWindowName);
        int64_t SendMessageA(void* hWnd, unsigned int Msg, uint64_t wParam, int64_t lParam);
      ]])
      local WM_CLOSE = 0x10;
      local hwnd = ffi.C.FindWindowA("ConsoleWindowClass", "Developer console")
      ffi.C.SendMessageA(hwnd, WM_CLOSE, 0, 0)
    end)

    _console_data.enabled = false
  end
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.toggle_developer_console = function ()

  if vmf:get("developer_mode") then

    local show_console = not vmf:get("show_developer_console")
    vmf:set("show_developer_console", show_console)

    vmf.load_dev_console_settings()

    if show_console then
      vmf:echo(vmf:localize("dev_console_opened"))
    else
      vmf:echo(vmf:localize("dev_console_closed"))
    end
  end
end

vmf.load_dev_console_settings = function()

  if vmf:get("developer_mode") and vmf:get("show_developer_console") then
    open_dev_console()
  else
    close_dev_console()
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.load_dev_console_settings()
