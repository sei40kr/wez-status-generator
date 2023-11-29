{ mkShell, wezterm, wez-status-generator, writeTextFile }:

let
  config = writeTextFile {
    name = "wez-status-generator-dev-shell-config.lua";
    text = ''
      package.path = package.path .. ";${wez-status-generator}/?.lua"

      local wezterm = require("wezterm")

      local config = {}

      if wezterm.config_builder then
        config = wezterm.config_builder()
      end

      config.use_fancy_tab_bar = false

      wezterm.on("update-status", function(window, pane)
        local status_generator = require("plugin")
        local section_a = {
          foreground = "#15161e",
          background = "#7aa2f7",
        }
        local section_b = {
          foreground = "#7aa2f7",
          background = "#3b4261",
        }
        local section_c = {
          foreground = "#a9b1d6",
          background = "#16161e",
        }
        local left_status = status_generator.generate_left_status({
          sections = {
            {
              components = {
                function() return window:mux_window():get_workspace() end,
              },
              foreground = section_a.foreground,
              background = section_a.background,
            },
            {
              components = {
                function() return wezterm.home_dir:gsub(".*/", "") end,
              },
              foreground = section_b.foreground,
              background = section_b.background,
            },
            {
              components = {
                function()
                  local tab_id = window:mux_window():active_tab():tab_id()
                  local pane_id = pane:pane_id()

                  return tab_id .. ":" .. pane_id
                end,
              },
              foreground = section_c.foreground,
              background = section_c.background,
            },
          },
        })
        local right_status = status_generator.generate_right_status({
          sections = {
            {
              components = {
                function() return wezterm.strftime("%H:%M:%S") end,
              },
              foreground = section_c.foreground,
              background = section_c.background,
            },
            {
              components = {
                function() return wezterm.strftime("%d-%b-%y") end,
              },
              foreground = section_b.foreground,
              background = section_b.background,
            },
            {
              components = {
                function() return wezterm.hostname() end,
              },
              foreground = section_a.foreground,
              background = section_a.background,
            },
          },
        })

        window:set_left_status(left_status)
        window:set_right_status(right_status)
      end)

      return config
    '';
  };
in
mkShell {
  name = "wez-status-generator-dev-shell";

  packages = [ wezterm ];

  shellHook = ''
    alias wezterm="wezterm --config-file ${config}"
  '';
}
