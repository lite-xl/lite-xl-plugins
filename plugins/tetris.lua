-- mod-version:3

local core = require "core"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"
local View = require "core.view"
local command = require "core.command"
local keymap = require "core.keymap"

local TetrisView = View:extend()

config.plugins.tetris = common.merge({
  tick = 0.5, -- The amount of time in seconds it takes for a piece to fall one line at 0 score.
  height = 30, -- The amount of cells of height.
  width = 10, -- The amount of cells of width.
  cell_size = 12, -- The size in pixels of each cell.
  cell_padding = 2 -- pixels between each cell
}, config.plugins.tetris)

function TetrisView:new(options)
  TetrisView.super.new(self)
  self.cell_size = options.cell_size
  self.cell_padding = options.cell_padding
  self.grid = { x = options.width, y = options.height }
  self.size.x = self.grid.x * (self.cell_size + self.cell_padding) + style.padding.x * 2
  self.cells = { }
  self.score = 0
  self.initial_tick = options.tick
  self.tick = self:calculate_tick(self.score)
  self.finished = false
  self.thread = core.add_thread(function()
    while not self.finished do
      self:step()
      core.redraw = true
      coroutine.yield(self.tick)
    end
  end)
  -- easier to specify rotations than to start doing matrix multiplication
  self.tetronimos = {
    {
      color = { common.color "#ff0000" },
      shape = { {
        1,1,0,0,
        1,1,0,0,
        0,0,0,0,
        0,0,0,0
      } }
    },
    {
      color = { common.color "#00ff00" },
      shape = { {
        1,1,0,0,
        1,0,0,0,
        1,0,0,0,
        0,0,0,0
      }, {
        1,1,1,0,
        0,0,1,0,
        0,0,0,0,
        0,0,0,0
      }, {
        0,0,1,0,
        0,0,1,0,
        0,1,1,0,
        0,0,0,0
      }, {
        0,0,0,0,
        1,0,0,0,
        1,1,1,0,
        0,0,0,0
      } }
    },
    {
      color = { common.color "#0000ff" },
      shape = { {
        1,0,0,0,
        1,0,0,0,
        1,1,0,0,
        0,0,0,0
      }, {
        1,1,1,0,
        1,0,0,0,
        0,0,0,0,
        0,0,0,0
      }, {
        0,1,1,0,
        0,0,1,0,
        0,0,1,0,
        0,0,0,0
      }, {
        0,0,0,0,
        0,0,1,0,
        1,1,1,0,
        0,0,0,0
      } }
    },
    {
      color = { common.color "#00ffff" },
      shape = { {
        1,1,0,0,
        0,1,1,0,
        0,0,0,0,
        0,0,0,0
      }, {
        0,1,0,0,
        1,1,0,0,
        1,0,0,0,
        0,0,0,0
      } }
    },
    {
      color = { common.color "#ffff00" },
      shape = { {
        0,1,1,0,
        1,1,0,0,
        0,0,0,0,
        0,0,0,0
      }, {
        1,0,0,0,
        1,1,0,0,
        0,1,0,0,
        0,0,0,0
      } }
    },
    {
      color = { common.color "#ff00ff" },
      shape = { {
        1,0,0,0,
        1,0,0,0,
        1,0,0,0,
        1,0,0,0
      }, {
        1,1,1,1,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0
      } }
    },
  }
  self.live_piece = nil
end

function TetrisView:calculate_tick(score)
  return self.initial_tick / (math.floor(score / 10) + 1)
end


function TetrisView:does_collide(x, y, tetronimo, rot)
  local shape = tetronimo.shape[rot]
  for i = 0, 3 do
    for j = 0, 3 do
      local ny = y + i
      local nx = x + j
      if (nx >= self.grid.x or ny >= self.grid.y or nx < 0 or ny < 0 or self.cells[self.grid.x * ny + nx + 1]) and shape[i * 4 + j + 1] == 1 then
        return true
      end
    end
  end
  return false
end

function TetrisView:finalize_live_piece()
  assert(self.live_piece)
  local shape = self.live_piece.tetronimo.shape[self.live_piece.rot]
  for i = 0, 3 do
    for j = 0, 3 do
      local ny = self.live_piece.y + i
      local nx = self.live_piece.x + j
      if shape[(i * 4 + j) + 1] == 1 then
        self.cells[ny * self.grid.x + nx + 1] = self.live_piece.idx
      end
    end
  end
  for y = self.live_piece.y, math.min(self.live_piece.y + 4, self.grid.y - 1) do
    local all_present = true
    for x = 0, self.grid.x - 1 do
      if not self.cells[y * self.grid.x + x + 1] then all_present = false end
    end
    if all_present then
      self.score = self.score + 1
      self.tick = self:calculate_tick(self.score)
      for ny = y, 2, -1 do
        for nx = 0, self.grid.x - 1 do
          self.cells[ny * self.grid.x + nx + 1] = self.cells[(ny - 1) * self.grid.x + nx + 1]
        end
      end
    end
  end
  self.live_piece = nil
end


