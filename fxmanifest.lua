fx_version 'adamant'

game 'gta5'

description "A DMV School for players to get their drivers license"

version '1.0'
legacyversion '1.9.1'

lua54 'yes'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

ui_page 'http://localhost:3000/'

files {
	'html/dist/index.html',
	'html/dist/assets/*',
	'html/dmv.png'
}

dependencies {
	'es_extended',
	'esx_license'
}
