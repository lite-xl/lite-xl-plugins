--
-- MessageBox example.
--

local MessageBox = require "libraries.widget.messagebox"

---@type widget.messagebox
local messagebox = MessageBox(
  nil,
  "Multiline",
  {
    "Some multiline message\nTo see how it works."
  }
)
messagebox.size.x = 250
messagebox.size.y = 300

messagebox:add_button("Ok")
messagebox:add_button("Cancel")

messagebox:show()

MessageBox.info(
  "Feeling",
  "Are you feeling well?",
  function(self, button_id, button)
    if button_id == 3 then
      MessageBox.error(
        "Error", {"No response was received!\nNo points for you!"}
      )
    elseif button_id == 2 then
      MessageBox.warning(
        "Warning",
        "We have to do something about that!",
        nil,
        MessageBox.BUTTONS_YES_NO
      )
    elseif button_id == 1 then
      MessageBox.info(
        "Info",
        "We are two now :)"
      )
    end
  end,
  MessageBox.BUTTONS_YES_NO_CANCEL
)

function messagebox:on_close(button_id, button)
  MessageBox.on_close(self, button_id, button)
  self:destroy()
end
