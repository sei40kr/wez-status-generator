# wez-status-style

## Installation

Clone this repository to your `$XDG_CONFIG_HOME/wezterm`:

```sh
git clone https://github.com/sei40kr/wez-tmux.git $XDG_CONFIG_HOME/wezterm
```

## Usage

```lua
-- Recommended configuration:
config.use_fancy_tab_bar = false

wezterm.on("update-status", function(window, pane)
    local status_styler = require("wez-status-styler.plugin")
    local status = status_styler.generate_left_status({
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
                    function() return wezterm.home_dir:gsub(".*/", "") end,
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
    })

    window:set_left_status(status)
end)
```

```lua
-- Recommended configuration:
config.use_fancy_tab_bar = false

wezterm.on("update-status", function(window, pane)
    local status_styler = require("wez-status-styler.plugin")
    local status = status_styler.generate_right_status({
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
    })

    window:set_right_status(status)
end)
```

## API References

### `generate_left_status`, `generate_right_status`

Generate a status for the left or right side of the window. Expected to be
called from the [update-status](https://wezfurlong.org/wezterm/config/lua/window-events/update-status.html) callback.

#### Arguments

| Name                           | Type             | Description                                                                   |
| ------------------------------ | ---------------- | ----------------------------------------------------------------------------- |
| `opts`                         | `table`          | Options for the status                                                        |
| `opts.sections[]`              | `table`          | Section of the status                                                         |
| `opts.sections[].components[]` | `fun(): string?` | Component of the section. Specify a function that returns a string to render. |
| `opts.sections[].separator`    | `string?`        | Separator between components of the section                                   |
| `opts.sections[].padding`      | `number?`        | Padding inside the section                                                    |
| `opts.sections[].foreground`   | `string`         | Foreground color of the section                                               |
| `opts.sections[].background`   | `string`         | Background color of the section                                               |

#### Returns

A string to be set as the status.