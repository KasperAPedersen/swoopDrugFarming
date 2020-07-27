dependency 'vrp'

client_script {
    'extra/Tunnel.lua',
    'extra/Proxy.lua',
    'client.lua'
}

server_script {
    '@vrp/lib/utils.lua',
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}