local M = {}

local wezterm = require("wezterm")

---@alias component (fun(): string?)
---@alias section { components: component[], separator: string?, padding: number?, foreground: string, background: string }

-- Generate a string to render for a section.
---@param section section
---@return string # The section string. Empty if there are no components to render.
local function generate_section_string(section)
  local section_string = ""
  local separator = section.separator or " | "
  local padding_string = (" "):rep(section.padding or 1)

  for i, component in ipairs(section.components) do
    local component_string = component()

    if component_string and component_string ~= "" then
      if i > 1 then
        section_string = section_string .. separator
      end

      section_string = section_string .. component_string
    end
  end

  if section_string == "" then
    return ""
  end

  return wezterm.format({
    { Background = { Color = section.background } },
    { Foreground = { Color = section.foreground } },
    { Text = padding_string },
    { Text = section_string },
    { Text = padding_string },
    "ResetAttributes",
  })
end

-- Generate status from sections and components defined in opts, and return it
-- as a string. This is a helper function for internal use.
---@param opts { sections: section[] }
---@return string # The status string. Empty if there are no sections to render.
local function generate_status(opts)
  local status_string = ""

  for _, section in ipairs(opts.sections) do
    local section_string = generate_section_string(section)

    status_string = status_string .. section_string
  end

  return status_string
end

-- Generate left status from sections and components defined in opts, and return
-- it as a string.
---@param opts { sections: section[] }
---@return string # The status string. Empty if there are no sections to render.
function M.generate_left_status(opts)
  return generate_status(opts)
end

-- Generate right status from sections and components defined in opts, and
-- return it as a string.
---@param opts { sections: section[] }
---@return string # The status string. Empty if there are no sections to render.
function M.generate_right_status(opts)
  return generate_status(opts)
end

function M.apply_to_config(_, _)
end

return M
