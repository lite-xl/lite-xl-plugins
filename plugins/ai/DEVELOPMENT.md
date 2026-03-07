-- AI Plugin - Development Guide

-- This guide shows how to extend the AI plugin with custom functionality

-- ============================================================================
-- 1. ADDING A NEW AI COMMAND
-- ============================================================================

-- To add a new command, add it to the command.add() block:

--[[
  ["ai:summarize"] = function(dv)
    local text, l1, c1, l2, c2 = get_ai_input(dv, "document")
    if not text or text == "" then
      core.status:show("⚠️ No text to summarize", core.log.WARN)
      return
    end
    
    local prompt = "Provide a concise summary of the following text:\n\n"
    local result = call_ai(text, prompt)
    if result then
      dv.doc:text_input("\n\n-- SUMMARY:\n-- " .. result:gsub("\n", "\n-- "), 1)
    end
  end,
--]]

-- ============================================================================
-- 2. ADDING A NEW API PROVIDER
-- ============================================================================

-- Example: Adding Groq API support

--[[
-- 1. Add config options at the top:
  groq_api_key = "",
  groq_model = "mixtral-8x7b-32768",

-- 2. Add to config_spec:
  {
    label = "Groq API Key",
    description = "Your Groq API key from console.groq.com",
    path = "groq_api_key",
    type = "string",
    default = ""
  },

-- 3. Create the API function:
  local function call_groq(text, system_prompt)
    local cfg = config.plugins.ai
    local api_key = cfg.groq_api_key
    
    if not api_key or api_key == "" then
      return nil, "Groq API key not configured"
    end
    
    local payload = json_encode({
      model = cfg.groq_model,
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
    
    local response = make_request("POST", "https://api.groq.com/openai/v1/chat/completions", headers, payload, cfg.timeout)
    local data = json_decode(response)
    
    if data and data.choices and data.choices[1] and data.choices[1].message then
      return data.choices[1].message.content
    else
      return nil, "Invalid response from Groq API"
    end
  end

-- 4. Update call_ai() function to handle new provider
--]]

-- ============================================================================
-- 3. MODIFYING SYSTEM PROMPTS
-- ============================================================================

-- System prompts guide the AI behavior. Make them more specific for better results:

-- Basic prompt (current):
-- "Complete the following code. Return only the completion, no explanations:"

-- More specific prompt for specific language:
-- "Complete the following Rust code. Return only the completion, no explanations. Use idiomatic Rust conventions:"

-- With context about the project:
-- "Complete the following code for a web server written in Node.js. The codebase uses Express.js and Typescript. Return only the completion:"

-- ============================================================================
-- 4. ADDING LANGUAGE-SPECIFIC HANDLING
-- ============================================================================

--[[
-- Example: Language-aware comments

local function get_comment_syntax(doc_extension)
  local comment_map = {
    lua = "-- ",
    python = "# ",
    javascript = "// ",
    typescript = "// ",
    rust = "// ",
    c = "// ",
    java = "// ",
    go = "// ",
  }
  return comment_map[doc_extension] or "-- "
end

-- Use in commands:
local ext = dv.doc.filename:match("%.(%w+)$") or "txt"
local comment_prefix = get_comment_syntax(ext)

--]]

-- ============================================================================
-- 5. ADDING STREAMING RESPONSES
-- ============================================================================

-- Future enhancement: The API supports 'stream' parameter

--[[
-- For better UX, add streaming responses:

local function call_openai_streaming(text, system_prompt, callback)
  local cfg = config.plugins.ai
  local api_key = os.getenv("OPENAI_API_KEY") or cfg.openai_api_key
  
  local payload = json_encode({
    model = cfg.openai_model,
    messages = {
      { role = "system", content = system_prompt },
      { role = "user", content = text }
    },
    temperature = cfg.temperature,
    max_tokens = cfg.max_tokens,
    stream = true  -- Enable streaming
  })
  
  -- Use curl with --raw to get stream output
  -- Process each chunk and update UI in real-time
end

--]]

-- ============================================================================
-- 6. CACHING RESPONSES
-- ============================================================================

-- To avoid duplicate API calls, implement caching:

--[[
local response_cache = {}

local function get_cached_response(text, prompt)
  local key = hash(text .. prompt)
  return response_cache[key]
end

local function cache_response(text, prompt, response)
  local key = hash(text .. prompt)
  response_cache[key] = response
end

-- Then in call_ai():
  local cached = get_cached_response(text, system_prompt)
  if cached then
    core.status:show("✅ AI: Using cached response", core.log.INFO)
    return cached
  end

--]]

-- ============================================================================
-- 7. ADDING MARKDOWN RENDERING FOR RESPONSES
-- ============================================================================

--[[
-- For better formatting of responses with code blocks:

local function format_markdown_response(response)
  -- Format markdown code blocks properly
  response = response:gsub("```(%w*)\n", "```%1\n")
  return response
end

--]]

-- ============================================================================
-- 8. CONFIGURATION PROFILES
-- ============================================================================

-- Allow users to save/load different configurations:

--[[
local profiles = {
  coding = {
    temperature = 0.3,
    max_tokens = 2000,
    api_provider = "openai"
  },
  creative = {
    temperature = 0.9,
    max_tokens = 4000,
    api_provider = "openai"
  },
  drafting = {
    temperature = 0.7,
    max_tokens = 3000,
    api_provider = "ollama"
  }
}

-- Then add command:
command.add(nil, {
  ["ai:load-profile"] = function()
    -- Show dialog to select profile
  end
})

--]]

-- ============================================================================
-- 9. CONTEXT WINDOW MANAGEMENT
-- ============================================================================

-- For large files, truncate context intelligently:

--[[
local function truncate_for_context(text, max_chars)
  if #text > max_chars then
    -- Keep beginning and end
    local half = max_chars // 2
    local ellipsis = "\n... [content truncated] ...\n"
    return text:sub(1, half) .. ellipsis .. text:sub(-half)
  end
  return text
end

--]]

-- ============================================================================
-- 10. ERROR HANDLING IMPROVEMENTS
-- ============================================================================

-- Implement retry logic for failed requests:

--[[
local function call_ai_with_retry(text, system_prompt, max_retries)
  max_retries = max_retries or 3
  local result, err
  
  for i = 1, max_retries do
    result, err = call_ai(text, system_prompt)
    if result then
      return result
    end
    if i < max_retries then
      core.status:show(string.format("🤖 AI: Retry %d/%d...", i, max_retries), core.log.WARN)
      -- Exponential backoff
      os.execute("sleep " .. math.min(2 ^ i, 30))
    end
  end
  
  return nil, err
end

--]]

-- ============================================================================
-- TESTING TIPS
-- ============================================================================

-- 1. Test with different code samples:
--    - Short snippets (< 10 lines)
--    - Medium code (10-100 lines)
--    - Large code blocks (> 100 lines)

-- 2. Test with different languages:
--    - Dynamically typed (Python, JavaScript)
--    - Statically typed (Java, TypeScript, Rust)
--    - Functional (Lisp, Haskell)

-- 3. Test API providers:
--    - OpenAI with different models
--    - Ollama with different models
--    - Anthropic with different models

-- 4. Performance testing:
--    - Measure response time
--    - Check memory usage
--    - Test with slow network

-- 5. Error scenarios:
--    - No API key configured
--    - Network timeout
--    - API rate limiting
--    - Invalid responses

-- ============================================================================
