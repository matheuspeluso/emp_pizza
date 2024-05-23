Tunnel = module('vrp','lib/Tunnel') -- permite que usamos as funções do server , no nosso client
-- agora diferente do tunnel que é server pra cliente e de client pra server 
-- temos o proxie que é de server pra server e de cliente pra client 
Proxy = module('vrp','lib/Proxy')

--para buscar as imformações da vrp 
vRP = Proxy.getInterface('vRP'); -- feito isso já podemos usar as funções do client da framework

-- criando uma tabela 
Work = {}

Remote = Tunnel.getInterface(GetCurrentResourceName()) -- tudo que estiver em work eu vou poder acessar no meu client

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local playerPos = GetEntityCoords(ped)
        local makerPos = vector3(144.18, -1462.18, 29.15-1)

        local distancia  = #(playerPos - makerPos)
        if distancia < 7 then
            sleep = 5
            DrawMarker(27, makerPos.x, makerPos.y, makerPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 1.2, 255, 255, 255, 255, false, false, 2, true, nil, nil, nil)
        end
        
        Wait(sleep)
    end

end)