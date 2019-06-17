function retrieve_mod_settings(e)

    stdlib.logger.log('retrieve mod settings')

end

stdlib.event.register({defines.events.on_runtime_mod_setting_changed,'on_load'}, retrieve_mod_settings)