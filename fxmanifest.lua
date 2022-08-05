fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_backpack'
description 'Multiple Backpack Items'
version '3.0'

shared_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua'
}

dependencies {
	'es_extended'
}