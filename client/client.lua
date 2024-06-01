Tunnel = module('vrp','lib/Tunnel') -- permite que usamos as funções do server , no nosso client
-- agora diferente do tunnel que é server pra cliente e de client pra server 
-- temos o proxie que é de server pra server e de cliente pra client 
Proxy = module('vrp','lib/Proxy')

--para buscar as imformações da vrp 
vRP = Proxy.getInterface('vRP'); -- feito isso já podemos usar as funções do client da framework

-- criando uma tabela 
Work = {
    pizzaInVehicle = {},
    routes = {
        {-1366.07, 56.52, 54.1},
        {-1047.89, 312.96, 67.01},
        {-958.13, 607.02, 106.3},
        {-772.74, 313.0, 85.7},
    }
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
                    TriggerEvent('Notify','aviso','Você entrou em serviço. Pegue seu veiculo de trabalho no estacionamento!',3000)
                    Work:spawVehicle()
                    Work:createRoutes() --criando rotas
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

    Citizen.CreateThread(function () 
        -- ao criar uma thread , ele executa todo o while mas sem atrapalhar o retante do
        -- codigo / e desta forma não travando o codigo no while infinitamente
        while self.inService do
            local sleep = 1000

            local ped = PlayerPedId()
            if not IsPedInAnyVehicle(ped, false)then
                local playerPos = GetEntityCoords(ped)
                local distance = #(playerPos - GetEntityCoords(self.vehicle)) < 2
                if distance then
                    sleep = 0
                    local havePizzaInVeh = #self.pizzaInVehicle > 0 and 'PRESSIONE ~y~[G] ~w~PARA ~y~RETIRAR ~w~A PIZZA DA MOTO' or ''
                    local text = self.pizzaInHand and 'PRESSIONE ~g~[G] ~w~PARA ~g~COLOCAR ~w~A PIZZA NA MOTO' or havePizzaInVeh
                    self:DrawText3D(playerPos.x,playerPos.y,playerPos.z,text)
                    if IsControlJustPressed(0, 58) then
                        if self.pizzaInHand then
                            self:removePizzaInHand()
                            self:putPizzaInVehicle()
                        elseif #self.pizzaInVehicle > 0 then
                            self:removePizzaFromVehicle() -- removendo a pizza do veiculo
                            Work:takePizzaHand() -- pegando novamente ela na mão
                        end
                        
                    end
                end
            end
            Citizen.Wait(sleep)

        end
    end)

end

--função rotas]
function Work:createRoutes()
    self.currentRoute = self.routes[math.random(1,#self.routes)]
    self.currentBlip = AddBlipForCoord(self.currentRoute[1],self.currentRoute[2],self.currentRoute[3])
    SetBlipSprite(self.currentBlip, 162)
    SetBlipColour(self.currentBlip, 5)
    SetBlipScale(self.currentBlip, 0.5)
    SetBlipAsShortRange(self.currentBlip, false)--mudar
    SetBlipRoute(self.currentBlip, true) -- cria o caminho ate o blip
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Entregar Pizza')
    EndTextCommandSetBlipName(self.currentBlip)

    --criando sistema de entregas
    Citizen.CreateThread(function ()
        while self.inService do
            local sleep = 1000
            local playerPos = GetEntityCoords(PlayerPedId())
            local distance =  #(playerPos - vec3(self.currentRoute[1],self.currentRoute[2],self.currentRoute[3])) -- convertendo as cordenadas para vector 3
            if distance < 2 then
                sleep = 0
                local text = self.pizzaInHand and "PRESSIONE ~g~[E] ~w~PARA ENTREGAR A PIZZA" or "CADE MINHA PIZZA ???"
                self:DrawText3D(self.currentRoute[1],self.currentRoute[2],self.currentRoute[3],text)
                if self.pizzaInHand and IsControlJustPressed(0, 38)then
                    self:removePizzaInHand()
                    Remote:sendMoney()
                    -- pelo Remote tunnel é possivel chamar uma função de pagamento que foi criada no server e chamar ela no cliente
                    RemoveBlip(self.currentBlip)
                    Work:createRoutes()
                    break
                end
            end
            Wait(sleep)
        end
    end)

end

--função pegar pizza na mão
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

--função remover pizza do veiculo
function Work:removePizzaFromVehicle()
    DeleteEntity(self.pizzaInVehicle[#self.pizzaInVehicle]) -- deletando o ultimo objeto
    -- passando o # ele retorna a quantidade de items da tabela e eu removo esse ultimo objeto
    self.pizzaInVehicle[#self.pizzaInVehicle] = nil -- removendo o ultimo objeto da tabela
end

--função colocar pizza no veiculo
function Work:putPizzaInVehicle()
    local pizza = CreateObject(GetHashKey('prop_pizza_box_02'), 0, 0, 0, true, true, true)
    local height = #self.pizzaInVehicle * 0.05
    AttachEntityToEntity(pizza, self.vehicle, GetEntityBoneIndexByName(self.vehicle, 'bodyshell'), 0.0, -0.8, 0.4 + height, 0.0, 0.0 , 0.0, false, true, false, false, 1, true)
    table.insert(self.pizzaInVehicle,pizza) -- a partir conseguimos saber quantas pizza temos em nosso veiculo
end

-- função remover pizza da mão
function Work:removePizzaInHand()
    self.pizzaInHand = false -- setando que não tem pizza mais na mão do player
    ClearPedTasks(PlayerPedId()) -- limpando a animação de segurar a pizza 
    DeleteEntity(self.currentPizzaInHand) -- deletando o objeto da pizza
    self.currentPizzaInHand = false --limpando a pizza

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

RegisterCommand('pararpizza', function ()

    TriggerEvent('Notify','aviso','Você saiu do serviço!',3000)
    --verficando se está em serviço
    if not Work.inService then
        return
    end

    -- verificando se tem blip e removendo caso tenha 
    if Work.currentBlip then
        RemoveBlip(Work.currentBlip)
    end

    -- verificando se tem carro e removendo caso tenha 
    if Work.vehicle then
        DeleteEntity(Work.vehicle)
    end

    if Work.currentPizzaInHand then
        DeleteEntity(Work.currentPizzaInHand)
    end

    if #Work.pizzaInVehicle > 0 then
        for key, value in pairs(Work.pizzaInVehicle) do
            DeleteEntity(value)
        end
    end

    Work.inService = nil
    Work.vehicle = nil
    Work.currentRoute = nil
    Work.currentBlip = nil
    Work.currentPizzaInHand = nil
    Work.pizzaInVehicle = {}
    ClearPedTasks(PlayerPedId())
    
end)