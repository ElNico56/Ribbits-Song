local rl = rl or require"raylib" ---@diagnostic disable-line
local ffi = require"ffi"

local function display_name(filename)
	local name = filename:gsub("%.ogg$", ""):gsub("_", " ")
	return name:gsub("(%w)(%w*)", function(f, r) return f:upper()..r:lower() end)
end

local function main()
	rl.SetTraceLogLevel(rl.LOG_FATAL)
	rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)
	rl.InitWindow(1080, 720, "")
	rl.SetTargetFPS(15)
	rl.InitAudioDevice()

	-- for f in io.popen"ls assets/*.ogg":lines() do table.insert(files, f) end
	-- for f in io.popen"dir /b assets\\*.ogg":lines() do table.insert(files, f) end
	-- if #files == 0 then
	-- 	print"No .ogg files found in current directory."
	-- 	rl.CloseAudioDevice()
	-- 	rl.CloseWindow()
	-- 	return
	-- end
	local files = rl.LoadDirectoryFiles"Ribbit/assets"
	for i = 0, files.count - 1 do
		print(ffi.string(files.paths[i]):match"[^/]%.ogg$")
	end
	local files = {"bass.ogg", "bongo.ogg", "flute.ogg", "guitar.ogg", "maraca.ogg"}

	local names = {}
	for i, path in ipairs(files) do names[i] = display_name(path) end

	local volumes = {}
	for i = 1, #files do volumes[i] = 1.0 end

	local sounds = {}
	for i, path in ipairs(files) do sounds[i] = rl.LoadSound("assets/"..path) end

	local speed = 1.0

	while not rl.WindowShouldClose() do
		for i = 1, #files do
			if rl.IsKeyPressed(rl.KEY_ONE + (i - 1)) then
				volumes[i] = 1 - volumes[i]
				rl.SetSoundVolume(sounds[i], volumes[i])
			end
		end

		if rl.IsKeyPressed(rl.KEY_DOWN) then speed = speed - 0.5 end
		if rl.IsKeyPressed(rl.KEY_UP) then speed = speed + 0.5 end

		local pitch = 2 ^ (speed - 1)
		for _, s in ipairs(sounds) do rl.SetSoundPitch(s, pitch) end

		for _, s in ipairs(sounds) do
			if not rl.IsSoundPlaying(s) then rl.PlaySound(s) end
		end

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		rl.DrawText(("Speed Units: %.1f"):format(speed), 30, 30, 30, rl.BLUE)
		rl.DrawText(("Pitch Factor: %.2f"):format(pitch), 30, 80, 30, rl.BLUE)

		for i = 1, #names do
			local color = volumes[i] > 0.5 and rl.GREEN or rl.RED
			rl.DrawText(("%d. %s"):format(i, names[i]), 50, 130 + (i - 1) * 50, 30, color)
		end

		rl.EndDrawing()
	end

	for _, s in ipairs(sounds) do rl.UnloadSound(s) end
	rl.CloseAudioDevice()
	rl.CloseWindow()
end

main()
