class "Irelia"

require = 'DamageLib'
require = 'Collision'
require = 'Tpred'


function Irelia:LoadSpells()

	Q = {Range = 650, Width = 0, Delay = 0.35, Speed = 2200, Collision = false, aoe = false, Type = "line"}
	W = {Range = 130, Width = 0, Delay = 0.30, Speed = 1000, Collision = false, aoe = false, Type = "line"}
	E = {Range = 325, Width = 70, Delay = 0.25, Speed = 1200, Collision = false, aoe = false, Type = "line"}
	R = {Range = 1000, Width = 0, Delay = 0.25, Speed = 1200, Collision = false, aoe = false, Type = "line"}

end

function Irelia:LoadMenu()

--Main Menu

self.Menu = MenuElement({type = MENU, id = "Irelia", name = "BunnyIrelia"})

--Combo Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Irelia", name = "BunnyIrelia"})
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Combo:MenuElement({id = "EStun", name = "Only E to Stun?", value = true})
	self.Menu.Combo:MenuElement({id = "RKey", name = "R Key", key = string.byte("T")})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})	
	
  
  --Harass Settings Menu
  
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("V")})


--Lasthit Settings Menu

	self.Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	self.Menu.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
  
  
	--Gapclose Settings Menu
  
	self.Menu:MenuElement({id = "Gapclose", name = "Gapclose", type = MENU})
	self.Menu.Gapclose:MenuElement({id = "QCombo", name = "Q on Combo", value = true})
	self.Menu.Gapclose:MenuElement({id = "QKS", name = "Q > Minion > KS Target", value = true})
  
  
	--KS
  
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "KS", name = "Enemies to use:", type = MENU})
	for i, hero in pairs(GetEnemyHeroes()) do
	self.Menu.Killsteal.KS:MenuElement({id = "KS"..hero.charName, name = ""..hero.charName, value = true})
	end
	self.Menu.Killsteal:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Killsteal:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Killsteal:MenuElement({id = "UseR", name = "Use R? Calculates all 4!", value = true})
  
  
  --Drawings Settings Menu
	
	self.Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	--Q
	self.Menu.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
  self.Menu.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
  self.Menu.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
  self.Menu.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--W
	-- self.Menu.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU})
    -- self.Menu.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    -- self.Menu.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    -- self.Menu.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--E
	self.Menu.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU})
    self.Menu.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    self.Menu.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--R
	self.Menu.Drawings:MenuElement({id = "R", name = "Draw R range", type = MENU})
    self.Menu.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	
	self.Menu.Drawings:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
   self.Menu.Drawings:MenuElement({id = "HPColor", name = "HP Color", color = Draw.Color(200, 255, 255, 255)})

	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


function Irelia:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	gsoSDK.Menu = MenuElement({name = "BunnyIrelia", id = "Irelia"})
            __gsoLoader()
            gsoSDK.Orbwalker:SetSpellMoveDelays( { q = 0.2, w = 0.2, e = 0.2, r = 0.2 } )
            gsoSDK.Orbwalker:SetSpellAttackDelays( { q = 0.33, w = 0.33, e = 0.33, r = 0.33 } )
            self:SetSpellData()
            self:CreateMenu()
            self:AddTickEvent()
            gsoSDK.Orbwalker:CanAttackEvent(function()
                  -- LastHit, LaneClear
                  if not gsoSDK.Menu.orb.keys.combo:Value() and not gsoSDK.Menu.orb.keys.harass:Value() then
                        return true
                  end


function Irelia:Tick()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true or ExtLibEvade and ExtLibEvade.Evading == true then return end
	if AIO.Combo.comboActive:Value() then
		self:ComboQ()
		self:ComboW()
		self:ComboE()
	end
	if AIO.Lasthit.lasthitActive:Value() then
		self:Lasthit()
	end
	if AIO.Harass.harassActive:Value() then
		self:HarassE()
		self:HarassW()
	end
	
	self:KillstealQ()
	self:KillstealE()
	self:KillstealR()
	
	self:RKey()
end

function Irelia:Draw()
if Ready(_Q) and AIO.Drawings.Q.Enabled:Value() then Draw.Circle(myHero.pos, Q.Range, AIO.Drawings.Q.Width:Value(), AIO.Drawings.Q.Color:Value()) end
if Ready(_E) and AIO.Drawings.E.Enabled:Value() then Draw.Circle(myHero.pos, E.Range, AIO.Drawings.E.Width:Value(), AIO.Drawings.E.Color:Value()) end
if Ready(_R) and AIO.Drawings.R.Enabled:Value() then Draw.Circle(myHero.pos, R.Range, AIO.Drawings.R.Width:Value(), AIO.Drawings.R.Color:Value()) end

		if AIO.Drawings.DrawDamage:Value() then
		for i, hero in pairs(GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (Ready(_Q) and Irelia:QDMG() or 0)
				local WDamage = (Ready(_W) and Irelia:WDMG() or 0)
				local EDamage = (Ready(_E) and Irelia:EDMG() or 0)
				local RDamage = (Ready(_R) and Irelia:RDMG() or 0)
				local AA = (getdmg("AA",hero,myHero) or 0) * 5
								
				local damage = QDamage + WDamage + EDamage + RDamage + AA
				if damage > hero.health then
					Draw.Text("KILLABLE", 30, hero.pos2D.x - 55, hero.pos2D.y - 190,Draw.Color(200, 255, 87, 51))	
					
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, AIO.Drawings.HPColor:Value())
				end
			end
		end	
	end
		if Ready(_Q) then
			local target = CurrentTarget(Q.Range)
			if target == nil then return end
			if (TPred) then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
				Draw.Circle(castpos, 60, 3, Draw.Color(200, 255, 255, 255))
			end
		end
end

function Irelia:QDMG()
    local level = myHero:GetSpellData(_Q).level
    local damage = ({20, 50, 80, 110, 140})[level] + 1.2 * myHero.totalDamage
	return damage
end

function Irelia:WDMG()
    local level = myHero:GetSpellData(_W).level
    local damage = ({15, 30, 45, 60, 75})[level]
	return damage
end

function Irelia:EDMG()
    local level = myHero:GetSpellData(_E).level
    local damage = ({80, 120, 160, 200, 240})[level] + 0.5 * myHero.ap
	return damage
end

function Irelia:RDMG()
    local level = myHero:GetSpellData(_R).level
    local damage = ({320, 480, 640})[level] + 0.5 * myHero.ap + 0.7 * myHero.totalDamage
	return damage
end

function Irelia:IsImmobileTarget(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.type == 28 or buff.type == 21 or buff.type == 22) and buff.count > 0 and Game.Timer() < buff.expireTime - 0.5 then
				return true
			end
		end
		return false	
end

function Irelia:ComboQ()
	local target = CurrentTarget(Q.Range)
	if target == nil then return end
	if AIO.Combo.UseQ:Value() and target and Ready(_Q) then
		if EnemyInRange(Q.Range) and GetDistance(myHero.pos, target.pos) > 130 then 
		    Control.CastSpell(HK_Q,target)
			end
		end
end

function Irelia:ComboW()
	local target = CurrentTarget(W.Range)
	if target == nil then return end
	if AIO.Combo.UseW:Value() and target and Ready(_W) then
		if EnemyInRange(W.Range) then
			if GetDistance(myHero.pos, target.pos) < 130 then
			    Control.CastSpell(HK_W)
			end
		end
	end
end

function Irelia:ComboE()
	local target = CurrentTarget(E.Range)
	if target == nil then return end
	if AIO.Combo.UseE:Value() and target and Ready(_E) then
		if EnemyInRange(E.Range) and AIO.Combo.EStun:Value() == false then
			    Control.CastSpell(HK_E,target)
		elseif EnemyInRange(E.Range) and AIO.Combo.EStun:Value() == true then
			if target.health >= myHero.health then
				Control.CastSpell(HK_E,target)
			end
		end
	end
end

function Irelia:RKey()
	local target = CurrentTarget(R.Range)
	if target == nil then return end
	if AIO.Combo.RKey:Value() and target and Ready(_R) then
		if EnemyInRange(R.Range) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, R.Delay , R.Width, R.Range, R.Speed, myHero.pos, R.ignorecol, R.Type )
			if (HitChance > 0 ) then
			    Control.CastSpell(HK_R,castpos)
			end
		end
	end
