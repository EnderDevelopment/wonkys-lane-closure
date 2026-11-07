fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'wonkys_laneclosure'
author 'EnderDevelopment'
description 'Manual cone layouts that divert ambient traffic around lane closures.'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib'
}
