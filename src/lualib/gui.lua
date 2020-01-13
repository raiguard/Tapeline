-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB GUI MODULE
-- GUI templating and event handling

-- dependencies
local event = require('lualib.event')
local util = require('__core__.lualib.util')

-- locals
local global_data
local string_gsub = string.gsub
local string_split = util.split
local table_deepcopy = table.deepcopy
local table_insert = table.insert
local table_merge = util.merge

-- settings
local handlers = {}
local templates = {}

-- objects
local self = {}

-- -----------------------------------------------------------------------------
-- LOCAL UTILITIES

local function get_subtable(s, t)
  local o = table_deepcopy(t)
  for _,key in pairs(string_split(s, '%.')) do
    o = o[key]
  end
  return o
end

-- recursively load a GUI template
local function recursive_load(parent, t, output, name, player_index)
  -- load template(s)
  if t.template then
    local template = t.template
    if type(template) == 'string' then
      template = {template}
    end
    for i=1,#template do
      t = util.merge{get_subtable(template[i], templates), t}
    end
  end
  -- format element table
  local elem_t = table_deepcopy(t)
  local style = elem_t.style
  local iterate_style = false
  if style and type(style) == 'table' then
    elem_t.style = style.name
    iterate_style = true
  end
  elem_t.children = nil
  elem_t.handlers = nil
  elem_t.save_as = nil
  -- create element
  local elem = parent.add(elem_t)
  -- set runtime styles
  if iterate_style then
    for k,v in pairs(t.style) do
      if k ~= 'name' then
        elem.style[k] = v
      end
    end
  end
  -- apply modifications
  if t.mods then
    for k,v in pairs(t.mods) do
      elem[k] = v
    end
  end
  -- add to output table
  if t.save_as then
    if type(t.save_as) == 'boolean' then
      t.save_as = t.handlers
    end
    output[t.save_as] = elem
  end
  -- register handlers
  if t.handlers then
    local prefix = name..'.'
    local elem_index = elem.index
    local path
    local append_path
    if type(t.handlers) == 'string' then
      path = prefix..t.handlers
      append_path=true
      t.handlers = get_subtable(prefix..t.handlers, handlers)
    end
    for n,func in pairs(t.handlers) do
      local con_name = elem.index..'_'..n
      local event_name = string_gsub(n, 'on_', 'on_gui_')
      if type(func) == 'string' then
        path = prefix..func
        func = get_subtable(prefix..func, handlers)
      end
      event[event_name](func, {name=con_name, player_index=player_index, gui_filters=elem_index})
      if not global_data[name] then global_data[name] = {} end
      if not global_data[name][player_index] then global_data[name][player_index] = {} end
      table_insert(global_data[name][player_index], {name=con_name, element=elem, path=append_path and (path..'.'..n) or path})
    end
  end
  -- add children
  local children = t.children
  if children then
    for i=1,#children do
      output = recursive_load(elem, children[i], output, name, player_index)
    end
  end
  return output
end

-- -----------------------------------------------------------------------------
-- SETUP

event.on_init(function()
  global.__lualib.gui = {}
  global_data = global.__lualib.gui
end)

event.on_load(function()
  global_data = global.__lualib.gui
  local con_registry = global.__lualib.event
  for _,pl in pairs(global_data) do
    for _,el in pairs(pl) do
      for i=1,#el do
        local t = el[i]
        local registry = con_registry[t.name]
        event.register(registry.id, get_subtable(t.path, handlers), {name=t.name})
      end
      break
    end
  end
end)

-- -----------------------------------------------------------------------------
-- OBJECT

function self.create(parent, name, player_index, template)
  return recursive_load(parent, template, {}, name, player_index)
end

function self.destroy(parent, name, player_index)
  local gui_tables = global_data[name]
  local list = gui_tables[player_index]
  for i=1,#list do
    local t = list[i]
    local func = get_subtable(t.path, handlers)
    event.deregister_conditional(func, {name=t.name, player_index=player_index})
  end
  gui_tables[player_index] = nil
  if table_size(gui_tables) == 0 then
    global_data[name] = nil
  end
  parent.destroy()
end

function self.add_templates(...)
  local arg = {...}
  if #arg == 1 then
    for k,v in pairs(arg[1]) do
      templates[k] = v
    end
  else
    templates[arg[1]] = arg[2]
  end
  return self
end

function self.add_handlers(...)
  local arg = {...}
  if #arg == 1 then
    for k,v in pairs(arg[1]) do
      handlers[k] = v
    end
  else
    handlers[arg[1]] = arg[2]
  end
  return self
end

return self