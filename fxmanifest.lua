fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Moshquito'
description 'mosh_uteknark (UteKnark) - multi-framework bridge (ESX/QB/Standalone)'
version '1.2.0'

dependencies {
    'oxmysql'
}

shared_scripts {
    'lib/locale.lua',
    'locales/*.lua',
    'config.lua',
    'lib/octree.lua',
    'lib/growth.lua',
    'lib/cropstate.lua'
}

client_scripts {
    'lib/debug.lua',
    'cl_mosh_uteknark.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'sv_mosh_uteknark.lua'
}
