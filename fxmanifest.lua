fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dev Matheus Peluso'
description ''
version '1.0.0'

client_scripts {
    '@vrp/lib/utils.lua',
    'client/client.lua',
}

server_script {
    '@vrp/lib/utils.lua',
    'server/server.lua',
}
