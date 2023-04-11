if table.unpack == nil then table.unpack = unpack end

function __AttachScript__(aentity)
	local Entity = entity
	local entity = aentity

    local k,v
    if type(Entity)=="table" then
        for k,v in pairs(Entity) do
            if type(k)=="string" then
                if type(v)=="function" then--add all functions into a function table
                    if type(entity.__functable__) ~= "table" then entity.__functable__ = {} end
                    if type(entity.__functable__[k]) ~= "table" then entity.__functable__[k] = {} end
                    table.insert(entity.__functable__[k],v)
                    --Print("Adding function "..k)
                    
                    --Create dummy function that calls all copies of the function with this name
                    if entity[k] ~= "function" then
                        local funcname = k
                        
                        function __DummyFunc__(entity,...)
                            return __ScriptFunction__(entity,funcname,...)
                        end
                        
                        entity[k] = __DummyFunc__
                    end
				else
					--Print("Adding field "..k.." = " .. tostring(v))
					entity[k] = v --add values directly to entity
                end
            else
                Print("Error: Script key must be a string.")
            end
        end
    else
        Print("Error: Script Entity table not found.")
    end
end

function __ScriptFunction__(entity, funcname, ...) --accepts any number of arguments
    local results = {}
    local n,func,funcs,result
    if type(entity.__functable__) == "table" then
        funcs = entity.__functable__[funcname]
        if type(funcs)=="table" then
			
			--Reset function if Start is called so it only gets called once per script
			--Needs to be done immediately in case function calls AddScript()
			if funcname=="Start" then entity.__functable__["Start"] = {} end
			
			for n,func in ipairs(funcs) do
				
                if type(func)=="function" then
                    result = func(entity, ...) --supplies all arguments to the function
                    if result ~= nil then
                        table.insert(results,result) --insert the return value into the table of returned values
                    end
                else
                    Print("Error: Function table value must be a function.")
				end
				
            end
        end
    end
    
    --Call flowgraph outputs
    entity:FireOutputs(funcname)
    
    return table.unpack(results) --returns multiple results
end

function __CloneScriptState__(source,target)
    local k,v
    for k,v in pairs(source) do
        if k == "__functable__" then
            local funcname,funclist
            if type(target.__functable__) ~= "table" then target.__functable__ = {} end
            for funcname,funclist in pairs(v) do
                target.__functable__.funcname = funclist
            end
        else
            target[k] = v
        end
    end
end