-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB GUI MODULE
-- GUI templating and event handling

-- dependencies
local event = require('lualib/event')
local util = require('__core__/lualib/util')

-- locals
local table_deepcopy = table.deepcopy
local templates = {}
local handlers = {}
local table_insert = table.insert
local string_split = util.split
local global_data

local function get_subtable(s, t)
  for _,key in pairs(string_split(s, '%.')) do
    t = t[key]
  end
  return t
end

event.on_init(function()
  global.__lualib.gui = {}
  global_data = global.__lualib.gui
end)

event.on_load(function()
  global_data = global.__lualib.gui
  for pi,t in pairs(global_data) do
    for i=1,#t do
      local data = t[i]
      event[data.event:gsub('on_', 'on_gui_')](get_subtable(data.path, handlers), {name=data.element.index..'_'..data.event, gui_filters=data.element.index})
    end
  end
end)

-- recursively load a GUI template
local function recursive_load(parent, t, output, options, parent_index)
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
  -- add element
  local elem = parent.add(elem_t)
  if not parent_index then parent_index = elem.index end
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
  -- register handler(s)
  if t.handlers then
    local index = elem.index
    local pi = options.player_index or error('Must specify a player index for GUI handlers in the options table!')
    local path
    local append_path = false
    if type(t.handlers) == 'string' then
      path = t.handlers
      append_path = true
      t.handlers = get_subtable(t.handlers, handlers)
    end
    for n,func in pairs(t.handlers) do
      local nn = n:gsub('on_', 'on_gui_')
      if type(func) == 'string' then
        path = func
        func = get_subtable(func, handlers)
      end
      event[nn](func, {name=index..'_'..n, player_index=pi, gui_filters=index})
      if not global_data[parent_index] then global_data[parent_index] = {} end
      table_insert(global_data[parent_index], {element=elem, event=n, path=append_path and (path..'.'..n) or path})
    end
  end
  -- add children
  local children = t.children
  if children then
    for i=1,#children do
      output = recursive_load(elem, children[i], output, options, parent_index)
    end
  end
  return output
end

local self = {}

-- load templates object
function self.load_templates(t)
  templates = t
  return self
end

-- load handlers object
function self.load_handlers(t)
  handlers = t
  return self
end

-- creates a GUI from the given template
function self.create(parent, template, options)
  if type(template) == 'string' then
    template = get_subtable(template, templates)
  end
  return recursive_load(parent, template, {}, options)
end

-- deregisters all events belonging to children of this GUI element, then destroys it
function self.destroy(parent, player_index)
  local events = global_data[parent.index]
  if events then
    for i=1,#events do
      local t = events[i]
      event.deregister(defines.events[t.event], get_subtable(t.path, handlers), {name=t.element.index..'_'..t.event, player_index=player_index})
    end
    global_data[parent.index] = nil
  end
  parent.destroy()
end

return self