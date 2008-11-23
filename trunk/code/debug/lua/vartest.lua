_N.TestVariable = 10
_N.TestVariable = 12
_N.TestVariable = 32
_N.TestVariable = 10
_N.TestVariable = 32
_N.TestVariable = 10
_N.TestVariable = 32
_N.TestVariable = 10
_N.TestVariable = 32
_N.TestVariable = 10
_N.TestVariable = 32
_N.TestVariable = 32
Timer(.2,function() _N.Woot = "awesome" end)
Timer(.4,function() _N.Woot = "alright" end)
Timer(.6,function() _N.Woot = "hooray" end)

function EntThink()
	_N.EntityCount = #GetAllEntities()
end
hook.add("Think","vartest",EntThink)