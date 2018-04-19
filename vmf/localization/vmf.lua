return {
  mods_options = {
    en = "Mods Options",
    ru = "Настройки модов",
  },
  open_vmf_options = {
    en = "Open Options Menu",
    ru = "Открыть меню настроек",
  },
  open_vmf_options_tooltip = {
    en = "Keybind for opening and closing mods options menu.",
    ru = "Клавиша / сочетание клавиш для открытия и закрытия меню настроек модов.",
  },
  vmf_options_scrolling_speed = {
    en = "Options Menu Scrolling Speed",
    ru = "Скорость прокрутки меню",
  },
  ui_scaling = {
    en = "UI Scaling for FHD+ Resolutions",
    ru = "Нормализация масштаба UI для FHD+ разрешений",
  },
  ui_scaling_tooltip = {
    en = "Automatically scale UI when resolution exceeds 1080p.",
    ru = "Нормализует масштаб элементов интерфейса, если разрешений экрана превышает 1080p.",
  },
  developer_mode = {
    en = "Developer Mode",
    ru = "Режим разработчика",
  },
  developer_mode_tooltip = {
    en = "Allows you to reload VMF and mods, gives you access to some debug features.",
    ru = "Позволяет перезагружать VMF и моды, даёт доступ к инструментам отладки.",
  },
  show_developer_console = {
    en = "Show Developer Console",
    ru = "Консоль разработчика",
  },
  show_developer_console_tooltip = {
    en = "Opens up the new window showing game log in real time.",
    ru = "Открывает новое окно, в которое в реальном времени выводится игровой лог.",
  },
  toggle_developer_console = {
    en = "Toggle Developer Console",
    ru = "Открыть/закрыть консоль разработчика",
  },
  show_network_debug_info = {
    en = "Log Network Calls",
    ru = "Логирование сетевых вызовов",
  },
  show_network_debug_info_tooltip = {
    en = "Log all the VMF network calls and all the data transfered with them.\n\n" ..
         "The method 'info' is used for the logging.",
    ru = "Логирование всех сетевых вызовов VMF и передаваемых с ними данных.\n\n" ..
         "Для логирования используется метод 'info'.",
  },
  log_ui_renderers_info = {
    en = "Log UI Renderers Creation Info",
    ru = "Логирование информации при создании UI Renderer",
  },
  log_ui_renderers_info_tooltip = {
    en = "Log the UI Renderer's creator name and all the materials passed as the agruments.\n\n" ..
         "The method 'info' is used for the logging.",
    ru = "Логирование имени создателя UI Renderer'а и всех материалов, переданных в качестве аргументов.\n\n" ..
         "Для логирования используется метод 'info'.",
  },
  logging_mode = {
    en = "Logging Settings",
    ru = "Настройки логирования",
  },
  settings_default = {
    en = "Default",
    ru = "Стандартные",
  },
  settings_custom = {
    en = "Custom",
    ru = "Пользовательские",
  },
  output_mode_echo = {
    en = "'Echo' Output",
    ru = "Вывод 'Echo'",
  },
  output_mode_error = {
    en = "'Error' Output",
    ru = "Вывод 'Error'",
  },
  output_mode_warning = {
    en = "'Warning' Output",
    ru = "Вывод 'Warning'",
  },
  output_mode_info = {
    en = "'Info' Output",
    ru = "Вывод 'Info'",
  },
  output_mode_debug = {
    en = "'Debug' Output",
    ru = "Вывод 'Debug'",
  },
  output_disabled = {
    en = "Disabled",
    ru = "Выключен",
  },
  output_log = {
    en = "Log",
    ru = "Лог",
  },
  output_chat = {
    en = "Chat",
    ru = "Чат",
  },
  output_log_and_chat = {
    en = "Log & Chat",
    ru = "Лог и чат",
  },
  chat_history_enable = {
    en = "Chat Input History",
    ru = "История ввода чата",
  },
  chat_history_enable_tooltip = {
    en = "Saves all the messages and commands you typed in the chat window.\n\n" ..
         "You can browse your input history by opening the chat and pressing \"Arrow Up\" and \"Arrow Down\".",
    ru = "Сохраняет все сообщения и команды, введённые в чате.\n\n" ..
         "Чтобы пролистывать историю ввода, откройте чат и используйте клавиши \"стрелка вверх\" и \"стрелка вниз\".",
  },
  chat_history_save = {
    en = "Save Input History Between Game Sessions",
    ru = "Сохранять историю ввода между сеансами игры",
  },
  chat_history_save_tooltip = {
    en = "Your chat input history will be saved even after reloading your game (or just VMF).",
    ru = "Когда игрок выключает игру (или перезагружает VMF), VMF cохраняет историю ввода в файл настроек, чтобы загрузить её при следующем запуске игры.",
  },
  chat_history_buffer_size = {
    en = "Input History Buffer Size",
    ru = "Размер буфера истории ввода",
  },
  chat_history_buffer_size_tooltip = {
    en = "Maximum number of saved entries.\n\n" ..
         "WARNING: Changing this setting will erase your chat history.",
    ru = "Максимальное количество сохраняемых записей.\n\n" ..
         "ВНИМАНИЕ: изменение этой настройки очистит вашу историю ввода.",
  },
  chat_history_remove_dups = {
    en = "Remove Duplicate Entries",
    ru = "Удалять повторяющиеся записи",
  },
  chat_history_remove_dups_mode = {
    en = "Removal Mode",
    ru = "Режим удаления",
  },
  chat_history_remove_dups_mode_tooltip = {
    en = "Which duplicate entries should be removed.\n\n" ..
         "-- LAST --\nRemoves previous entry if it matches the last one.\n\n" ..
         "-- ALL --\nRemoves all entries if it matches the last one.",
    ru = "Повторяющиеся записи, которые будут удалены.\n\n" ..
         "-- ПОСЛЕДНИЕ --\nПредпоследняя запись будет удалена, если она совпадает с последней.\n\n" ..
         "-- ВСЕ --\nВсе записи, совпадающие с последней записью, будут удалены.",
  },
  settings_last = {
    en = "Last",
    ru = "Последние",
  },
  settings_all = {
    en = "All",
    ru = "Все",
  },
  chat_history_commands_only = {
    en = "Save only executed commands",
    ru = "Сохранять только выполненные команды",
  },
  chat_history_commands_only_tooltip = {
    en = "Only successfully executed commands will be saved in the chat history.\n\n" ..
         "WARNING: Changing this setting will erase your chat history.",
    ru = "Только успешно выполненные команды будут сохранены в истории ввода.\n\n" ..
         "ВНИМАНИЕ: изменение этой настройки очистит вашу историю ввода.",
  },


  clean_chat_history = {
    en = "cleans chat input history",
    ru = "очищает историю ввода",
  },
  dev_console_opened = {
    en = "Developer console opened.",
    ru = "Консоль разработчика открыта.",
  },
  dev_console_closed = {
    en = "Developer console closed.",
    ru = "Консоль разработчика закрыта.",
  },


  -- MUTATORS


  easy = {
    en = "Easy"
  },
  normal = {
    en = "Normal"
  },
  hard = {
    en = "Hard"
  },
  harder = {
    en = "Nightmare"
  },
  hardest = {
    en = "Cataclysm"
  },
  survival_hard = {
    en = "Veteran"
  },
  survival_harder = {
    en = "Champion"
  },
  survival_hardest = {
    en = "Heroic"
  },

  broadcast_enabled_mutators = {
    en = "ENABLED MUTATORS"
  },
  broadcast_all_disabled = {
    en = "ALL MUTATORS DISABLED"
  },
  broadcast_disabled_mutators = {
    en = "MUTATORS DISABLED"
  },
  local_disabled_mutators = {
    en = "Mutators disabled"
  },
  whisper_enabled_mutators = {
    en = "[Automated message] This lobby has the following mutators active"
  },

  disabled_reason_not_server = {
    en = "because you're no longer the host"
  },
  disabled_reason_difficulty_change = {
    en = "DUE TO CHANGE IN DIFFICULTY"
  },

  mutators_title = {
    en = "Mutators"
  },
  mutators_banner_tooltip = {
    en = "Enable and disable mutators"
  },
  no_mutators = {
    en = "No mutators installed"
  },
  no_mutators_tooltip = {
    en = "Subscribe to mods and mutators on the workshop"
  },

  tooltip_supported_difficulty = {
    en = "Supported difficulty levels"
  },
  tooltip_incompatible_with_all = {
    en = "Incompatible with all other mutators"
  },
  tooltip_incompatible_with = {
    en = "Incompatible with"
  },
  tooltip_compatible_with_all = {
    en = "Compatible with all other mutators"
  },
  tooltip_will_be_disabled = {
    en = "Will be disabled when Play is pressed"
  }
}