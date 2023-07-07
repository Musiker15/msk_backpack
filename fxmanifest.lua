fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_backpack'
description 'Multiple Backpack Items'
version '3.7'

shared_scripts {
	'@es_extended/imports.lua',
	'@msk_core/import.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

dependencies {
	'es_extended',
	'oxmysql',
	'msk_core'
}