-- Based on the code from:
-- https://gist.github.com/zr-tex8r/1969061a025fa4fc5486c9c28460f48e

local Object = require "core.object"

--------------------------------------------------------------------------------
-- Class Declarations
--------------------------------------------------------------------------------

---@class widget.fonts.cdata : core.object
---@field private data string
---@field private position integer
local FontCDATA = Object:extend()

---@class  widget.fonts.reader : core.object
---@field private file file*
---@field private path string
local FontReader = Object:extend()

---@class  widget.fonts.data
---@field public path string
---@field public id number @Numerical id of the font
---@field public type '"ttc"' | '"ttf"' | '"otf"'
---@field public copyright string
---@field public family string
---@field public subfamily '"Regular"' | '"Bold"' | '"Italic"' | '"Bold Italic"'
---@field public fullname string
---@field public version string
---@field public psname string
---@field public url string
---@field public license string
---@field public tfamily string
---@field public tsubfamily '"Regular"' | '"Bold"' | '"Italic"' | '"Bold Italic"'
---@field public wwsfamily string
---@field public wwssubfamily string
---@field public monospace boolean

---@class widget.fonts.info : core.object
---@field private reader widget.fonts.reader
---@field public path string @Path of the font file
---@field public data widget.fonts.data[] @Holds the metadata for each of the embedded fonts
local FontInfo = Object:extend()

---@alias widget.fonts.style
---|>'"regular"'
---| '"bold"'
---| '"italic"'
---| '"bold italic"'
---| '"thin"'
---| '"medium"'
---| '"light"'
---| '"black"'
---| '"condensed"'
---| '"oblique"'
---| '"bold oblique"'
---| '"extra nold"'
---| '"Extra bold italic"'
---| '"bold condensed"'

--------------------------------------------------------------------------------
-- FontCDATA Implementation
--------------------------------------------------------------------------------
function FontCDATA:new(data)
  self.data = data
  self.position = 0
end

function FontCDATA:__tostring()
  return "cdata(pos="..self.position..")"
end

function FontCDATA:pos(p)
  if not p then return self.position end
  self.position = p
  return self
end

