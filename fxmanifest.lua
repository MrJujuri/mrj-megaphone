fx_version 'cerulean'
game 'gta5'
lua54 'true'

author 'MrJujuri'
description 'Megaphone Script for QBCore and ESX'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/megaphone.lua'
}

server_scripts {
    'server/megaphone.lua'
}
