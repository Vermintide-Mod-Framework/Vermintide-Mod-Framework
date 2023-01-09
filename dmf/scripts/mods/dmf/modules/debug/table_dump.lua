local dmf = get_mod("DMF") -- @TODO: remove it?

-- Local backup of the io library
local _io = dmf:persistent_table("_io")
_io.initialized = _io.initialized or false
if not _io.initialized then
  _io = dmf.deepcopy(Mods.lua.io)
end

-- Local backup of the io library
local _os = dmf:persistent_table("_os")
_os.initialized = _os.initialized or false
if not _os.initialized then
  _os = dmf.deepcopy(Mods.lua.os)
end

-- Global backup of original print() method
local print = __print

local function table_dump(key, value, depth, max_depth)
  if max_depth < depth then
    return
  end

  local prefix = string.rep("  ", depth) .. ((key == nil and "") or "[" .. tostring(key) .. "]")
  local value_type = type(value)

  if value_type == "table" then
    prefix = prefix .. ((key == nil and "") or " = ")

    print(prefix .. "table")

    for key_, value_ in pairs(value) do
      table_dump(key_, value_, depth + 1, max_depth)
    end

    local meta = getmetatable(value)

    if meta then
      if type(meta) == "boolean" then
        print(prefix .. "protected metatable")
      else
        print(prefix .. "metatable")
        for key_, value_ in pairs(meta) do
          if key_ ~= "__index" and key_ ~= "super" then
            table_dump(key_, value_, depth + 1, max_depth)
          end
        end
      end
    end
  elseif value_type == "function" or value_type == "thread" or value_type == "userdata" or value == nil then
    print(prefix .. " = " .. tostring(value))
  else
    print(prefix .. " = " .. tostring(value) .. " (" .. value_type .. ")")
  end
end

DMFMod.dump = function (self, dumped_object, dumped_object_name, max_depth)

  if dmf.check_wrong_argument_type(self, "dump", "dumped_object_name", dumped_object_name, "string", "nil") or
     dmf.check_wrong_argument_type(self, "dump", "max_depth", max_depth, "number")
  then
    return
  end

  local object_type = type(dumped_object)

  if object_type ~= "table" then
    local error_message = "(dump): \"object_name\" is not a table. It's " .. object_type

    if object_type ~= "nil" then
      error_message = error_message .. " (" .. tostring(dumped_object) .. ")"
    end

    self:error(error_message)
    return
  end

  if dumped_object_name then
    print(string.format("<%s>", dumped_object_name))
  end

  if not max_depth then
    self:error("(dump): maximum depth is not specified")
    return
  end

  local success, error_message = pcall(function()
    for key, value in pairs(dumped_object) do
      table_dump(key, value, 0, max_depth)
    end
  end)

  if not success then
    self:error("(dump): %s", tostring(error_message))
  end

  if dumped_object_name then
    print(string.format("</%s>", dumped_object_name))
  end
end







