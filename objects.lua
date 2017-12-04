local Objects = {}





function Objects.newObject(name, type, value, x, y, width, height)
	local obj = {}
	obj.name = name
	obj.type = type
	obj.value = value
	obj.x, obj.y = x, y
	obj.width, obj.height = width, height
	obj.speedX, obj.speedY = 0, 0
	obj.full = true

	obj.filter = function(item, other)
		if other.name == 'palyer' then
			return 'cross'
		end
	end

	return obj

end

return Objects