-class "Leblanc"
- 
-require = 'DamageLib'
-require = 'Collision'
-require = 'Tpred'
-
function Leblanc:__init()
	print("Weedle's Leblanc Loaded")
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	self:Menu()
end	

function Leblanc:Menu()
	KoreanMechanics.Spell:MenuElement({id = "Q", name = "Q Key", key = string.byte("Q")})
	KoreanMechanics.Spell:MenuElement({id = "QR", name = "Q Range", value = 700, min = 0, max = 700, step = 10})
	KoreanMechanics.Spell:MenuElement({id = "W", name = "W Key", key = string.byte("W")})
--	KoreanMechanics.Spell:MenuElement({id = "WR", name = "W Range", value = 600, min = 0, max = 600, step = 10})	
	KoreanMechanics.Spell:MenuElement({id = "E", name = "E Key", key = string.byte("E")})
	KoreanMechanics.Spell:MenuElement({id = "ER", name = "E Range", value = 925, min = 0, max = 925, step = 10})
	KoreanMechanics.Spell:MenuElement({type = SPACE, name = "1. Change the E HK in league settings to new key"})
	KoreanMechanics.Spell:MenuElement({type = SPACE, name = "2. Change the HK_E in GOS settings to same key"})		

	KoreanMechanics.Draw:MenuElement({id = "QD", name = "Draw Q range", type = MENU})
    KoreanMechanics.Draw.QD:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    KoreanMechanics.Draw.QD:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    KoreanMechanics.Draw.QD:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
    KoreanMechanics.Draw:MenuElement({id = "WD", name = "Draw W range", type = MENU})
    KoreanMechanics.Draw.WD:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    KoreanMechanics.Draw.WD:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    KoreanMechanics.Draw.WD:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
    KoreanMechanics.Draw:MenuElement({id = "ED", name = "Draw E range", type = MENU})
    KoreanMechanics.Draw.ED:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    KoreanMechanics.Draw.ED:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    KoreanMechanics.Draw.ED:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)}) 
end

function Leblanc:Tick()
	if KoreanMechanics.Enabled:Value() or KoreanMechanics.Hold:Value() then 
		if KoreanMechanics.Spell.Q:Value() then
			self:Q()
		end
		if KoreanMechanics.Spell.W:Value() then
			self:W()
		end
		if KoreanMechanics.Spell.E:Value() then
			self:E()
		end
	end
	if not KoreanMechanics:Value() or KoreanMechanics.Hold:Value() then
		if KoreanMechanics.Spell.E:Value() then
			self:E2()
		end
	end
end

function Leblanc:Q()
	if Ready(_Q) then
local target =  _G.SDK.TargetSelector:GetTarget(800)
if target == nil then return end 	
	Control.CastSpell(HK_Q, target)
end 
end

function Leblanc:W()
	if Ready(_W) then
local target =  _G.SDK.TargetSelector:GetTarget(800)
if target == nil then return end 		
	local pos = GetPred(target, 1600, (0.25 + Game.Latency())/1000)	
	Control.CastSpell(HK_W, pos)
end
end	


function Leblanc:E()
	if Ready(_E) then
local target =  _G.SDK.TargetSelector:GetTarget(1025)
if target == nil then Leblanc:E2() end 	
	local pos = GetPred(target, 1750, (0.25 + Game.Latency())/1000)	
	Control.CastSpell(HK_E, pos)
end
end	

function Leblanc:E2()
	if Ready(_E) then
	Control.CastSpell(HK_E, mousePos)
end
end

function Leblanc:Draw()
	if not myHero.dead then
	   	if KoreanMechanics.Draw.Enabled:Value() then
	   		local textPos = myHero.pos:To2D()
	   		if KoreanMechanics.Enabled:Value() then
				Draw.Text("Aimbot ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000)) 		
			end
			if not KoreanMechanics.Enabled:Value() and KoreanMechanics.Draw.OFFDRAW:Value() then 
				Draw.Text("Aimbot OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 255, 000, 000)) 
			end 
			if KoreanMechanics.Draw.QD.Enabled:Value() then
	    	    Draw.Circle(myHero.pos, KoreanMechanics.Spell.QR:Value(), KoreanMechanics.Draw.QD.Width:Value(), KoreanMechanics.Draw.QD.Color:Value())
	    	end
	    	if KoreanMechanics.Draw.WD.Enabled:Value() then
	    	    Draw.Circle(myHero.pos, 600, KoreanMechanics.Draw.WD.Width:Value(), KoreanMechanics.Draw.WD.Color:Value())
	    	end
	    	if KoreanMechanics.Draw.ED.Enabled:Value() then
	    	    Draw.Circle(myHero.pos, KoreanMechanics.Spell.ER:Value(), KoreanMechanics.Draw.ED.Width:Value(), KoreanMechanics.Draw.ED.Color:Value())
	    	end	    	
	    end		
	end
end

if _G[myHero.charName]() then print("Welcome back " ..myHero.name..", thank you for using my Scripts ^^") end
