fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Moshquito forked from DemmyDemon'
description 'UteKnark (ESX Legacy update)'
version 'legacy-esx'

dependencies {
  'es_extended'
  -- optional: 'oxmysql' (if you use it)
}

shared_scripts {
  '@es_extended/imports.lua',
  '@es_extended/locale.lua',
  'locales/*.lua',
  'config.lua',
  'lib/*.lua'
}

client_scripts {
  'cl_uteknark.lua'
}

-- variant A (recommended): oxmysql
server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'sv_uteknark.lua'
}

-- variant B (If you are still using mysql-async): then replace the OX block above with:
-- server_scripts {
--   '@mysql-async/lib/MySQL.lua',
--   'sv_uteknark.lua'
-- }
