class "Irelia"

require = 'DamageLib'
require = 'Collision'
require = 'Tpred'

function Irelia:__init()
	if myHero.charName ~= "Irelia" then return end
PrintChat("Test Irelia]")  
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end

	 
   
function Irelia:LoadSpells()

	Q = {Range = 650, Width = 0, Delay = 0.35, Speed = 2200, Collision = false, aoe = false, Type = "line"}
	W = {Range = 130, Width = 0, Delay = 0.30, Speed = 1000, Collision = false, aoe = false, Type = "line"}
	E = {Range = 325, Width = 70, Delay = 0.25, Speed = 1200, Collision = false, aoe = false, Type = "line"}
	R = {Range = 1000, Width = 0, Delay = 0.25, Speed = 1200, Collision = false, aoe = false, Type = "line"}

end

function Irelia:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "Irelia", name = "Test Irelia"})

    --[[Combo]]
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
    --[[Harass]]
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Menu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
    self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Farm]]
    self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    self.Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
    self.Menu.Farm:MenuElement({id = "FarmW", name = "Use W", value = true})
    self.Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
    self.Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Misc]]
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})

    --[[Draw]]
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})

    PrintChat("[Irelia Test] Menu Loaded")
end

function Irelia:Tick()
	if myHero.dead then return end
if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			self:Harass()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			self:JungleClear()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			self:Flee()	
		end
	self:Misc()
	self:KS()
end

function Irelia:Draw()
if Ready(_Q) and self.Drawings.Q.Enabled:Value() then Draw.Circle(myHero.pos, Q.Range, self.Drawings.Q.Width:Value(), self.Drawings.Q.Color:Value()) end
if Ready(_E) and self.Drawings.E.Enabled:Value() then Draw.Circle(myHero.pos, E.Range, self.Drawings.E.Width:Value(), self.Drawings.E.Color:Value()) end
if Ready(_R) and self.Drawings.R.Enabled:Value() then Draw.Circle(myHero.pos, R.Range, self.Drawings.R.Width:Value(), self.Drawings.R.Color:Value()) end

		if self.Drawings.DrawDamage:Value() then
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
	if self.Combo.UseQ:Value() and target and Ready(_Q) then
		if EnemyInRange(Q.Range) and GetDistance(myHero.pos, target.pos) > 130 then 
		    Control.CastSpell(HK_Q,target)
			end
		end
end

function Irelia:ComboW()
	local target = CurrentTarget(W.Range)
	if target == nil then return end
	if self.Combo.UseW:Value() and target and Ready(_W) then
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
	if self.Combo.UseE:Value() and target and Ready(_E) then
		if EnemyInRange(E.Range) and self.Combo.EStun:Value() == false then
			    Control.CastSpell(HK_E,target)
		elseif EnemyInRange(E.Range) and self.Combo.EStun:Value() == true then
			if target.health >= myHero.health then
				Control.CastSpell(HK_E,target)
			end
		end
	end
end

function Irelia:RKey()
	local target = CurrentTarget(R.Range)
	if target == nil then return end
	if self.Combo.RKey:Value() and target and Ready(_R) then
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
	if self.Harass.UseQ:Value() and target and Ready(_Q) then
		if EnemyInRange(Q.Range) and GetDistance(myHero.pos, target.pos) > 130 then 
		    Control.CastSpell(HK_Q,target)
			end
		end
end

function Irelia:HarassE()
	local target = CurrentTarget(E.Range)
	if target == nil then return end
	if self.Harass.UseE:Value() and target and Ready(_E) then
		if EnemyInRange(E.Range) then 
		    Control.CastSpell(HK_E,target)
		end
	end
end
	
function Irelia:HarassW()
	local target = CurrentTarget(W.Range)
	if target == nil then return end
	if self.Harass.UseW:Value() and target and Ready(_W) then
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
	if self.Killsteal.UseQ:Value() and self.Killsteal.KS["KS"..target.charName]:Value() and target and Ready(_Q) then
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
	if self.Killsteal.UseE:Value() and self.Killsteal.KS["KS"..target.charName]:Value() and target and Ready(_E) then
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
	if self.Killsteal.UseR:Value() and self.Killsteal.KS["KS"..target.charName]:Value() and target and Ready(_R) then
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
