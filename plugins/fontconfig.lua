-- mod-version:1 -- lite-xl 2.00
local subprocess = require "process"

local core = require "core"
local style = require "core.style"
local config = require "core.config"

--[[
    Example config (put it in user module):
    ```
    local fc = require "plugins.fontconfig"
    fc(
        { name = "sans", size = 13 * SCALE },     -- UI font
        { name = "monospace", size = 13 * SCALE } -- code font
    )
    ```
]]

local function resolve_font(spec)
    local scan_rate = 1 / config.fps
    local proc = subprocess.start({ "fc-match", "-s", "-f", "%{file}\n", spec }, {
        stdin = subprocess.REDIRECT_DISCARD,
        stdout = subprocess.REDIRECT_PIPE,
        stderr = subprocess.REDIRECT_STDOUT
    })
    local prev, lines = {}, {}
    while proc:running() do
        coroutine.yield(scan_rate)
        local buf = proc:read_stdout()
        local p, _, n = string.match(buf, "(.+)\n(.+)")
        if p then
            prev[#prev + 1] = p
            lines[#lines + 1] = table.concat(prev, "")
            prev = { n }
        else
            prev[#prev + 1] = buf
        end
    end
    table.insert(lines, table.concat(prev, ""))

    if proc:returncode() ~= 0 or #lines < 1 then
        error(string.format("Cannot find a font matching the given specs: %q", spec), 0)
    end
    -- maybe in the future we can detect and do glyph substitution here...
    return lines[1]
end

local function load_system_fonts(font, code_font)
    core.add_thread(function()
        local font_file = resolve_font(font.name)
        local code_font_file = resolve_font(code_font.name)
        style.font = renderer.font.load(font_file, font.size, font)
        style.code_font = renderer.font.load(code_font_file, code_font.size, code_font)
    end)
end

return load_system_fonts