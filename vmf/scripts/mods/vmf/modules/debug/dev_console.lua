local vmf = get_mod("VMF")

DEV_CONSOLE_ENABLED = DEV_CONSOLE_ENABLED or false
PRINT_ORIGINAL_FUNCTION = PRINT_ORIGINAL_FUNCTION or print

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function open_dev_console()

  if not DEV_CONSOLE_ENABLED then

    local print_hook_function = function(func, ...)
      if DEV_CONSOLE_ENABLED then
        CommandWindow.print(...)
        func(...)
      else
        func(...)
      end
    end

    print = function(...)
      print_hook_function(PRINT_ORIGINAL_FUNCTION, ...)
    end

    CommandWindow.open("Developer console")
    DEV_CONSOLE_ENABLED = true
  end
end

local function close_dev_console()

  if DEV_CONSOLE_ENABLED then

    print = PRINT_ORIGINAL_FUNCTION

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

    DEV_CONSOLE_ENABLED = false
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