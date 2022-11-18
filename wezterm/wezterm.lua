local wezterm = require 'wezterm'
return {
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  hide_tab_bar_if_only_one_tab = true,
  font = wezterm.font_with_fallback {
    'Fira Code',
    'Nerd Font',
    'Mono',
  },
  font_size = 18.0,
  color_scheme = 'Gruvbox Dark',
}
