# wez-status-generator

<img src="https://raw.githubusercontent.com/sei40kr/wez-status-generator/main/img/screenshot.png" width="960" height="640" alt="screenshot">

## Breaking changes

- The `separators` enum has been renamed to `section_separators`.

## Installation

Clone this repository to your `$XDG_CONFIG_HOME/wezterm`:

```sh
git clone https://github.com/sei40kr/wez-status-generator.git $XDG_CONFIG_HOME/wezterm
```

## Usage

```lua
-- Recommended configuration:
config.use_fancy_tab_bar = false

wezterm.on("update-status", function(window, pane)
    local status_generator = require("wez-status-generator.plugin")
    local status = status_generator.generate_left_status({
        sections = {
            {
                components = {
                    function() return window:mux_window():get_workspace() end,
                },
                foreground = "#15161e",
                background = "#7aa2f7",
            },
            {
                components = {
                    function() return os.getenv("USER") end,
                },
                foreground = "#7aa2f7",
                background = "#3b4261",
            },
            {
                components = {
                    function()
                        local tab_id = window:mux_window():active_tab():tab_id()
                        local pane_id = pane:pane_id()

                        return tab_id .. ":" .. pane_id
                    end,
                },
                foreground = "#a9b1d6",
                background = "#16161e",
            },
        },
        separator = status_generator.section_separators.ARROW,
        hide_empty_sections = true,
    })

    window:set_left_status(status)
end)
```

```lua
-- Recommended configuration:
config.use_fancy_tab_bar = false

wezterm.on("update-status", function(window, pane)
    local status_generator = require("wez-status-generator.plugin")
    local status = status_generator.generate_right_status({
        sections = {
            {
                components = {
                    function() return wezterm.strftime("%H:%M:%S") end,
                },
                foreground = "#a9b1d6",
                background = "#16161e",
            },
            {
                components = {
                    function() return wezterm.strftime("%d-%b-%y") end,
                },
                foreground = "#7aa2f7",
                background = "#3b4261",
            },
            {
                components = {
                    function() return wezterm.hostname() end,
                },
                foreground = "#15161e",
                background = "#7aa2f7",
            },
        },
        separator = status_generator.section_separators.ARROW,
        hide_empty_sections = true,
    })

    window:set_right_status(status)
end)
```

## API References

### `generate_left_status`, `generate_right_status`

Generate a status for the left or right side of the window. Expected to be
called from the [update-status](https://wezfurlong.org/wezterm/config/lua/window-events/update-status.html) callback.

#### Arguments

| Name                           | Type               | Default                    | Description                                                                     |
| ------------------------------ | ------------------ | -------------------------- | ------------------------------------------------------------------------------- |
| `opts`                         | `table`            | Required                   | Options for the status                                                          |
| `opts.sections[]`              | `table`            | Required                   | Section of the status                                                           |
| `opts.sections[].components[]` | `fun(): string?`   | Required                   | Component of the section. Specify a function that returns a string to render.   |
| `opts.sections[].separator`    | `string?`          | `" \| "`                   | Separator between components of the section                                     |
| `opts.sections[].padding`      | `number?`          | `1`                        | Padding inside the section                                                      |
| `opts.sections[].foreground`   | `string`           | Required                   | Foreground color of the section                                                 |
| `opts.sections[].background`   | `string`           | Required                   | Background color of the section                                                 |
| `opts.separator`               | `SectionSeparator` | `section_separators.ARROW` | Separator between the sections. See below for the list of available separators. |
| `opts.hide_empty_sections`     | `boolean`          | `true`                     | Whether to hide the section if all components are empty                         |

##### List of available `section_separators`

| Name                               | Value          |
| ---------------------------------- | -------------- |
| `section_separators.NONE`          | `{ "", "" }`   |
| `section_separators.ARROW`         | `{ "", "" }` |
| `section_separators.ROUND`         | `{ "", "" }` |
| `section_separators.SLANT`         | `{ "", "" }` |
| `section_separators.SLANT_REVERSE` | `{ "", "" }` |

#### Returns

A string to be set as the status.

## Tips

### Insert spaces between the left status and the tab bar

```lua
-- Change the number of spaces as you like
window:set_left_status(status .. (" "):rep(2))
```

### The workspace names set by [wez-per-project-workspace](https://github.com/sei40kr/wez-per-project-workspace) are too long to display

[wez-per-project-workspace](https://github.com/sei40kr/wez-per-project-workspace)
sets the workspace names to the full path of the project directory and it's too
long to display.

You can truncate a workspace name to display the last directory name only.

```lua
local status = status_generator.generate_left_status({
    sections = {
        {
            components = {
                function()
                    return window:mux_window():get_workspace():gsub(".*/", "")
                end,
            },
        },
    },
})
```

### Use `wezterm.format` to set the attributes of a component

You cannot simply set the attributes of a component with `wezterm.format`
because it resets current attributes all.

As a workaround, you can put the foreground/background colors of the section
together.

```lua
local status = status_generator.generate_left_status({
    sections = {
        {
            components = {
                function()
                    return wezterm.format({
                        { Attribute = { Intensity = "Bold" } },

                        -- Put the foreground/background colors of the section together
                        { Foreground = { Color = "#15161e" } },
                        { Background = { Color = "#7aa2f7" } },

                        { Text = window:mux_window():get_workspace() },
                    })
                end,
            },
            foreground = "#15161e",
            background = "#7aa2f7",
        },
    },
})
```
