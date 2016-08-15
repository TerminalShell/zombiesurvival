-- See the languages folder to add your own languages.

translate = {}

local Languages = {}
local Translations = {}
local AddingLanguage
local CurrentLanguage = "eng"

function translate.GetLanguages()
	return Languages
end

function translate.GetLanguageName(short)
	return Languages[short]
end

function translate.GetTranslations(short)
	return Translations[short] or Translations["eng"]
end

function translate.SwitchLanguage(short)
	CurrentLanguage = short
end

function translate.AddLanguage(short, long)
	Languages[short] = long
	Translations[short] = Translations[short] or {}
	AddingLanguage = short
end

function translate.AddTranslation(id, text)
	if not AddingLanguage or not Translations[AddingLanguage] then return end

	Translations[AddingLanguage][id] = text
end

function translate.Get(id)
	return translate.GetTranslations(CurrentLanguage)[id] or translate.GetTranslations("eng")[id] or ("@"..id.."@")
end

function translate.Format(id, ...)
	return string.format(translate.Get(id), ...)
end

if SERVER then
	function translate.ClientGet(pl, ...)
		translate.SwitchLanguage(pl:GetInfo("zs_language"))
		return translate.Get(...)
	end

	function translate.ClientFormat(pl, ...)
		translate.SwitchLanguage(pl:GetInfo("zs_language"))
		return translate.Format(...)
	end
end

if CLIENT then
	translate.ClientGet = Get
	translate.ClientFormat = Format
end

for i, filename in pairs(file.Find(GM.FolderName.."/gamemode/languages/*.lua", "LUA")) do
	LANGUAGE = {}
	AddCSLuaFile("languages/"..filename)
	include("languages/"..filename)
	for k, v in pairs(LANGUAGE) do
		translate.AddTranslation(k, v)
	end
	LANGUAGE = nil
end