end

function Irelia:HarassQ()
	local target = CurrentTarget(Q.Range)
	if target == nil then return end
	if AIO.Harass.UseQ:Value() and target and Ready(_Q) then
		if EnemyInRange(Q.Range) and GetDistance(myHero.pos, target.pos) > 130 then 
		    Control.CastSpell(HK_Q,target)
			end
		end
end

function Irelia:HarassE()
	local target = CurrentTarget(E.Range)
	if target == nil then return end
	if AIO.Harass.UseE:Value() and target and Ready(_E) then
		if EnemyInRange(E.Range) then 
		    Control.CastSpell(HK_E,target)
		end
	end
end
	
function Irelia:HarassW()
	local target = CurrentTarget(W.Range)
	if target == nil then return end
	if AIO.Harass.UseW:Value() and target and Ready(_W) then
		if EnemyInRange(W.Range) then
			if GetDistance(myHero.pos, target.pos) < 130 then
			    Control.CastSpell(HK_W)
			end
		end
	end
end

function Irelia:Lasthit()
	if Ready(_Q) then
  		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local Qdamage = self:QDMG()
			if myHero.pos:DistanceTo(minion.pos) < Q.Range and AIO.Lasthit.UseQ:Value() and minion.isEnemy and not minion.dead then
				if Qdamage >= HpPred(minion,1) then
				Control.CastSpell(HK_Q,minion)
				end
			end
		end
	end
end

function Irelia:KillstealQ()
	local target = CurrentTarget(Q.Range)
	if target == nil then return end
	if AIO.Killsteal.UseQ:Value() and AIO.Killsteal.KS["KS"..target.charName]:Value() and target and Ready(_Q) then
		if EnemyInRange(Q.Range) then 
		   	local Qdamage = Irelia:QDMG()
			if Qdamage >= HpPred(target,1) + target.hpRegen * 1 then
				CastSpell(HK_Q, target)
				end
			end
		end
	end
	
function Irelia:KillstealE()
	local target = CurrentTarget(E.Range)
	if target == nil then return end
	if AIO.Killsteal.UseE:Value() and AIO.Killsteal.KS["KS"..target.charName]:Value() and target and Ready(_E) then
		if EnemyInRange(E.Range) then 
		   	local Edamage = Irelia:EDMG()
			if Edamage >= HpPred(target,1) + target.hpRegen * 1 then
				CastSpell(HK_E, target)
				end
			end
		end
	end

function Irelia:KillstealR()
	local target = CurrentTarget(R.Range)
	if target == nil then return end
	if AIO.Killsteal.UseR:Value() and AIO.Killsteal.KS["KS"..target.charName]:Value() and target and Ready(_R) then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, R.Delay , R.Width, R.Range, R.Speed, myHero.pos, R.ignorecol, R.Type )
		if EnemyInRange(R.Range) then 
		   	local Rdamage = Irelia:RDMG()
			if Rdamage >= HpPred(target,1) + target.hpRegen * 1 then
				if (HitChance > 0 ) then
				CastSpell(HK_R, castpos)
				end
			end
		end
	end
end
