fx_version 'adamant'
games { 'gta5' }

author 'Musiker15'
description 'ESX Backpack'
version '2.0'

shared_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'server.lua'
}

dependencies {
	'es_extended'
}