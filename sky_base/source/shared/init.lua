if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/shared/init.lua") end
-- =====================================================
--  sky_base · source/shared/init.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = {
    Config = Config,
    Functions = Functions
}

Locales = Locales[Config.locale] or Locales.en
