function love.conf(t)
	t.title = "A Tale about tail"			-- The title of the window the game is in (string)
	t.version = "0.10.2"
	t.console = false					-- Attach a console (boolean, Windows only)
	t.window.width = 640				-- The window width (number)
	t.window.height = 640				-- The window height (number)
	t.window.fullscreen = false			-- Enable fullscreen (boolean)
	t.window.vsync = false				-- Enable vertical sync (boolean)
	t.window.resizable = false
	t.modules.audio = true				-- Enable the audio module (boolean)
	t.modules.keyboard = true			-- Enable the keyboard module (boolean)
	t.modules.event = true				-- Enable the event module (boolean)
	t.modules.image = true				-- Enable the image module (boolean)
	t.modules.graphics = true			-- Enable the graphics module (boolean)
	t.modules.timer = true				-- Enable the timer module (boolean)
	t.modules.mouse = true				-- Enable the mouse module (boolean)
	t.modules.sound = true				-- Enable the sound module (boolean)
	t.modules.physics = false			-- Enable the physics module (boolean)
	t.modules.filesystem = true
end
