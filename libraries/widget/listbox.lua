--
-- ListBox Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local core = require "core"
local style = require "core.style"
local Widget = require "libraries.widget"
local MessageBox = require "libraries.widget.messagebox"

---@class widget.listbox.column
---@field public name string
---@field public width string
---@field public expand boolean
---@field public longest integer

---@alias widget.listbox.drawcol fun(self, row, x, y, font, color, only_calc)
---@alias widget.listbox.filtercb fun(self:widget.listbox, idx:integer, row:widget.listbox.row, data:any):number?

---@alias widget.listbox.row table<integer, renderer.font|widget.fontreference|renderer.color|integer|string|widget.listbox.drawcol>

---@alias widget.listbox.colpos table<integer,integer>

---@class widget.listbox : widget
---@field rows widget.listbox.row[]
---@field private row_data any
---@field private rows_original widget.listbox.row[]
---@field private row_data_original any
---@field private columns widget.listbox.column[]
---@field private positions widget.listbox.colpos[]
---@field private mouse widget.position
---@field private selected_row integer
---@field private hovered_row integer
---@field private largest_row integer
---@field private expand boolean
---@field private visible_rows table<integer, integer>
---@field private visible_rendered boolean
---@field private last_scale integer
---@field private last_offset integer
local ListBox = Widget:extend()

---Indicates on a widget.listbox.row that the end
---of a column was reached.
---@type integer
ListBox.COLEND = 1

---Indicates on a widget.listbox.row that a new line
---follows while still rendering the same column.
---@type integer
ListBox.NEWLINE = 2

---Constructor
---@param parent widget
function ListBox:new(parent)
  ListBox.super.new(self, parent)
  self.type_name = "widget.listbox"
  self.scrollable = true
  self.rows = {}
  self.row_data = {}
  self.rows_original = {}
  self.row_data_original = {}
  self.rows_idx_original = {}
  self.columns = {}
  self.positions = {}
  self.selected_row = 0
  self.hovered_row = 0
  self.largest_row = 0
  self.expand = false
  self.visible_rows = {}
  self.visible_rendered = false
  self.last_scale = 0
  self.last_offset = 0

  self:set_size(200, (self:get_font():get_height() + (style.padding.y*2)) * 3)
end

---Set which rows to show using the specified match string or callback,
---if nil all rows are restored.
---@param match? string | widget.listbox.filtercb
function ListBox:filter(match)
  if (not match or match == "") and #self.rows_original > 0 then
    self:clear()
    for idx, row in ipairs(self.rows_original) do
      self:add_row(row, self.row_data_original[idx])
    end
    self.rows_original = {}
    self.row_data_original = {}
    self.rows_idx_original = {}
    return
  elseif match and match ~= "" then
    self.rows_original = #self.rows_original > 0
      and self.rows_original or self.rows
    self.row_data_original = #self.row_data_original > 0
      and self.row_data_original or self.row_data
    self.rows_idx_original = {}

    self:clear()

    local match_type = type(match)

    local rows = {}
    for idx, row in ipairs(self.rows_original) do
      local score
      if match_type == "function" then
        score = match(self, idx, row, self.row_data_original[idx])
      else
        score = system.fuzzy_match(self:get_row_text(row), match, false)
      end
      if score then
        table.insert(rows, {row, self.row_data_original[idx], score, idx})
      end
    end

    table.sort(rows, function(a, b) return a[3] > b[3] end)

    for _, row in ipairs(rows) do
      self:add_row(row[1], row[2])
      table.insert(self.rows_idx_original, row[4])
    end
  end
end

---If no width is given column will be set to automatically
---expand depending on the longest element
---@param name string
---@param width? number
---@param expand? boolean
function ListBox:add_column(name, width, expand)
  local column = {
    name = name,
    width = width or self:get_font():get_width(name),
    expand = expand and expand or (width and false or true)
  }

  table.insert(self.columns, column)
end

