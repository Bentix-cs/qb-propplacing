----------------------
--                  --
--    Scripted by   --
--       Ben        --
--                  --
----------------------



fx_version 'cerulean'
games { 'gta5' }

author 'Ben'
description 'qb-propplacing'
version '1.0.0'

lua54 'yes'

client_script 'client.lua'

server_script 'server.lua'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/*.lua'
}



