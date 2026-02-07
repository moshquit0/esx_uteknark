-- Simple locale helper to keep the resource framework-agnostic.
--
-- Locale files populate `Locales[<code>] = { key = 'value', ... }`
-- Config.Locale controls which dictionary to use.

Locales = Locales or {}

local function resolveLocale(code)
    if not code then return nil end
    if Locales[code] then return Locales[code] end
    local lower = string.lower(code)
    if Locales[lower] then return Locales[lower] end
    -- Try language only (e.g. de-DE -> de)
    local lang = lower:match('^([a-z]+)')
    if lang and Locales[lang] then return Locales[lang] end
    return nil
end

---Translate helper. Keep the same signature as ESX locale (_U).
---@param key string
---@param ... any
function _U(key, ...)
    local code = (Config and Config.Locale) or 'en-US'
    local dict = resolveLocale(code) or resolveLocale('en-US') or resolveLocale('en') or {}
    local value = dict[key]
        or (resolveLocale('en-US') and resolveLocale('en-US')[key])
        or (resolveLocale('en') and resolveLocale('en')[key])
        or key

    if select('#', ...) > 0 then
        return string.format(value, ...)
    end
    return value
end
