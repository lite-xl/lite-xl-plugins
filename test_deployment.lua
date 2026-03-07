#!/usr/bin/env lua
-- Simple test script to verify AI plugin structure

print("🔍 Testing AI Plugin Deployment...")

-- Check if files exist
local files_to_check = {
    "plugins/ai/init.lua",
    "plugins/ai/README.md",
    "plugins/ai/DEVELOPMENT.md",
    "manifest.json"
}

local all_exist = true
for _, file in ipairs(files_to_check) do
    local f = io.open(file, "r")
    if f then
        print("✅ " .. file .. " exists")
        f:close()
    else
        print("❌ " .. file .. " missing")
        all_exist = false
    end
end

-- Check manifest.json contains AI plugin
local manifest = io.open("manifest.json", "r")
if manifest then
    local content = manifest:read("*all")
    manifest:close()
    if content:find('"id": "ai"') then
        print("✅ AI plugin registered in manifest.json")
    else
        print("❌ AI plugin not found in manifest.json")
        all_exist = false
    end
else
    print("❌ Cannot read manifest.json")
    all_exist = false
end

-- Check plugin structure
local plugin_dir = "plugins/ai/"
local plugin_files = {
    "init.lua",
    "README.md",
    "DEVELOPMENT.md"
}

for _, file in ipairs(plugin_files) do
    local f = io.open(plugin_dir .. file, "r")
    if f then
        local content = f:read("*all")
        f:close()
        print("✅ " .. plugin_dir .. file .. " (" .. #content .. " bytes)")
    else
        print("❌ " .. plugin_dir .. file .. " missing")
        all_exist = false
    end
end

-- Basic syntax check for init.lua
local init_file = io.open("plugins/ai/init.lua", "r")
if init_file then
    local content = init_file:read("*all")
    init_file:close()

    -- Check for required patterns
    local checks = {
        {"mod%-version:3", "mod-version header"},
        {"config.plugins.ai", "config registration"},
        {"command.add", "command registration"},
        {"keymap.add", "keybinding registration"},
        {"call_openai", "OpenAI function"},
        {"call_ollama", "Ollama function"},
        {"call_anthropic", "Anthropic function"}
    }

    for _, check in ipairs(checks) do
        if content:find(check[1]) then
            print("✅ Contains " .. check[2])
        else
            print("❌ Missing " .. check[2])
            all_exist = false
        end
    end
end

print("\n" .. string.rep("=", 50))
if all_exist then
    print("🎉 DEPLOYMENT TEST PASSED!")
    print("✅ All files present and properly structured")
    print("✅ Plugin ready for distribution")
else
    print("❌ DEPLOYMENT TEST FAILED!")
    print("❌ Some files missing or malformed")
end
print(string.rep("=", 50))