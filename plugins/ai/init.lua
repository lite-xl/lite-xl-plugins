-- mod-version:3
local core = require "core"
local config = require "core.config"
local command = require "core.command"
local keymap = require "core.keymap"
local contextmenu = require "plugins.contextmenu"
local common = require "core.common"
local json = require "plugins.json"

-- Configuration
config.plugins.ai = common.merge({
  enabled = true,
  api_provider = "openai", -- "openai", "ollama", "anthropic", "custom"
  openai_api_key = "",
  openai_model = "gpt-4",
  openai_endpoint = "https://api.openai.com/v1/chat/completions",
  
  ollama_endpoint = "http://localhost:11434/api/generate",
  ollama_model = "llama2",
  
  anthropic_api_key = "",
  anthropic_model = "claude-3-sonnet-20240229",
  
  custom_endpoint = "",
  custom_model = "",
  
  timeout = 30,
  temperature = 0.7,
  max_tokens = 2000,
  
  -- The config specification used by the settings gui
  config_spec = {
    name = "AI Assistant",
    {
      label = "Enable",
      description = "Enable or disable the AI assistant plugin.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "API Provider",
      description = "Choose the LLM service to use.",
      path = "api_provider",
      type = "selection",
      default = "openai",
      values = {
        { text = "OpenAI", value = "openai" },
        { text = "Ollama (Local)", value = "ollama" },
        { text = "Anthropic", value = "anthropic" },
        { text = "Custom Endpoint", value = "custom" }
      }
    },
    {
      label = "OpenAI API Key",
      description = "Your OpenAI API key (leave blank to use env variable OPENAI_API_KEY).",
      path = "openai_api_key",
      type = "string",
      default = ""
    },
    {
      label = "OpenAI Model",
      description = "OpenAI model to use (e.g., gpt-4, gpt-3.5-turbo).",
      path = "openai_model",
      type = "string",
      default = "gpt-4"
    },
    {
      label = "Ollama Endpoint",
      description = "Ollama API endpoint URL.",
      path = "ollama_endpoint",
      type = "string",
      default = "http://localhost:11434/api/generate"
    },
    {
      label = "Ollama Model",
      description = "Ollama model name.",
      path = "ollama_model",
      type = "string",
      default = "llama2"
    },
    {
      label = "Anthropic API Key",
      description = "Your Anthropic API key.",
      path = "anthropic_api_key",
      type = "string",
      default = ""
    },
    {
      label = "Custom Endpoint",
      description = "Custom API endpoint URL.",
      path = "custom_endpoint",
      type = "string",
      default = ""
    },
    {
      label = "Custom Model",
      description = "Model name for custom endpoint.",
      path = "custom_model",
      type = "string",
      default = ""
    },
    {
      label = "Temperature",
      description = "Controls randomness (0-2). Lower = more focused, Higher = more creative.",
      path = "temperature",
      type = "number",
      default = 0.7,
      min = 0,
      max = 2,
      step = 0.1
    },
    {
      label = "Max Tokens",
      description = "Maximum length of AI response.",
      path = "max_tokens",
      type = "number",
      default = 2000,
      min = 100,
      max = 8000,
      step = 100
    },
    {
      label = "Timeout (seconds)",
      description = "Network request timeout.",
      path = "timeout",
      type = "number",
      default = 30,
      min = 5,
      max = 120
    }
  }
}, config.plugins.ai)


-- Helper function to make HTTP requests
local function make_request(method, url, headers, body, timeout)
  local cmd
  local header_args = ""
  
  if headers then
    for key, value in pairs(headers) do
      header_args = header_args .. string.format(' -H "%s: %s"', key, value)
    end
  end
  
  if body then
    cmd = string.format(
      'curl -s -X %s %s --connect-timeout %d -m %d -d \'%s\' "%s"',
      method, header_args, timeout, timeout, 
      body:gsub("'", "'\\''"), url
    )
  else
    cmd = string.format(
      'curl -s -X %s %s --connect-timeout %d -m %d "%s"',
      method, header_args, timeout, timeout, url
    )
  end
  
  local handle = io.popen(cmd)
  local response = handle:read("*a")
  handle:close()
  
  return response
end


