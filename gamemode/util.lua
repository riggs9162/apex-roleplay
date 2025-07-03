function GM:LoadFile(path, realm)
	if ( !isstring(path) ) then
		self:PrintError("Failed to load file " .. path .. "!")
		return
	end

	if ( ( realm == "server" or string.find(path, "sv_") ) and SERVER ) then
		include(path)
	elseif ( realm == "shared" or string.find(path, "shared.lua") or string.find(path, "sh_") ) then
		if ( SERVER ) then
			AddCSLuaFile(path)
		end

		include(path)
	elseif ( realm == "client" or string.find(path, "cl_") ) then
		if ( SERVER ) then
			AddCSLuaFile(path)
		else
			include(path)
		end
	else
		print("Failed to load file " .. path .. "! Realm not specified or invalid.")
		return
	end
end

function GM:LoadFolder(directory, bFromLua, recursive)
	local baseDir = debug.getinfo(2).source
	baseDir = string.sub(baseDir, 2, string.find(baseDir, "/[^/]*$"))
	baseDir = string.gsub(baseDir, "gamemodes/", "")

	if ( bFromLua ) then
		baseDir = ""
	end

	local files, folders = file.Find(baseDir .. directory .. "/*", "LUA")
	if ( files or #files != 0 ) then
		for _, file in ipairs(files) do
			self:LoadFile(directory .. "/" .. file)
		end
	end

	if ( recursive and folders and #folders != 0 ) then
		for _, folder in ipairs(folders) do
			self:LoadFolder(directory .. "/" .. folder, bFromLua, recursive)
		end
	end

	return true
end

function GM:GetTextWidth(font, text)
	surface.SetFont(font)
	return select(1, surface.GetTextSize(text))
end

function GM:GetTextHeight(font)
	surface.SetFont(font)
	return select(2, surface.GetTextSize("W"))
end

function GM:GetWrappedText(text, font, maxWidth)
	if ( !isstring(text) or !isstring(font) or !isnumber(maxWidth) ) then
		print("Attempted to wrap text with no value", text, font, maxWidth)
		return false
	end

	local lines = {}
	local line = ""

	if ( self:GetTextWidth(font, text) <= maxWidth ) then
		return {text}
	end

	local words = string.Explode(" ", text)

	for i = 1, #words do
		local word = words[i]
		local wordWidth = self:GetTextWidth(font, word)

		if ( wordWidth > maxWidth ) then
			for j = 1, string.len(word) do
				local char = string.sub(word, j, j)
				local next = line .. char

				if ( self:GetTextWidth(font, next) > maxWidth ) then
					lines[#lines + 1] = line
					line = ""
				end

				line = line .. char
			end

			continue
		end

		local space = (line == "") and "" or " "
		local next = line .. space .. word

		if ( self:GetTextWidth(font, next) > maxWidth ) then
			lines[#lines + 1] = line
			line = word
		else
			line = next
		end
	end

	if ( line != "" ) then
		lines[#lines + 1] = line
	end

	return lines
end