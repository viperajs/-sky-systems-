fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Sky-Systems'
description 'Base resource for all Sky-Systems Scripts'
version '1.26.0'

escrow_ignore 'config/**'

shared_scripts {
    'source/diagnostics.lua',
    'config/init.lua',
    'config/config.lua',
    'config/currency.lua',
    'config/locales/*.lua',
    'config/functions.lua',
    'source/shared/init.lua',
    'source/shared/modules/*.lua',
    'source/shared/main.lua',
    'source/shared/set_config.lua',
}

server_scripts {
    -- '@vrp/lib/utils.lua',
    '@oxmysql/lib/MySQL.lua',
    '@mysql-async/lib/MySQL.lua',
    'config/framework/*.lua',
    'source/server/inventory/helpers.lua',
    'config/inventory/native/*.lua',
    'config/inventory/*.lua',
    'source/server/inventory/defaults.lua',
    'source/server/inventory/cache.lua',
    'config/banking/*.lua',
    'config/sv_config.lua',
    'config/sv_functions.lua',
    'config/housing/*.lua',
    'config/garage/*.lua',
    'config/phone/*.lua',
    'config/billing/*.lua',
    'config/license/*.lua',
    'source/server/main.lua',
    'source/server/modules/*.lua'
}

client_scripts {
    -- '@vrp/client/Proxy.lua',
    -- '@vrp/client/Tunnel.lua',
    'config/phone/*.lua',
    'source/client/main.lua',
    'source/client/modules/*.lua',
    'source/client/events.lua',
    'config/framework/*.lua',
    'config/housing/*.lua',
    'config/target/*.lua',
    'config/vehiclekeys/*.lua',
    'config/fuel/*.lua',
    'config/progress/*.lua',
}

files {
    'source/diagnostics.lua',
    'source/import.lua',
    'source/client/modules/*.lua',
    'source/shared/modules/*.lua',
    'source/html/index.html',
    'source/html/assets/*.*'
}

ui_page 'source/html/index.html'

dependency '/assetpacks'