-- Helper to JSON encode a table
local function json_encode(tbl)
  local result = {}
  local function encode(val, depth)
    depth = depth or 0
    if depth > 20 then return "null" end
    
    if type(val) == "string" then
      return '"' .. val:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r') .. '"'
    elseif type(val) == "number" then
      return tostring(val)
    elseif type(val) == "boolean" then
      return val and "true" or "false"
    elseif type(val) == "table" then
      if val[1] then
        -- Array
        local items = {}
        for _, item in ipairs(val) do
          table.insert(items, encode(item, depth + 1))
        end
        return "[" .. table.concat(items, ",") .. "]"
      else
        -- Object
        local items = {}
        for k, v in pairs(val) do
          table.insert(items, '"' .. k .. '":' .. encode(v, depth + 1))
        end
        return "{" .. table.concat(items, ",") .. "}"
      end
    else
      return "null"
    end
  end
  return encode(tbl)
end


-- Helper to JSON decode
local function json_decode(str)
  local pos = 1
  local function skip_whitespace()
    while pos <= #str and str:match("^%s", pos) do
      pos = pos + 1
    end
  end
  
  local function parse_value()
    skip_whitespace()
    if pos > #str then return nil end
    
    local char = str:sub(pos, pos)
    if char == '"' then
      pos = pos + 1
      local start = pos
      while pos <= #str and str:sub(pos, pos) ~= '"' do
        if str:sub(pos, pos) == '\\' then pos = pos + 2 else pos = pos + 1 end
      end
      local val = str:sub(start, pos - 1):gsub('\\"', '"'):gsub('\\n', '\n'):gsub('\\r', '\r')
      pos = pos + 1
      return val
    elseif char == '{' then
      pos = pos + 1
      local tbl = {}
      while true do
        skip_whitespace()
        if pos > #str or str:sub(pos, pos) == '}' then break end
        if str:sub(pos, pos) == '"' then
          pos = pos + 1
          local start = pos
          while pos <= #str and str:sub(pos, pos) ~= '"' do pos = pos + 1 end
          local key = str:sub(start, pos - 1)
          pos = pos + 1
          skip_whitespace()
          if str:sub(pos, pos) == ':' then pos = pos + 1 end
          tbl[key] = parse_value()
        end
        skip_whitespace()
        if str:sub(pos, pos) == ',' then pos = pos + 1 end
      end
      if pos <= #str and str:sub(pos, pos) == '}' then pos = pos + 1 end
      return tbl
    elseif char == '[' then
      pos = pos + 1
      local tbl = {}
      while true do
        skip_whitespace()
        if pos > #str or str:sub(pos, pos) == ']' then break end
        table.insert(tbl, parse_value())
        skip_whitespace()
        if str:sub(pos, pos) == ',' then pos = pos + 1 end
      end
      if pos <= #str and str:sub(pos, pos) == ']' then pos = pos + 1 end
      return tbl
    elseif str:sub(pos, pos + 3) == "true" then
      pos = pos + 4
      return true
    elseif str:sub(pos, pos + 4) == "false" then
      pos = pos + 5
      return false
    elseif str:sub(pos, pos + 3) == "null" then
      pos = pos + 4
      return nil
    else
      local start = pos
      while pos <= #str and not str:match("[,%]}", pos) do pos = pos + 1 end
      local numstr = str:sub(start, pos - 1):match("^%-?%d+%.?%d*")
      if numstr then return tonumber(numstr) end
      return nil
    end
  end
  
  return parse_value()
end


-- Function to call OpenAI API
local function call_openai(text, system_prompt)
  local cfg = config.plugins.ai
  local api_key = cfg.openai_api_key ~= "" and cfg.openai_api_key or os.getenv("OPENAI_API_KEY")
  
  if not api_key or api_key == "" then
    return nil, "OpenAI API key not configured. Set OPENAI_API_KEY env var or configure in settings."
  end
  
  local payload = json_encode({
    model = cfg.openai_model,
    messages = {
      { role = "system", content = system_prompt },
      { role = "user", content = text }
    },
    temperature = cfg.temperature,
    max_tokens = cfg.max_tokens
  })
  
  local headers = {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. api_key
  }
  
  local response = make_request("POST", cfg.openai_endpoint, headers, payload, cfg.timeout)
  local data = json_decode(response)
  
  if data and data.choices and data.choices[1] and data.choices[1].message then
    return data.choices[1].message.content
  elseif data and data.error then
    return nil, "OpenAI API error: " .. (data.error.message or "Unknown error")
  else
    return nil, "Invalid response from OpenAI API"
  end
end


