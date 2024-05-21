local M = {}

local wezterm = require("wezterm")

---@enum position
local positions = {
  LEFT = 0,
  RIGHT = 1,
}

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
---@param position position
---@param opts { sections: section[], separator: SectionSeparator?, hide_empty_sections: boolean? }
---@return string # The status string. Empty if there are no sections to render.
local function generate_status(position, opts)
  local hide_empty_sections = opts.hide_empty_sections
  local left_sep, right_sep = table.unpack(opts.separator or M.section_separators.ARROW)
  ---@type { section_string: string, foreground: string, background: string }[]
  local section_intermediates = {}
  local status_string = ""

  if hide_empty_sections == nil then
    hide_empty_sections = true
  end

  for _, section in ipairs(opts.sections) do
    local section_string = generate_section_string(section)

    if section_string ~= "" or not hide_empty_sections then
      table.insert(section_intermediates, {
        section_string = section_string,
        foreground = section.foreground,
        background = section.background,
      })
    end
  end

  for i, section_intermediate in ipairs(section_intermediates) do
    local prev_section_intermediate
    local next_section_intermediate

    if 1 < i then
      prev_section_intermediate = section_intermediates[i - 1]
    end
    if i < #opts.sections then
      next_section_intermediate = section_intermediates[i + 1]
    end

    if position == positions.RIGHT then
      local format_items = {}

      if prev_section_intermediate then
        table.insert(format_items, {
          Background = { Color = prev_section_intermediate.background },
        })
      end

      table.insert(format_items, {
        Foreground = { Color = section_intermediate.background },
      })
      table.insert(format_items, { Text = right_sep })

      status_string = status_string .. wezterm.format(format_items)
    end

    status_string = status_string .. section_intermediate.section_string

    if position == positions.LEFT then
      local format_items = {}

      if next_section_intermediate then
        table.insert(format_items, {
          Background = { Color = next_section_intermediate.background },
        })
      end

      table.insert(format_items, {
        Foreground = { Color = section_intermediate.background },
      })
      table.insert(format_items, { Text = left_sep })

      status_string = status_string .. wezterm.format(format_items)
    end
  end

  return status_string
end

---@enum SectionSeparator
M.section_separators = {
  NONE = { "", "" },
  ARROW = { "", "" },
  ROUND = { "", "" },
  SLANT = { "", "" },
  SLANT_REVERSE = { "", "" },
};

-- Generate left status from sections and components defined in opts, and return
-- it as a string.
---@param opts { sections: section[], separator: SectionSeparator, hide_empty_sections: boolean }
---@return string # The status string. Empty if there are no sections to render.
function M.generate_left_status(opts)
  return generate_status(positions.LEFT, opts)
end

-- Generate right status from sections and components defined in opts, and
-- return it as a string.
---@param opts { sections: section[], separator: SectionSeparator, hide_empty_sections: boolean }
---@return string # The status string. Empty if there are no sections to render.
function M.generate_right_status(opts)
  return generate_status(positions.RIGHT, opts)
end

function M.apply_to_config(_, _)
end

return M
