DEV_CONSOLE_ENABLED = DEV_CONSOLE_ENABLED or false

if DEV_CONSOLE_ENABLED == false then

  local print_original_function = print

  local print_hook_function = function(func, ...)
    if DEV_CONSOLE_ENABLED then
      CommandWindow.print(...)
      func(...)
    else
      func(...)
    end
  end

  print = function(...)
    print_hook_function(print_original_function, ...)
  end

  CommandWindow.open("Developer console")
  DEV_CONSOLE_ENABLED = true
end