function FontCDATA:unum(b)
  local v, data = 0, self.data
  assert(#data >= self.position + b, 11)
  for _ = 1, b do
    self.position = self.position + 1
    v = v * 256 + data:byte(self.position)
  end
  return v
end

function FontCDATA:setunum(b, v)
  local t, data = {}, self.data
  t[1] = data:sub(1, self.position)
  self.position = self.position + b
  assert(#data >= self.position, 12)
  t[b + 2] = data:sub(self.position + 1)
  for i = 1, b do
    t[b + 2 - i] = string.char(v % 256)
    v = math.floor(v / 256)
  end
  self.data = table.concat(t, '')
  return self
end

function FontCDATA:str(b)
  local data = self.data
  self.position = self.position + b
  assert(#data >= self.position, 13)
  return data:sub(self.position - b + 1, self.position)
end

function FontCDATA:setstr(s)
  local t, data = {}, self.data
  t[1], t[2] = data:sub(1, self.position), s
  self.position = self.position + #s
  assert(#data >= self.position, 14)
  t[3] = data:sub(self.position + 1)
  self.data = table.concat(t, '')
  return self
end

function FontCDATA:ushort()
  return self:unum(2)
end

function FontCDATA:ulong()
  return self:unum(4)
end

function FontCDATA:setulong(v)
  return self:setunum(4, v)
end

function FontCDATA:ulongs(num)
  local t = {}
  for i = 1, num do
    t[i] = self:unum(4)
  end
  return t
end

--------------------------------------------------------------------------------
-- FontReader Implementation
--------------------------------------------------------------------------------
function FontReader:new(font_path)
  local file, errmsg = io.open(font_path, "rb")
  assert(file, errmsg)
  self.file = file
  self.path = font_path
end

function FontReader:__gc()
  if self.file then
    self.file:close()
  end
end

function FontReader:__tostring()
  return "reader("..self.path..")"
end

---@param offset integer
---@param len integer
---@return widget.fonts.cdata?
---@return string|nil errmsg
function FontReader:cdata(offset, len)
  local data, errmsg = self:read(offset, len)
  if data then
    return FontCDATA(data)
  end
  return nil, errmsg
end

function FontReader:read(offset, len)
  self.file:seek("set", offset)
  local data = self.file:read(len)
  if data:len() ~= len then
    return nil, "failed reading font data"
  end
  return data
end

function FontReader:close()
  self.file:close()
  self.file = nil
end

--------------------------------------------------------------------------------
-- FontInfo Helper Functions
--------------------------------------------------------------------------------
-- speeds up function lookups
local floor, ceil = math.floor, math.ceil

local function div(x, y)
  return floor(x / y), x % y
end

local function utf16betoutf8(src)
  local s, d = { tostring(src):byte(1, -1) }, {}
  for i = 1, #s - 1, 2 do
    local c = s[i] * 256 + s[i+1]
    if c < 0x80 then d[#d+1] = c
    elseif c < 0x800 then
      local x, y = div(c, 0x40)
      d[#d+1] = x + 0xC0; d[#d+1] = y + 0x80
    elseif c < 0x10000 then
      local x, y, z = div(c, 0x1000); y, z = div(y, 0x40)
      d[#d+1] = x + 0xE0; d[#d+1] = y + 0x80; d[#d+1] = z + 0x80
    else
      assert(nil)
    end
  end
  return string.char(table.unpack(d))
end

local file_type = {
  [0x74746366] = 'ttc',
  [0x10000] = 'ttf',
  [0x4F54544F] = 'otf',
  [1008813135] = 'ttc'
}

---@param reader widget.fonts.reader
local function otf_offset(reader)
  local cd, errmsg = reader:cdata(0, 12)
  if not cd then
    return nil, errmsg
  end
  local tag = cd:ulong()
  local ftype = file_type[tag];
  if ftype == 'ttc' then
    local ver = cd:ulong();
    local num = cd:ulong();
    cd, errmsg = reader:cdata(12, 4 * num)
    if not cd then
      return nil, errmsg
    end
    local res = cd:ulongs(num);
    return res
  elseif ftype == 'otf' or ftype == 'ttf' then
    return { 0 }
  else
    return nil, string.format("unknown file tag: %s", tag)
  end
end

---@param reader widget.fonts.reader
---@param fofs integer
---@param ntbl integer
local function otf_name_table(reader, fofs, ntbl)
  local cd_d = reader:cdata(fofs + 12, 16 * ntbl)
  if not cd_d then
    return nil, "error reading names table"
  end
  for _ = 1, ntbl do
    local t = {-- tag, csum, ofs, len
      cd_d:str(4), cd_d:ulong(), cd_d:ulong(), cd_d:ulong()
    }
    if t[1] == 'name' then
      return reader:cdata(t[3], ceil(t[4] / 4) * 4)
    end
  end
  return nil, "name table is missing"
end

---@param cdata widget.fonts.cdata
local function otf_name_records(cdata)
  local nfmt, nnum, nofs = cdata:ushort(), cdata:ushort(), cdata:ushort()
  assert(nfmt == 0, string.format("unsupported name table format: %s", nfmt))
  local nr = {}
  for i = 1, nnum do
    nr[i] = { -- pid, eid, langid, nameid, len, ofs
      cdata:ushort(), cdata:ushort(), cdata:ushort(),
      cdata:ushort(), cdata:ushort(), cdata:ushort() + nofs
    }
  end
  return nr
end

---@param cdata widget.fonts.cdata
local function otf_name(cdata, nr, nameid)
  local function seek(pid, eid, lid)
    for i = 1, #nr do
      local t = nr[i]
      local ok = (t[4] == nameid and t[1] == pid and t[2] == eid and
          t[3] == lid)
      if ok then return t end
    end
  end

  local rec = seek(3, 1, 0x409)
    or seek(3, 10, 0x409)
    or seek(1, 0, 0) or seek(0, 3, 0)
    or seek(0, 4, 0) or seek(0, 6, 0)

  if not rec then return '' end
  local s = cdata:pos(rec[6]):str(rec[5])
  return (rec[1] == 3) and utf16betoutf8(s) or s
end

---@param reader widget.fonts.reader
local function otf_list(reader, fid, fofs)
  local cd_fh, errmsg = reader:cdata(fofs, 12)
  if not cd_fh then
    return nil, errmsg
  end

  local tag = cd_fh:ulong()
  local ntbl = cd_fh:ushort()

  local cd_n = nil
  cd_n, errmsg = otf_name_table(reader, fofs, ntbl)
  if not cd_n then
    return nil, errmsg
  end

  local ext = { id = fid; type = file_type[tag] or '' }

  local nr = nil
  nr, errmsg = otf_name_records(cd_n)
  if not nr then
    return nil, errmsg
  end

  local output = {
    id = ext.id,
    type = ext.type,
    copyright = otf_name(cd_n, nr, 0),
    family = otf_name(cd_n, nr, 1),
    subfamily = otf_name(cd_n, nr, 2),
    fullname = otf_name(cd_n, nr, 4),
    version = otf_name(cd_n, nr, 5),
    psname = otf_name(cd_n, nr, 6),
    url = otf_name(cd_n, nr, 11),
    license = otf_name(cd_n, nr, 13),
    tfamily = otf_name(cd_n, nr, 16),
    tsubfamily = otf_name(cd_n, nr, 17),
  }

  return output
end

--------------------------------------------------------------------------------
-- FontInfo Implementation
--------------------------------------------------------------------------------

---Helper function to check and update a font monospace attribute.
---@param font_data widget.fonts.data
---@return boolean checked
---@return string? errmsg
function FontInfo.check_is_monospace(font_data)
  if font_data then
    local loaded, fontren = pcall(renderer.font.load, font_data.path, 8, {})
    if not loaded then
      return false, "could not load font"
    else
      if fontren:get_width("|") == fontren:get_width("w") then
        font_data.monospace = true
      else
        font_data.monospace = false
      end
    end
  end
  return true
end

---Constructor
---@param font_path? string
function FontInfo:new(font_path)
  if type(font_path) == "string" then
    self:read(font_path)
  else
    self.data = {}
    self.path = ""
    self.last_error = "no font given"
  end
end

local function fontinfo_read_native(self, font_path)
  ---@type widget.fonts.data
  local font
  ---@type string?
  local errmsg

  ---@diagnostic disable-next-line
  font, errmsg = renderer.font.get_metadata(font_path)

  if not font then
    self.last_error = errmsg
    return font, errmsg
  end

  local add = true
  local family = nil
  if font.tfamily then
    family = font.tfamily
  elseif font.family then
    family = font.family
  end

  local subfamily = nil
  if font.tsubfamily then
    subfamily = font.tsubfamily -- sometimes tsubfamily includes more styles
  elseif font.subfamily then
    subfamily = font.subfamily
  end

  -- fix font meta data or discard if empty
  if family and subfamily then
    font.fullname = family .. " " .. subfamily
  elseif font.fullname and family and not font.fullname:ufind(family, 1, true) then
    font.fullname = font.fullname .. " " .. family
  elseif not font.fullname and family then
    font.fullname = family
  else
    self.last_error = "font metadata is empty"
    add = false
  end

  if add then
    table.insert(self.data, font)
  else
    return nil, self.last_error
  end

  return true
end

local function fontinfo_read_nonnative(self, font_path)
  self.reader = FontReader(font_path)

  local tofs, errmsg = otf_offset(self.reader)

  if not tofs then
    self.last_error = errmsg
    return nil, errmsg
  end

  local data = nil
  for i = 1, #tofs do
    data, errmsg = otf_list(self.reader, i - 1, tofs[i])
    if data then
      table.insert(self.data, data)
    else
      self.last_error = errmsg
      return nil, errmsg
    end
  end

  if self.data[1] then
    local font = self.data[1]

    local family = nil
    if font.tfamily ~= "" then
      family = font.tfamily
    elseif font.family ~= "" then
      family = font.family
    end

    local subfamily = nil
    if font.tsubfamily ~= "" then
      subfamily = font.tsubfamily -- sometimes tsubfamily includes more styles
    elseif font.subfamily ~= "" then
      subfamily = font.subfamily
    end

    -- fix font meta data or discard if empty
    if family and subfamily then
      font.fullname = family .. " " .. subfamily
    elseif font.fullname ~= "" and family and not font.fullname:ufind(family, 1, true) then
      font.fullname = font.fullname .. " " .. family
    elseif font.fullname == "" and family then
      font.fullname = family
    else
      self.data = {}
      self.last_error = "font metadata is empty"
      return nil, self.last_error
    end
  end

  self.reader:close()

  return true
end

---Open a font file and read its metadata.
---@param font_path string
---@return widget.fonts.info?
---@return string|nil errmsg
function FontInfo:read(font_path)
  self.data = {}
  self.path = font_path

  local read, errmsg

  ---@diagnostic disable-next-line
  if type(renderer.font.get_metadata) == "function" then
    read, errmsg = fontinfo_read_native(self, font_path)
  else
    read, errmsg = fontinfo_read_nonnative(self, font_path)
  end

  if not read then
    return read, errmsg
  end

  return self
end

---Get the amount of collections on the font file.
---@return integer
function FontInfo:embedded_fonts_count()
  return #self.data
end

---Get the metadata of a previously read font file without
---copyright and license information which can be long.
---@param idx? integer Optional position of the embedded font
---@return widget.fonts.data?
---@return string|nil errmsg
function FontInfo:get_data(idx)
  idx = idx or 1
  local data = {}

  if #self.data > 0 and self.data[idx] then
    data = self.data[idx]
  else
    return nil, self.last_error
  end

  return {
    path         = self.path,
    id           = data.id,
    type         = data.type,
    family       = data.family,
    subfamily    = data.subfamily,
    fullname     = data.fullname,
    version      = data.version,
    psname       = data.psname,
    url          = data.url,
    tfamily      = data.tfamily,
    tsubfamily   = data.tsubfamily,
    wwsfamily    = data.wwsfamily,
    wwssubfamily = data.wwssubfamily,
    monospace    = data.monospace or false
  }
end


return FontInfo
