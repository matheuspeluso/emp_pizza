-- copiei do client
Tunnel = module('vrp','lib/Tunnel') -- permite que usamos as funções do server , no nosso client
    -- agora diferente do tunnel que é server pra cliente e de client pra server 
    -- temos o proxie que é de server pra server e de cliente pra client 
Proxy = module('vrp','lib/Proxy')
    
    --para buscar as imformações da vrp 
vRP = Proxy.getInterface('vRP'); -- feito isso já podemos usar as funções do client da framework

Work = {}

-- tunelar para que as funções do nosso server possamos usar lá no nosso ClearInteriorForEntity

Tunnel.bindInterface(GetCurrentResourceName(),Work)
-- native GetCurrentResourceName() resposnavel por retornar o nome do arquivo , nesse caso emp_pizza
--segundo parametro que é Work é a nossa tabela que iremos tunelar