local function table_dump_to_file(dumped_table, dumped_table_name, max_depth)

  -- #####################
  -- ##     Parsing     ##
  -- #####################

  -- All tables which needs to be parsed will be put in here (their references).
  local parsing_queue = {}

  -- Special entry is created for every table added to 'parsing_queue'. It will contain parsed contents
  -- of the table in the text form and other 'reached_tables' entries (plus some extra info)
  local reached_tables = {}

  -- This variable will contain the reference to the top 'reached_tables' entry
  local parsed_tree


  parsing_queue[1] = {}
  table.insert(parsing_queue[1], dumped_table)


  local system_table_name = tostring(dumped_table)
  local new_table_entry = {
    false,                    -- 'true' if parser will come across this table again
    system_table_name:sub(8), -- table identifier, will be shown in json if previous value is 'true'
    {},                       -- all things which are stored inside the parsed table will be put in here
    nil                       -- if table has metatable, {} will be created and it will be parsed as well
  }
  reached_tables[system_table_name] = new_table_entry
  parsed_tree                       = new_table_entry


  -- some temporary variables for speeding things up
  local current_entry
  local value_type
  local reached_table
  local parsed_metatable


  -- parsing
  for i = 1, max_depth do

    -- the parser is not reached the max_level but there's nothing more to parse
    if #parsing_queue[i] == 0 then
      break
    end

    local allow_pushing_new_entries = i < max_depth
    if allow_pushing_new_entries then
      parsing_queue[i + 1] = {}
    end

    local function parse_table(table_entry, parsed_table)

      for key, value in pairs(parsed_table) do

        if key ~= "__index" then

          -- key can be the table and the userdata. Unfortunately JSON does not support table keys
          key = tostring(key):gsub('\\','\\\\'):gsub('\"','\\\"'):gsub('\t','\\t'):gsub('\n','\\n')

          value_type = type(value)

          if value_type == "table" then

            if allow_pushing_new_entries then

              system_table_name = tostring(value)

              reached_table = reached_tables[system_table_name]
              if reached_table then

                reached_table[1] = true
                table_entry[key] = "(table)(" .. system_table_name:sub(8) .. ")"
              else

                new_table_entry = {
                  false,
                  system_table_name:sub(8),
                  {},
                  nil
                }

                reached_tables[system_table_name] = new_table_entry

                table_entry[key] = new_table_entry

                table.insert(parsing_queue[i + 1], value)
              end

            else
              table_entry[key] = "(table)"
            end

          elseif value_type == "function" or value_type == "thread" then

            table_entry[key] = "[" .. value_type .. "]"
          else

            value = tostring(value):gsub('\\','\\\\'):gsub('\"','\\\"'):gsub('\t','\\t'):gsub('\n','\\n')
            table_entry[key] = value .. " (" .. value_type .. ")"
          end
        end
      end
    end

    -- parsing all the tables in 'parsing_queue' for the current depth level
    for _, parsed_table in pairs(parsing_queue[i]) do

      current_entry = reached_tables[tostring(parsed_table)]

      -- table

      parse_table(current_entry[3], parsed_table)

      -- metatable

      parsed_metatable = getmetatable(parsed_table)

      if parsed_metatable and type(parsed_metatable) == "table" then

        current_entry[4] = {}

        parse_table(current_entry[4], parsed_metatable)
      end
    end
  end

  -- ####################
  -- ## Saving to file ##
  -- ####################

  _os.execute("mkdir dump 2>nul")
  local file = assert(_io.open("./dump/" .. dumped_table_name .. ".json", "w+"))

  local function dump_to_file(table_entry, table_name, depth)

    local print_string = nil

    local prefix = string.rep('  ', depth)

    -- if table was reached more than once, add its system identifier to its name
    if table_entry[1] then
      file:write(prefix .. '"' .. table_name .. ' (' .. table_entry[2] .. ')": {\n')
    else
      file:write(prefix .. '"' .. table_name .. '": {\n')
    end

    -- if table has metatable
    if table_entry[4] then

      local prefix2 = prefix .. '  '
      local prefix3 = prefix2 .. '  "'

      -- TABLE

      file:write(prefix2 .. '"table": {\n')

      for key, value in pairs(table_entry[3]) do

        if print_string then
          file:write(print_string .. ',\n')
        end

        if type(value) == "table" then
          dump_to_file(value, key, depth + 2)
          print_string = prefix2 .. '  }'
        else
          print_string = prefix3 .. key .. '": "' .. value .. '"'
        end
      end

      if print_string then
        file:write(print_string .. '\n')
        print_string = nil
      end

      file:write(prefix2 .. '},\n')

      -- METATABLE

      file:write(prefix2 .. '"metatable": {\n')

      for key, value in pairs(table_entry[4]) do

        if print_string then
          file:write(print_string .. ',\n')
        end

        if type(value) == "table" then
          dump_to_file(value, key, depth + 2)
          print_string = prefix2 .. '  }'
        else
          print_string = prefix3 .. key .. '": "' .. value .. '"'
        end
      end

      if print_string then
        file:write(print_string .. '\n')
      end

      file:write(prefix2 .. '}\n')

    else

      local prefix2 = prefix .. '  "'

      for key, value in pairs(table_entry[3]) do

        if print_string then
          file:write(print_string .. ',\n')
        end

        if type(value) == "table" then
          dump_to_file(value, key, depth + 1)
          print_string = prefix .. '  }'
        else
          print_string = prefix2 .. key .. '": "' .. value .. '"'
        end
      end

      if print_string then
        file:write(print_string .. '\n')
      end
    end
  end

  -- dumping parsed info to the file
  file:write('{\n')
  dump_to_file (parsed_tree, dumped_table_name, 1)
  file:write('  }\n')
  file:write('}\n')
  file:close()
end


DMFMod.dump_to_file = function (self, dumped_object, object_name, max_depth)

  if dmf.check_wrong_argument_type(self, "dump_to_file", "object_name", object_name, "string") or
     dmf.check_wrong_argument_type(self, "dump_to_file", "max_depth", max_depth, "number")
  then
    return
  end

  local object_type = type(dumped_object)

  if object_type ~= "table" then
    local error_message = "(dump_to_file): \"object_name\" is not a table. It's " .. object_type

    if object_type ~= "nil" then
      error_message = error_message .. " (" .. tostring(dumped_object) .. ")"
    end

    self:error(error_message)
    return
  end

  local success, error_message = pcall(function() table_dump_to_file(dumped_object, object_name, max_depth) end)
  if not success then
    self:error("(dump_to_file): %s", tostring(error_message))
  end
end

DMFMod.dtf = DMFMod.dump_to_file

-- Managers.curl._requests crashes the game
