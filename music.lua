local Music = {}

local songs = {}
local effects = {}
local playing_song = nil

Music.effectsEnabled = true

-- Загружает аудио-файлы в соответствии с их типом
-- Типы могут быть: song (для песен в фоне) и sfx (для эффектов)
function Music.load(type, name, path)
	if type == "song" then
		songs[name] = love.audio.newSource(path, "static")
		songs[name]:setLooping(true)
		songs[name]:play()
		songs[name]:pause()
		songs[name]:setVolume(0.25)
	end

	if type == "sfx" then
		effects[name] = love.audio.newSource(path, "static")
	end
end

-- Включает песню по параметру song (название песни), а уже
-- играющая песня останавливается
function Music.play(song)
	if songs[song] ~= nil then
		Music.stop()
		songs[song]:resume()
		playing_song = song
	end
end

-- Выключает играющую песню
function Music.stop()
	if songs[playing_song] ~= nil then
		songs[playing_song]:pause()
	end
end

-- Воспроизводит  указанный эффект по параметру effecy (название)
-- Если этот эффект уже играл, он остановится и сыграется снова
function Music.effect(effect)
	if Music.effectsEnabled then
		if effects[effect] ~= nil then
			effects[effect]:stop()
			effects[effect]:play()
		end
	end
end

return Music