-- Function to call Ollama API
local function call_ollama(text, system_prompt)
  local cfg = config.plugins.ai
  
  local payload = json_encode({
    model = cfg.ollama_model,
    prompt = system_prompt .. "\n\n" .. text,
    stream = false,
    num_predict = cfg.max_tokens
  })
  
  local response = make_request("POST", cfg.ollama_endpoint, { ["Content-Type"] = "application/json" }, payload, cfg.timeout)
  local data = json_decode(response)
  
  if data and data.response then
    return data.response
  else
    return nil, "Invalid response from Ollama API"
  end
end


-- Function to call Anthropic API
local function call_anthropic(text, system_prompt)
  local cfg = config.plugins.ai
  local api_key = cfg.anthropic_api_key
  
  if not api_key or api_key == "" then
    return nil, "Anthropic API key not configured. Set in settings."
  end
  
  local payload = json_encode({
    model = cfg.anthropic_model,
    max_tokens = cfg.max_tokens,
    temperature = cfg.temperature,
    system = system_prompt,
    messages = {
      { role = "user", content = text }
    }
  })
  
  local headers = {
    ["Content-Type"] = "application/json",
    ["x-api-key"] = api_key,
    ["anthropic-version"] = "2023-06-01"
  }
  
  local response = make_request("POST", "https://api.anthropic.com/v1/messages", headers, payload, cfg.timeout)
  local data = json_decode(response)
  
  if data and data.content and data.content[1] and data.content[1].text then
    return data.content[1].text
  elseif data and data.error then
    return nil, "Anthropic API error: " .. (data.error.message or "Unknown error")
  else
    return nil, "Invalid response from Anthropic API"
  end
end


-- Function to call custom endpoint
local function call_custom(text, system_prompt)
  local cfg = config.plugins.ai
  
  if not cfg.custom_endpoint or cfg.custom_endpoint == "" then
    return nil, "Custom endpoint not configured"
  end
  
  local payload = json_encode({
    model = cfg.custom_model,
    messages = {
      { role = "system", content = system_prompt },
      { role = "user", content = text }
    },
    temperature = cfg.temperature,
    max_tokens = cfg.max_tokens
  })
  
  local headers = {
    ["Content-Type"] = "application/json"
  }
  
  local response = make_request("POST", cfg.custom_endpoint, headers, payload, cfg.timeout)
  local data = json_decode(response)
  
  -- Try OpenAI-compatible format first
  if data and data.choices and data.choices[1] and data.choices[1].message then
    return data.choices[1].message.content
  elseif data and data.response then
    return data.response
  else
    return nil, "Invalid response from custom endpoint"
  end
end


-- Main function to call AI
local function call_ai(text, system_prompt)
  local cfg = config.plugins.ai
  
  if not cfg.enabled then
    return nil, "AI plugin is disabled"
  end
  
  core.status:show("🤖 AI: processing...", core.log.INFO)
  
  local result, err
  if cfg.api_provider == "openai" then
    result, err = call_openai(text, system_prompt)
  elseif cfg.api_provider == "ollama" then
    result, err = call_ollama(text, system_prompt)
  elseif cfg.api_provider == "anthropic" then
    result, err = call_anthropic(text, system_prompt)
  elseif cfg.api_provider == "custom" then
    result, err = call_custom(text, system_prompt)
  else
    result, err = nil, "Unknown API provider: " .. cfg.api_provider
  end
  
  if result then
    core.status:show("✅ AI: Complete", core.log.INFO)
    return result
  else
    core.status:show("❌ AI Error: " .. (err or "Unknown error"), core.log.ERROR)
    return nil
  end
end


-- Get selected text with scope option
local function get_ai_input(dv, scope)
  local text, line_start, col_start, line_end, col_end
  
  for idx, l1, c1, l2, c2 in dv.doc:get_selections() do
    if scope == "line" then
      -- Get entire current line
      text = dv.doc.lines[l1]
      line_start, col_start = l1, 1
      line_end, col_end = l1, #text + 1
    elseif scope == "selection" then
      -- Get selected text (if any selection)
      if l1 ~= l2 or c1 ~= c2 then
        text = dv.doc:get_text(l1, c1, l2, c2)
        line_start, col_start = l1, c1
        line_end, col_end = l2, c2
      else
        -- No selection, use line
        text = dv.doc.lines[l1]
        line_start, col_start = l1, 1
        line_end, col_end = l1, #text + 1
      end
    else -- "document"
      -- Get entire document
      text = dv.doc:get_text()
      line_start, col_start = 1, 1
      line_end, col_end = #dv.doc.lines, #dv.doc.lines[#dv.doc.lines] + 1
    end
    break
  end
  
  return text, line_start, col_start, line_end, col_end
