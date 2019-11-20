## Tapeline Notes

### Global Table Structure
```
global
    conditional_event_registry (used by event handler)
    end_wait (number)
    next_tilegrid_index (number)
    tilegrids
        drawing
            <index>
                last_capsule_pos (LuaPosition)
                last_capsule_tick (number)
                player (number)
        perishing
            <index> = tick_to_perish (number)
        registry
            <index>
                area
                    left_bottom (LuaPosition)
                    left_top (LuaPosition)
                    right_bottom (LuaPosition)
                    right_top (LuaPosition)
                    origin (LuaPosition)
                    midpoints (LuaPosition)
                    width (number)
                    height (number)
                    width_changed (boolean)
                    height_changed (boolean)
                entities
                    highlight_box (LuaEntity)
                    settings_button (LuaEntity)
                hot_corner (string)
                surface (number)
                settings
                    (identical to settings in players table)
    players
        <index>
            cur_drawing
            cur_editing
            settings
                auto_clear
                cardinals_only
                grid_type
                increment_divisor
                split_divisor
                log_to_chat
```

