local defaultLocale = "en"
locales = {}

function translate(str, ...)
	if locales[Config.locale] then
		if locales[Config.locale][str] then
			return string.format(locales[Config.locale][str], ...)
		elseif Config.locale ~= "en" and locales["en"] and locales["en"][str] then
			return string.format(locales["en"][str], ...)
		else
			return "Translation [" .. Config.locale .. "][" .. str .. "] does not exist"
		end
	elseif Config.locale ~= defaultLocale and locales[defaultLocale] and locales[defaultLocale][str] then
		return string.format(locales[defaultLocale][str], ...)
	else
		return "Locale [" .. Config.locale .. "] does not exist"
	end
end

function translateCap(str, ...)
	return _(str, ...):gsub("^%l", string.upper)
end

_ = translate
_U = translateCap