end


-- Command: AI Completion
command.add("core.docview", {
  ["ai:complete"] = function(dv)
    local text, l1, c1, l2, c2 = get_ai_input(dv, "selection")
    if not text or text == "" then
      core.status:show("⚠️ No text selected", core.log.WARN)
      return
    end
    
    local prompt = "Complete the following code. Return only the completion, no explanations:\n\n"
    local result = call_ai(text, prompt)
    if result then
      dv.doc:text_input(result, 1)
    end
  end,

  ["ai:explain"] = function(dv)
    local text, l1, c1, l2, c2 = get_ai_input(dv, "selection")
    if not text or text == "" then
      core.status:show("⚠️ No text selected", core.log.WARN)
      return
    end
    
    local prompt = "Explain the following code concisely:\n\n"
    local result = call_ai(text, prompt)
    if result then
      -- Insert explanation as comment
      local comment_prefix = "-- "
      local lines = result:split("\n")
      local commented = {}
      for _, line in ipairs(lines) do
        table.insert(commented, comment_prefix .. line)
      end
      dv.doc:text_input("\n" .. table.concat(commented, "\n"), 1)
    end
  end,

  ["ai:generate"] = function(dv)
    core.command_view:enter("AI: Describe what to generate", {
      submit = function(description)
        local prompt = "Generate code for the following requirement. Return only code, no explanations:\n\n"
        local result = call_ai(description, prompt)
        if result then
          dv.doc:text_input(result, 1)
        end
      end
    })
  end,

  ["ai:refactor"] = function(dv)
    local text, l1, c1, l2, c2 = get_ai_input(dv, "selection")
    if not text or text == "" then
      core.status:show("⚠️ No text selected", core.log.WARN)
      return
    end
    
    core.command_view:enter("AI: Describe refactoring goal (or press Enter for auto)", {
      submit = function(goal)
        local prompt = "Refactor the following code to be more efficient and readable."
        if goal and goal ~= "" then
          prompt = prompt .. " Goal: " .. goal
        end
        prompt = prompt .. " Return only the refactored code, no explanations:\n\n"
        
        local result = call_ai(text, prompt)
        if result then
          dv.doc:replace(function(s)
            return s == text and result or s
          end)
        end
      end
    })
  end,

  ["ai:find-bugs"] = function(dv)
    local text, l1, c1, l2, c2 = get_ai_input(dv, "selection")
    if not text or text == "" then
      core.status:show("⚠️ No text selected", core.log.WARN)
      return
    end
    
    local prompt = "Analyze the following code for bugs, issues, and potential improvements. Be concise:\n\n"
    local result = call_ai(text, prompt)
    if result then
      -- Insert bugs analysis as comment
      local comment_prefix = "-- BUG ANALYSIS: "
      local lines = result:split("\n")
      local commented = {}
      table.insert(commented, comment_prefix .. lines[1])
      for i = 2, #lines do
        table.insert(commented, "-- " .. lines[i])
      end
      dv.doc:text_input("\n" .. table.concat(commented, "\n"), 1)
    end
  end,

  ["ai:custom"] = function(dv)
    local text, l1, c1, l2, c2 = get_ai_input(dv, "selection")
    
    core.command_view:enter("AI: Enter your prompt", {
      submit = function(prompt)
        if not text or text == "" then
          local result = call_ai(prompt, "You are a helpful AI coding assistant.")
        else
          local result = call_ai(text, prompt)
        end
        if result then
          dv.doc:text_input(result, 1)
        end
      end
    })
  end,
})


-- Register context menu items
contextmenu:register("core.docview", {
  { text = "AI: Complete",       command = "ai:complete" },
  { text = "AI: Explain",        command = "ai:explain" },
  { text = "AI: Refactor",       command = "ai:refactor" },
  { text = "AI: Find Bugs",      command = "ai:find-bugs" },
  { text = "AI: Generate Code",  command = "ai:generate" },
  { text = "AI: Custom Prompt",  command = "ai:custom" },
})


-- Register keybindings
keymap.add {
  ["ctrl+shift+a"]      = "ai:complete",
  ["ctrl+shift+e"]      = "ai:explain",
  ["ctrl+shift+g"]      = "ai:generate",
  ["ctrl+shift+r"]      = "ai:refactor",
  ["ctrl+shift+b"]      = "ai:find-bugs",
  ["ctrl+shift+p"]      = "ai:custom",
}
