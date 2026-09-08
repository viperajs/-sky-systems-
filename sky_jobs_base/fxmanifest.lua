fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Sky-Systems'
description 'Jobs Base'
version '1.28.0'

escrow_ignore 'config/**'

shared_scripts {
	'source/diagnostics.lua',
	'source/import.lua',
	'source/enums/*.lua',
}

client_scripts {
	'config/init.lua',
	'config/config.lua',
	'config/locales/*.lua',
	'source/client/nui_registry.lua',
	'source/client/utils.lua',
	'source/client/access.lua',
	'source/client/bodycam_recorder.lua',
	'source/client/calendar.lua',
	'source/client/camera.lua',
	'source/client/cctv.lua',
	'source/client/chat.lua',
	'source/client/clothing.lua',
	'source/client/colleague_map_blips.lua',
	'source/client/creator.lua',
	'source/client/dispatch.lua',
	'source/client/duty.lua',
	'source/client/employee_gps_jammer.lua',
	'source/client/gallery.lua',
	'source/client/garage.lua',
	'source/client/heli_cam.lua',
	'source/client/incident_notification.lua',
	'source/client/job_configurator.lua',
	'source/client/main.lua',
	'source/client/management.lua',
	'source/client/map.lua',
	'source/client/multijob.lua',
	'source/client/panic.lua',
	'source/client/public_forms.lua',
	'source/client/radial_menu.lua',
	'source/client/shop.lua',
	'source/client/storage.lua',
	'source/client/tablet_apps.lua',
	'source/client/tablet_notifications.lua',
	'source/client/tablet_prop.lua',
	'source/client/tablet_state.lua',
	'source/client/vehicle_attach_editor.lua',
	'source/client/wardrobe.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config/init.lua',
	'config/config.lua',
	'config/locales/*.lua',
	'source/server/jobs.lua',
	'source/server/classes/*.lua',
	'source/server/creator.lua',
	'source/server/garage.lua',
	'source/server/main.lua',
	'source/server/map.lua',
	'source/server/shop.lua',
	'source/server/storage.lua',
	'source/server/tablet_apps.lua',
	'source/server/wardrobe.lua',
}

files {
	'source/diagnostics.lua',
	'source/html/index.html',
	'source/html/assets/**',
	'source/html/img/**',
	'source/html/sounds/**',
	'source/enums/*.lua',
	'source/import.lua'
}

ui_page 'source/html/index.html'

dependency 'sky_base'

dependency '/assetpacks'
