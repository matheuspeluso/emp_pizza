Tunnel = module('vrp','lib/Tunnel') -- permite que usamos as funções do server , no nosso client
-- agora diferente do tunnel que é server pra cliente e de client pra server 
-- temos o proxie que é de server pra server e de cliente pra client 
Proxy = module('vrp','lib/Proxy')

--para buscar as imformações da vrp 
vRP = Proxy.getInterface('vRP'); -- feito isso já podemos usar as funções do client da framework

-- criando uma tabela 
Work = {
    pizzaInVehicle = {},
}

Remote = Tunnel.getInterface(GetCurrentResourceName()) -- tudo que estiver em work eu vou poder acessar no meu client

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local playerPos = GetEntityCoords(ped)
        local makerPos = vector3(144.18, -1462.18, 29.15)

        local distancia  = #(playerPos - makerPos)
        
        if distancia < 7 then
            if not Work.inService then
                
                sleep = 5
                Work:DrawText3D(makerPos.x, makerPos.y, makerPos.z+0.5,'PRESSIONE ~g~[E] ~w~PARA ENTRAR EM SERVIÇO!')
                DrawMarker(27, makerPos.x, makerPos.y, makerPos.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 1.2, 255, 255, 255, 255, false, false, 2, true, nil, nil, nil)
                if IsControlJustPressed(0, 38)then
                    Work.inService = true -- criando variavel para entrar em serviço
                    Work:spawVehicle()
                end
                
            else
                --[[
                    colcoar # na frente de tabela na qual so contenha valores sem chaves ,
                    retorna-se a quantidade de itens que tem na tabale
                    ]] 
                sleep = 5
                if #Work.pizzaInVehicle < 10 then
                    local text = Work.pizzaInHand and 'COLOQUE A PIZZA NA MOTO' or 'PRESSIONE ~g~[E] ~w~PARA PEGAR UMA PIZZA';
                    Work:DrawText3D(makerPos.x, makerPos.y, makerPos.z+0.5,text)
                    if not Work.pizzaInHand and IsControlJustPressed(0,38) then
                        Work:takePizzaHand()
                    end
                end
            end
        end
    
        Wait(sleep)
    end
end)

-- função pizza na mão

function Work:takePizzaHand()
    self.pizzaInHand = true -- self.pizaInHand = Work.pizzaInHand
    --self acessa tudo que esta dentro de work  ou seja ele mesmo

    --animação da pizza na mão
    local dict  = 'anim@heists@box_carry@'
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(),dict, 'idle', 8.0, 8.0, -1, 49, -1, true, false, false)
    self.currentPizzaInHand = CreateObject(GetHashKey('prop_pizza_box_02'), 0, 0, 0, true, true, true)
    AttachEntityToEntity(self.currentPizzaInHand, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, -0.2, -0.15, 0.0, 0.0, 0.0, 0.0, false, false, false, false, true)
end

-- criando veiculo
function Work:spawVehicle()
    local hash = GetHashKey('akuma')
    RequestModel(hash); -- requisitando veiculo

    while not HasModelLoaded(hash)do -- enquanto o veiculo não for carregado , esperar 100 milessegundos
        Citizen.Wait(100)
    end

    -- guardar a informação do veiculo para que depois consiga excluir o mesmo
    Work.vehicle = CreateVehicle(hash, 154.71, -1448.28, 29.15, 141.96, true, true) --native createVehicle alem de criar , retorna o identificador do mesmo
    SetVehicleNumberPlateText(Work.vehicle, vRP.getRegistrationNumber()) -- função da vrp que gerar a nossa placa na qual nosso o player se torna dono da placa


end

function Work:DrawText3D(x,y,z,txt) -- para poder trabalhar dessa forma é necessario estár usando o lua54 'yes' no fxmanifest.lua
    
    if txt == '' then
        return 
    end

    local onScreen, x2D, y2D = World3dToScreen2d(x,y,z)

    if onScreen then
        SetTextScale(0.5, 0.5)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255,255,255,255)
        SetTextEntry('STRING')
        SetTextCentre(true)
        AddTextComponentString(txt)
        DrawText(x2D,y2D)
    end

 
end