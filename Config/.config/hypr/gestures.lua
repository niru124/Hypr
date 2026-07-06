-- █▀▀ █▀▀ █▀▀ █▀▀ █▀▀ █ █▀▀ █▀▀ █▀▀ █▀▀
-- █▄▄ █▄▄ █▄▄ █▄▄ █▄▄ █ █▄▄ █▄▄ █▄▄ █▄▄

hl.gesture({ fingers = 4, direction = "up", action = "float" })

-- 3-finger swipe: move focus between windows
hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
hl.gesture({ fingers = 3, direction = "up", action = function() hl.dispatch(hl.dsp.focus({ direction = "u" })) end })
hl.gesture({ fingers = 3, direction = "down", action = function() hl.dispatch(hl.dsp.focus({ direction = "d" })) end })

-- 4-finger swipe: workspace switching
hl.gesture({ fingers = 4, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ workspace = "r-1" })) end })
hl.gesture({ fingers = 4, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ workspace = "r+1" })) end })

-- 2-finger pinch: zoom
-- hl.gesture({ fingers = 2, direction = "pinch", action = "cursor_zoom", zoom_level = 2, mode = "live" })
