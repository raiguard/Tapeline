-- we must do this here instead of in on_configuration_changed so the event module doesn't crash
global.__lualib = {
  event = {},
  gui = {}
}