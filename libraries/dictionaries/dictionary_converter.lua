


-- The only variables to change for the script to work
local input_file = "words-FR.txt"
local output_file = "words-FR.lua"


local fp = assert(io.open(output_file, "w+"))
fp:write("return {\n")


for line in io.lines(input_file) do
	fp:write("[\"", line:sub(1, -2), "\"]=true,\n")
end

fp:write("}\n")

fp:close()
