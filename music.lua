local Music = {}

Music.songs = {}
local effects = {}
local playing_song = nil

Music.effectsEnabled = true
Music.songsEnabled = true

-- Загружает аудио-файлы в соответствии с их типом
-- Типы могут быть: song (для песен в фоне) и sfx (для эффектов)
function Music.load(type, name, path)
	if type == "song" then
		Music.songs[name] = love.audio.newSource(path, "static")
		Music.songs[name]:setLooping(true)
		Music.songs[name]:setVolume(0.25)
	end

	if type == "sfx" then
		effects[name] = love.audio.newSource(path, "static")
	end
end

-- Включает песню по параметру song (название песни), а уже
-- играющая песня останавливается
function Music.play(song)
	if Music.songsEnabled then
		if Music.songs[song] ~= nil then
			Music.stop()
			Music.songs[song]:play()
			playing_song = song
		end
	end
end

-- Выключает играющую песню
function Music.stop()
	if Music.songs[playing_song] ~= nil then
		Music.songs[playing_song]:stop()
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
