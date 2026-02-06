fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Moshquito'
description 'ESX UteKnark by DemmyDemon - updated for ESX Legacy'
version '1.1.4-legacy'

dependencies {
    'es_extended',
    'oxmysql'
}

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'lib/octree.lua',
    'lib/growth.lua',
    'lib/cropstate.lua'
}

client_scripts {
    'lib/debug.lua',
    'cl_uteknark.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'sv_uteknark.lua'
}
