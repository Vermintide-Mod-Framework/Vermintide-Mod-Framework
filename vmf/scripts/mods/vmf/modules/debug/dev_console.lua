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
    DEV_CONSOLE_ENABLED = false
  end
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.toggle_developer_console = function (open_console)

  if open_console then
    open_dev_console()
  else
    close_dev_console()
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

if vmf:get("developer_mode") and vmf:get("show_developer_console") then
  open_dev_console()
end