---You can give it a table a la statusview style where you pass elements
---like fonts, colors, ListBox.COLEND, ListBox.NEWLINE and multiline strings.
---@param row widget.listbox.row
---@param data any Associated with the row and given to on_row_click()
function ListBox:add_row(row, data)
  table.insert(self.rows, row)
  table.insert(self.positions, self:get_col_positions(row))

  if type(data) ~= "nil" then
    self.row_data[#self.rows] = data
  end

  -- increase columns width if needed
  if #self.columns > 0 then
    local ridx = #self.rows
    for col, pos in ipairs(self.positions[ridx]) do
      if self.columns[col].expand then
        local w = self:draw_row_range(ridx, row, pos[1], pos[2], 1, 1, true)

        -- store the row with longest column for cheaper calculation
        self.columns[col].width = math.max(self.columns[col].width, w)
        if self.columns[col].width < w then
          self.columns[col].longest = ridx
        end
      end
    end
  end

  -- precalculate the row size and position
  self:calc_row_size_pos(#self.rows)
end

---Calculate a row position and size and store it on the row it
---self on the fields x, y, w, h
---@param ridx integer
function ListBox:calc_row_size_pos(ridx)
  local x = self.border.width
  local y = self.border.width

  if ridx == 1 then
    -- if columns are enabled leave some space to render them
    if #self.columns > 0 then
      y = y + self:get_font():get_height() + style.padding.y
    end
  else
    y = y + self.rows[ridx-1].y + self.rows[ridx-1].h
  end

  self:draw_row(ridx, x, y, true)
end

---Recalculate all row sizes and positions which should be only required
---when lite-xl ui scale changes or a row is removed from the list
function ListBox:recalc_all_rows()
  for ridx, _ in ipairs(self.rows) do
    self:calc_row_size_pos(ridx)
  end
end

---Calculates the scrollable size based on the last row of the list.
---@return number
function ListBox:get_scrollable_size()
  local size = self.size.y
  local rows = #self.rows
  if rows > 0 and self.rows[rows].y then
    size = math.max(size, self.rows[rows].y + self.rows[rows].h)
  end
  return size
end

---Detects the rows that are visible each time the content is scrolled,
---this way the draw function will only process the visible rows.
function ListBox:set_visible_rows()
  local _, oy = self:get_content_offset()
  local h = self.size.y

  -- substract column heading from list height
  local colh = 0
  if #self.columns > 0 then
    colh = self:get_font():get_height() + style.padding.y
    h = h - colh
  end

  -- start from nearest row relative to scroll direction for
  -- better performance on long lists
  local idx, total, step = 1, #self.rows, 1
  if #self.visible_rows > 0 then
    if oy < self.last_offset or not self.visible_rendered then
      idx = self.visible_rows[1]
      self.visible_rendered = true
    else
      idx = self.visible_rows[#self.visible_rows]
      total = 1
      step = -1
    end
  end

  oy = oy - self.position.y

  self.visible_rows = {}
  local first_visible = false
  local height = 0
  for i=idx, total, step do
    local row = self.rows[i]
    if row then
      local top = row.y - colh + row.h + oy
      local visible = false
      local visible_area = h - top
      if top < 0 and (top + row.h) > 0 then
        visible = true
      elseif top >= 0 and top < h then
        visible = true
      end
      if visible and height <= h then
        table.insert(self.visible_rows, i)
        first_visible = true
        -- store only the visible height
        if top < 0 then
          height = height + (top + row.h)
        else
          if visible_area > row.h then
            height = height + row.h
          else
            height = height + visible_area
          end
        end
      elseif first_visible then
        table.insert(self.visible_rows, i)
        break
      end
    end
  end

  -- append one more row if possible to fill possible empty spaces of
  -- incomplete row height calculation above (bad math skills workarounds)
  local last_row = self.visible_rows[#self.visible_rows]
  local first_row = self.visible_rows[1]
  if #self.visible_rows > 0 then
    if step == 1 then
      if self.rows[last_row+1] then
        table.insert(self.visible_rows, last_row+1)
      end
    else
      if self.rows[first_row-2] and first_row-2 ~= 1 then
        table.insert(self.visible_rows, first_row-2)
      elseif self.rows[last_row+1] then
        table.insert(self.visible_rows, last_row+1)
      end

      -- sort for proper subsequent loop interations
      table.sort(
        self.visible_rows,
        function(val1, val2) return val1 < val2 end
      )

      local frow = self.visible_rows[1]
      for i, _ in ipairs(self.visible_rows) do
        if self.rows[frow] then
          self.visible_rows[i] = frow
          frow = frow + 1
        end
      end
      if #self.visible_rows > 1 then
        if
          self.visible_rows[#self.visible_rows]
          ==
          self.visible_rows[#self.visible_rows-1]
        then
          table.remove(self.visible_rows, #self.visible_rows)
        end
      end
    end
  end
end

-- Solution to safely remove elements from array table:
-- found at https://stackoverflow.com/a/53038524
local function array_remove(t, fnKeep)
  local j, n = 1, #t;

  for i=1, n do
    if (fnKeep(t, i, j)) then
      if (i ~= j) then
        t[j] = t[i];
        t[i] = nil;
      end
      j = j + 1;
    else
      t[i] = nil;
    end
  end

  return t;
end

---Remove a given row index from the list.
---@param ridx integer
function ListBox:remove_row(ridx)
  if not self.rows[ridx] then return end

  if #self.rows_idx_original > 0 then
    MessageBox.error(
      "Can not remove row",
      "Rows can not be removed when the list is filtered."
    )
    return
  end

  local last_col = false
  local row_y = self.rows[ridx].y
  local row_h = self.rows[ridx].h
  if ridx == #self.rows then
    last_col = true
  end

  local fields = { "rows", "positions", "row_data" }
  for _, field in ipairs(fields) do
    array_remove(self[field], function(_, i, _)
      if i == ridx then
        return false
      end
      return true
    end)
  end
  for _, col in ipairs(self.columns) do
    if col.longest == ridx then
      col.longest = nil
    end
  end

  if not last_col and #self.rows > 0 then
    for idx=ridx, #self.rows, 1 do
      self.rows[idx].y = self.rows[idx].y - row_h
    end
  end

  local visible_removed = false
  array_remove(self.visible_rows, function(t, i, _)
    if t[i] == ridx then
      visible_removed = true
      return false
    end
    return true
  end)

  -- make visible rows sequence correctly incremental
  if visible_removed and #self.visible_rows > 0 then
    local first_row = self.visible_rows[1]
    for i, _ in ipairs(self.visible_rows) do
      self.visible_rows[i] = first_row
      first_row = first_row + 1
    end
    self:set_visible_rows()
  end
end

---Set the row that is currently active/selected.
---@param idx? integer
function ListBox:set_selected(idx)
  self.selected_row = idx or 0
end

---Get the row that is currently active/selected.
---@return integer | nil
function ListBox:get_selected()
  if self.selected_row > 0 then
    return self.selected_row
  end
  return nil
end

---Change the content assigned to a row.
---@param idx integer
---@param row widget.listbox.row
function ListBox:set_row(idx, row)
  --TODO: recalculate subsequent row sizes and max col width if needed
  if self.rows[idx] then
    self.rows[idx] = row
    if #self.rows_idx_original > 0 then
      self.rows_original[self.rows_idx_original[idx]] = row
    end
    -- precalculate the row size and position
    self:calc_row_size_pos(idx)
  end
end

---Change the data assigned to a row.
---@param idx integer
---@param data any|nil
function ListBox:set_row_data(idx, data)
  if self.rows[idx] then
    self.row_data[idx] = data
    if #self.rows_idx_original > 0 then
      self.row_data_original[self.rows_idx_original[idx]] = data
    end
  end
end

---Get the data associated with a row.
---@param idx integer
---@return any|nil
function ListBox:get_row_data(idx)
  if type(self.row_data[idx]) ~= "nil" then
    return self.row_data[idx]
  end
  return nil
end

---Get the text only of a styled row.
---@param row integer | table
---@return string
function ListBox:get_row_text(row)
  local text = ""
  row = type(row) == "table" and row or self.rows[row]
  if row then
    for _, element in ipairs(row) do
      if type(element) == "string" then
        text = text .. element
      elseif element == ListBox.NEWLINE then
        text = text .. "\n"
      end
    end
  end
  return text
end

---Get the starting and ending position of columns in a row table.
---@param row widget.listbox.row
---@return widget.listbox.colpos
function ListBox:get_col_positions(row)
  local positions = {}
  local idx = 1
  local idx_start = 1
  local row_len = #row

  for _, element in ipairs(row) do
    if element == ListBox.COLEND then
      table.insert(positions, { idx_start, idx-1 })
      idx_start = idx + 1
    elseif idx == row_len then
      table.insert(positions, { idx_start, idx })
    end
    idx = idx + 1
  end

  return positions
end

---Move a row to the desired position if possible.
---@param idx integer
---@param pos integer
---@return boolean moved
function ListBox:move_row_to(idx, pos)
  if idx == pos or (pos == #self.rows and #self.rows == 1) then return false end

  if pos < 1 then pos = 1 end

  local row = table.remove(self.rows, idx)
  local position = table.remove(self.positions, idx)

  if pos <= #self.rows then
    table.insert(self.rows, pos, row)
    table.insert(self.positions, pos, position)
  else
    table.insert(self.rows, row)
    table.insert(self.positions, position)
    pos = #self.rows
  end

  local moved_row_data = self.row_data[idx]
  local swapped_row_data = self.row_data[pos]
  self.row_data[idx] = swapped_row_data
  self.row_data[pos] = moved_row_data

  self.selected_row = pos

  self:recalc_all_rows()
  self:set_visible_rows()

  return true
end

---Move a row one position up if possible.
---@param idx integer
---@return boolean moved
function ListBox:move_row_up(idx)
  return self:move_row_to(idx, idx-1)
end

---Move a row one position down if possible.
---@param idx integer
---@return boolean moved
function ListBox:move_row_down(idx)
  self:move_row_to(idx, idx+1)
end

---Enables expanding the element to total size of parent on content updates.
function ListBox:enable_expand(expand)
  self.expand = expand
  if expand then
    self:resize_to_parent()
  end
end

---Resizes the listbox to match the parent size
function ListBox:resize_to_parent()
  self.size.x = self.parent.size.x
    - (self.border.width * 2)

  self.size.y = self.parent.size.y
    - (self.border.width * 2)

  self:set_visible_rows()
end

---Remove all the rows from the listbox.
function ListBox:clear()
  self.rows = {}
  self.row_data = {}
  self.positions = {}
  self.selected_row = 0
  self.hovered_row = 0

  for cidx, col in ipairs(self.columns) do
    col.width = self:get_col_width(cidx)
    col.longest = nil
  end

  self:set_visible_rows()
end

---Render or calculate the size of the specified range of elements in a row.
---@param ridx integer
---@param row widget.listbox.row
---@param start_idx integer
---@param end_idx integer
---@param x integer
---@param y integer
---@param only_calc boolean
---@return integer width
---@return integer height
function ListBox:draw_row_range(ridx, row, start_idx, end_idx, x, y, only_calc)
  local font = self:get_font()
  local color = self.foreground_color or style.text
  local width = 0
  local height = font:get_height()
  local new_line = false
  local nx = x

  for pos=start_idx, end_idx, 1 do
    local element = row[pos]
    local ele_type = type(element)
    if
      ele_type == "userdata"
      or
      (
        ele_type == "table"
        and
        (element.container or type(element[1]) == "userdata")
      )
    then
      if ele_type == "table" and element.container then
        font = element.container[element.name]
      else
        font = element
      end
    elseif ele_type == "table" then
      color = element
    elseif element == ListBox.NEWLINE then
      y = y + font:get_height()
      nx = x
      new_line = true
    elseif ele_type == "function" then
      local w, h = element(self, ridx, nx, y, font, color, only_calc)
      nx = nx + width
      height = math.max(height, h)
      width = width + w
    elseif ele_type == "string" then
      local rx, ry, w, h = self:draw_text_multiline(
        font, element, nx, y, color, only_calc
      )
      y = ry
      nx = rx
      if new_line then
        height = height + h
        width = math.max(width, w)
        new_line = false
      else
        height = math.max(height, h)
        width = width + w
      end
    end
  end

  return width, height
end

---Calculate the overall width of a column.
---@param col integer
---@return number
function ListBox:get_col_width(col)
  if self.columns[col] then
    if not self.columns[col].expand then
      return self.columns[col].width
    else
      -- if longest is available don't iterate the entire row list
      if self.columns[col].longest then
        local id = self.columns[col].longest
        local width = self:draw_row_range(
          id,
          self.rows[id],
          self.positions[id][col][1],
          self.positions[id][col][2],
          1,
          1,
          true
        )
        return width
      end

      local width = self:get_font():get_width(self.columns[col].name)
      for id, row in ipairs(self.rows) do
        local w, h = self:draw_row_range(
          id,
          row,
          self.positions[id][col][1],
          self.positions[id][col][2],
          1,
          1,
          true
        )
        width = math.max(width, w)
      end
      return width
    end
  end
  return 0
end

---Draw the column headers of the list if available
---@param w integer
---@param h integer
function ListBox:draw_header(w, h)
  local x = self.position.x
  local y = self.position.y
  renderer.draw_rect(x, y, w, h, style.background2)
  for _, col in ipairs(self.columns) do
    renderer.draw_text(
      self:get_font(),
      col.name,
      x + style.padding.x / 2,
      y + style.padding.y / 2,
      style.accent
    )
    x = x + col.width + style.padding.x
  end
end

---Draw or calculate the dimensions of the given row position and stores
---the size and position on the row it self.
---@param row integer
---@param x integer
---@param y integer
---@param only_calc? boolean
---@return integer width
---@return integer height
function ListBox:draw_row(row, x, y, only_calc)
  local w, h = 0, 0

  if not only_calc and self.rows[row].w then
    w, h = self.rows[row].w, self.rows[row].h
    w = self.largest_row > 0 and self.largest_row or w

    if self.selected_row == row then
      renderer.draw_rect(x, y, w, h, style.selection)
    end

    local mouse = self.mouse
    if
      mouse.x >= x
      and
      mouse.x <= x + w
      and
      mouse.y >= y
      and
      mouse.y <= y + h
    then
      renderer.draw_rect(x, y, w, h, style.line_highlight)
      self.hovered_row = row
    end
    w, h = 0, 0
  end

  -- add padding on top
  y = y + (style.padding.y / 2)

  if #self.columns > 0 then
    for col, coldata in ipairs(self.columns) do
      -- padding on left
      w = w + style.padding.x / 2
      local cw, ch = self:draw_row_range(
        row,
        self.rows[row],
        self.positions[row][col][1],
        self.positions[row][col][2],
        x + w,
        y,
        only_calc
      )
      -- add column width and end with padding on right
      w = w + coldata.width + (style.padding.x / 2)
      -- only store column height if bigger than previous one
      h = math.max(h, ch)
    end
  else
    local cw, ch = self:draw_row_range(
      row,
      self.rows[row],
      1,
      #self.rows[row],
      x + style.padding.x / 2,
      y,
      only_calc
    )
    h = ch
    w = cw + style.padding.x
  end

  -- Add padding on top and bottom
  h = h + style.padding.y

  if only_calc or not self.rows[row].w then
    -- store the dimensions for inexpensive subsequent hover calculation
    self.rows[row].w = w
    self.rows[row].h = h

    -- TODO: performance improvement, render only the visible rows on the view?
    self.rows[row].x = x
    self.rows[row].y = y - (style.padding.y / 2)
  end

  -- return height with padding on top and bottom
  return w, h
end

---
--- Events
---

function ListBox:on_mouse_leave(x, y, dx, dy)
  ListBox.super.on_mouse_leave(self, x, y, dx, dy)
  self.hovered_row = 0
end

function ListBox:on_mouse_moved(x, y, dx, dy)
  ListBox.super.on_mouse_moved(self, x, y, dx, dy)
  self.hovered_row = 0
end

function ListBox:on_click(button, x, y)
  if button == "left" and self.hovered_row > 0 then
    self.selected_row = self.hovered_row
    self:on_row_click(self.hovered_row, self.row_data[self.hovered_row])
  end
end

---You can overwrite this to listen to item clicks
---@param idx integer
---@param data any Data associated with the row
function ListBox:on_row_click(idx, data) end

function ListBox:update()
  if not ListBox.super.update(self) then return false end

  -- only calculate columns width on scale change since this can be expensive
  if self.last_scale ~= SCALE then
    if #self.columns > 0 then
      for col, column in ipairs(self.columns) do
        column.width = self:get_col_width(col)
      end
    end
    self:recalc_all_rows()
    self.last_scale = SCALE
  end

  local _, oy = self:get_content_offset()
  if self.last_offset ~= oy then
    self:set_visible_rows()
    self.last_offset = oy
  end

  return true
end

function ListBox:draw()
  if not ListBox.super.draw(self) then return false end

  if #self.rows > 0 and #self.visible_rows <= 0 then
    self:set_visible_rows()
  end

  local new_width = 0
  local new_height = 0
  local font = self:get_font()

  if #self.columns > 0 then
    new_height = new_height + font:get_height() + style.padding.y
    for _, col in ipairs(self.columns) do
      new_width = new_width + col.width + style.padding.x
    end
  end

  if self.expand then
    self:resize_to_parent()

    self.largest_row = self.size.x
      - (self.parent.border.width * 2)
  end

  -- Normalize the offset position
  local _, opy = self.parent:get_content_offset()
  local _, oy = self:get_content_offset()
  oy = oy - opy
  if #self.visible_rows > 0 then
    oy = oy + (self.rows[self.visible_rows[1]].y - new_height)
  end
  oy = oy - (self.position.y - self.parent.position.y)

  local x = self.position.x + self.border.width
  local y = oy + self.position.y + self.border.width + new_height

  core.push_clip_rect(
    self.position.x, self.position.y, self.size.x, self.size.y
  )
  for _, ridx in ipairs(self.visible_rows) do
    if self.rows[ridx] then
      local w, h = self:draw_row(ridx, x, y)
      new_width = math.max(new_width, w)
      new_height = new_height + h
      y = y + h
    end
  end
  core.pop_clip_rect()

  if not self.expand then
    self.largest_row = math.max(new_width, self:get_width() - (self.border.width*2))
    self.size.x = self.largest_row
  end

  if #self.columns > 0 then
    self:draw_header(
      self.largest_row,
      font:get_height() + style.padding.y
    )
  end

  self:draw_border()
  self:draw_scrollbar()

  return true
end


return ListBox
