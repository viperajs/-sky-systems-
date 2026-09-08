fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Sky-Systems'
description 'Mechanic Job / Vehicle System'
version '1.12.0'

escrow_ignore 'config/**'

shared_scripts {
	'source/diagnostics.lua',
	'source/import.lua'
}

client_scripts {
	'config/init.lua',
	'config/config.lua',
	'config/adv_config.lua',
	'config/locales/*.lua',
	'source/client/state.lua',
	'source/client/main.lua',
	'source/client/xenon_sync.lua',
	'source/client/tuning_minigames.lua',
	'source/client/oil_change.lua',
	'source/client/spray_paint.lua',
	'source/client/vehicle_care.lua',
	'source/client/tuning.lua',
	'source/client/custom_tuning.lua',
	'source/client/stance_kit.lua',
	'source/client/radial_actions.lua',
	'source/client/engine_swap.lua',
	'source/client/orders.lua',
	'source/client/parts_delivery.lua',
	'source/client/lift.lua',
	'source/client/change_parts.lua',
	'source/client/rgb_controller.lua',
	'source/client/nitro.lua',
	'source/client/antilag.lua',
	'source/client/twostep.lua',
	'source/client/vehicle_effects.lua',
	'source/client/vehicle_rollover.lua',
	'source/client/vehicle_persistence.lua',
	'source/client/wear.lua',
	'source/client/wheel_damage.lua',
	'source/client/dyno.lua',
	'source/client/wheel_change.lua',
	'source/client/wheel_theft.lua',
	'source/client/catalytic_converter.lua',
	'source/client/stolen_parts_dealer.lua',
	'source/client/gallery.lua',
	'source/client/vehicles.lua',
	'source/client/tablet_bridge.lua',
	'source/client/nui_jobs_bridge.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config/init.lua',
	'config/config.lua',
	'config/adv_config.lua',
	'config/sv_functions.lua',
	'config/locales/*.lua',
	'source/server/db_migrate.lua',
	'source/server/tuning_db.lua',
	'source/server/vehicle_persistence.lua',
	'source/server/vehicle_history.lua',
	'source/server/pricing.lua',
	'source/server/main.lua',
	'source/server/lift.lua',
	'source/server/vehicle_care.lua',
	'source/server/migrate.lua',
	'source/server/wear.lua',
	'source/server/catalytic_converter.lua',
	'source/server/wheel_theft.lua',
	'source/server/stolen_parts_dealer.lua',
	'source/server/wheel_damage.lua',
	'source/server/nitro.lua',
	'source/server/vehicles.lua',
	'source/server/parts_delivery.lua',
	'source/server/antilag.lua',
	'source/server/twostep.lua',
	'source/server/tablet_apps.lua',
	'source/server/debug.lua',
}

files {
	'source/diagnostics.lua',
	'config/img/**',
	'source/html/index.html',
	'source/html/assets/*.*',
	'source/html/img/**',
	"data/carcols_gen9.meta",
	"data/carmodcols_gen9.meta",
	"stream/sky_mechanic_props.ytyp",
}

ui_page 'source/html/index.html'

data_file "CARCOLS_GEN9_FILE" "data/carcols_gen9.meta"
data_file "CARMODCOLS_GEN9_FILE" "data/carmodcols_gen9.meta"
data_file 'DLC_ITYP_REQUEST' 'sky_mechanic_props.ytyp'

dependency 'sky_jobs_base'
dependency 'sky_base'

dependency '/assetpacks'
