-- copiei do client
Tunnel = module('vrp','lib/Tunnel') -- permite que usamos as funções do server , no nosso client
    -- agora diferente do tunnel que é server pra cliente e de client pra server 
    -- temos o proxie que é de server pra server e de cliente pra client 
Proxy = module('vrp','lib/Proxy')
    
    --para buscar as imformações da vrp 
vRP = Proxy.getInterface('vRP'); -- feito isso já podemos usar as funções do client da framework

Work = {} -- work do server é diferente do work do client // são 2 arrays diferente

-- tunelar para que as funções do nosso server possamos usar lá no nosso ClearInteriorForEntity

Tunnel.bindInterface(GetCurrentResourceName(),Work)
-- native GetCurrentResourceName() resposnavel por retornar o nome do arquivo , nesse caso emp_pizza
--segundo parametro que é Work é a nossa tabela que iremos tunelar

-- sistema de pagamento
function Work:sendMoney()
    local src = source -- não precisa determinar nenhum valor para source 
    -- pois ela ja retorna no id do player automicaticamente no server
    --pela source é possivel pegar o ped e o id do player tb

    local money = math.random(1000,5000)
    vRP.giveInventoryItem(src, "dinheiro", money) 
    -- base vrpex o dinheiro vem pelo inventario mas pode mudar de acordo com o framework
    TriggerClientEvent('Notify', src, 'aviso', 'Você Recebeu <b>$' .. money .. '</b> em dinheiro!')
    

end