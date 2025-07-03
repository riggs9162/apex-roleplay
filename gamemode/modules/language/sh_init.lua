apex.language = apex.language or {}
apex.language.stored = apex.language.stored or {}

local selectedLanguage = GetConVarString("gmod_language")

function apex.language.Register(name, tbl)
	local old = apex.language.stored[name] or {}
	apex.language.stored[name] = tbl

	for k, v in pairs(old) do
		apex.language.stored[name][k] = v
	end

	LANGUAGE = apex.language.stored[name]

	print("Language registered: " .. name)
end

function apex.language.AddPhrase(lang, name, phrase)
	apex.language.stored[lang] = apex.language.stored[lang] or {}
	apex.language.stored[lang][name] = phrase
end

function apex.language.GetPhrase(name, ...)
	local langTable = apex.language.stored[selectedLanguage] or apex.language.stored.en

	return string.format(langTable[name] or apex.language.stored.en[name], ...)
end

print("Language module loaded")