function TetrisView:step()
  if not self.finished then
    if not self.live_piece then
      local idx = self.next_piece or math.floor(math.random() * #self.tetronimos) + 1
      self.live_piece = { tetronimo = self.tetronimos[idx], idx = idx, x = math.floor(self.grid.x / 2), y = 0, rot = 1 }
      self.next_piece = math.floor(math.random() * #self.tetronimos) + 1
      if (self:does_collide(self.live_piece.x, self.live_piece.y + 1, self.live_piece.tetronimo, self.live_piece.rot)) then
        self:finalize_live_piece()
        self.finished = true
      end
    else
      if (self:does_collide(self.live_piece.x, self.live_piece.y + 1, self.live_piece.tetronimo, self.live_piece.rot)) then
        self:finalize_live_piece()
      else
        self.live_piece.y = self.live_piece.y + 1
      end
    end
  end
end

function TetrisView:draw_tetronimo(posx, posy, tetronimo, rot)
  local shape = tetronimo.shape[rot]
  for y = 0, 3 do
    for x = 0, 3 do
      if shape[y * 4 + x + 1] == 1 then
        renderer.draw_rect(posx + x * (self.cell_size + self.cell_padding), posy + y * (self.cell_size + self.cell_padding), self.cell_size, self.cell_size, tetronimo.color)
      end
    end
  end
end

function TetrisView:draw()
  self:draw_background(style.background3)
  local lh = style.font:get_height()
  local tx = self.position.x + style.padding.x
  local ty = self.position.y + style.padding.y

  renderer.draw_text(style.font, "Score: " .. self.score, tx, self.position.y + style.padding.y, style.normal)
  renderer.draw_text(style.font, "Next Piece", tx, self.position.y + style.padding.y + lh, style.normal)
  if self.next_piece then
    self:draw_tetronimo(tx, self.position.y + style.padding.y + lh * 2, self.tetronimos[self.next_piece], 1)
  end
  ty = ty + lh * 2 + (self.cell_size + self.cell_padding) * 4 + style.padding.y

  renderer.draw_rect(tx, ty, (self.cell_size + self.cell_padding) * self.grid.x, (self.cell_size + self.cell_padding) * self.grid.y, style.background)
  for y = 0, self.grid.y - 1 do
    for x = 0, self.grid.x - 1 do
      if self.cells[y * self.grid.x + x + 1] then
        local color = self.tetronimos[self.cells[y * self.grid.x + x + 1]].color
        renderer.draw_rect(tx + x * (self.cell_size + self.cell_padding), ty + y * (self.cell_size + self.cell_padding), self.cell_size, self.cell_size, color)
      end
    end
  end
  if self.live_piece then
    self:draw_tetronimo(tx + self.live_piece.x * (self.cell_size + self.cell_padding), ty + self.live_piece.y * (self.cell_size + self.cell_padding), self.live_piece.tetronimo, self.live_piece.rot)
  end
  if self.finished then
    common.draw_text(style.font, style.error, "GAME OVER", "center", tx, ty, self.grid.x * (self.cell_size + self.cell_padding), self.grid.y * (self.cell_size + self.cell_padding))
  end
end

function TetrisView:rotate()
  if self.live_piece then
    local new_rot = (self.live_piece.rot % #self.live_piece.tetronimo.shape) + 1
    if not self:does_collide(self.live_piece.x, self.live_piece.y, self.live_piece.tetronimo, new_rot) then
      self.live_piece.rot = new_rot
    end
  end
end


function TetrisView:down()
  if self.live_piece then
    for y = self.live_piece.y, self.grid.y do
      if self:does_collide(self.live_piece.x, y + 1, self.live_piece.tetronimo, self.live_piece.rot) then
        self.live_piece.y = y
        self:finalize_live_piece()
        break
      end
    end
  end
end

function TetrisView:shift(delta)
  if self.live_piece and not self:does_collide(self.live_piece.x + delta, self.live_piece.y, self.live_piece.tetronimo, self.live_piece.rot) then
    self.live_piece.x = self.live_piece.x + delta
  end
end

command.add(TetrisView, {
  ["tetris:rotate"] = function() core.active_view:rotate() end,
  ["tetris:shift-left"] = function() core.active_view:shift(-1) end,
  ["tetris:shift-right"] = function() core.active_view:shift(1) end,
  ["tetris:down"] = function() core.active_view:down() end,
  ["tetris:quit"] = function()
    core.active_view.finished = true
    core.active_view.node:close_view(core.root_view.root_node, core.active_view)
  end
})
command.add(nil, {
  ["tetris:start"] = function()
    local view = TetrisView(config.plugins.tetris)
    local node = core.root_view:get_active_node()
    view.node = node:split("right", view, { x = true }, true)
    core.set_active_view(view)
  end
})

keymap.add {
  ["up"] = "tetris:rotate",
  ["left"] = "tetris:shift-left",
  ["right"] = "tetris:shift-right",
  ["down"] = "tetris:down",
  ["escape"] = "tetris:quit",
  ["ctrl+e"] = { "tetris:quit", "tetris:start" }
}
return { view = TetrisView }
