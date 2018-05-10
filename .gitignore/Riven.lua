class "Riven"
 
require = 'DamageLib'
require = 'Collision'
require = 'Tpred'

function Riven:__init()
	if myHero.charName ~= "Riven" then return end
PrintChat("[omg BETA]")  
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end


function Riven.LoadSpells()

	Q = {range = 260, delay = 0.267, width = 135, speed = 0}
	W = {range = 125, delay = 0.25, width = 1, speed = 1}
	E = {range = 325, delay = 0.25, width = 1, speed = 1}
	R = {range = 900, delay = 0.25, width = 50, speed = 1600}
end

function Riven:LoadMenu()

--Main Menu

	self.Menu = MenuElement({type = MENU, id = "Riven", name = "RivenOmg"})

--Combo Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "UseR", name = "Use R", value = true})
	self.Menu.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 1, min = 1, max = 5})
	self.Menu.Combo:MenuElement({id = "Exhaust", name = "Use Exhaust", value = false})
	

--Harass Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "Use E", value = true})
	self.Menu.Harass:MenuElement({id = "UseR", name = "Use R", value = true})
	self.Menu.Harass:MenuElement({id = "ER", name = "Min enemies to use R", value = 1, min = 1, max = 5})

--KS
	
	self.Menu:MenuElement({type = MENU, id = "Killsteal", name = "Killsteal"})
	self.Menu.Killsteal:MenuElement({id = "UseR", name = "Use R", value = true})

--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
  	self.Menu.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true})
  	self.Menu.JungleClear:MenuElement({id = "W", name = "Use W", value = true})
  	self.Menu.JungleClear:MenuElement({id = "E", name = "Use E", value = true})
	
 
--Flee or Chase
	self.Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
	self.Menu.Flee:MenuElement({id = "UseQ", name = "Use Q", value = true})
	self.Menu.Flee:MenuElement({id = "UseW", name = "Use W", value = false})
	self.Menu.Flee:MenuElement({id = "UseE", name = "Use E", value = true})

--misc
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})
		if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
			self.Menu.Misc:MenuElement({id = "UseIgnite", name = "Use Ignite", value = true})
		end

--Drawings Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawing Settings"})
	self.Menu.Drawings:MenuElement({id = "drawW", name = "Draw W Range", value = true})
	self.Menu.Drawings:MenuElement({id = "drawQ", name = "Draw Q Range", value = true})
end

function Riven:Tick()
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

function Riven:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawW:Value())then
		Draw.Circle(myHero, W.range, 3, Draw.Color(255, 225, 255, 10))
	end
	if(self.Menu.Drawings.drawQ:Value())then
		Draw.Circle(myHero, 440, 3, Draw.Color(225, 0, 255, 10))
	end
end
--Combo Spacebar
function Riven:Combo()
	if _G.SDK.TargetSelector:GetTarget(700) == nil then return end
	
    if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    	self:CastR(rtarg)
    end

    if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
    	self:CastQ(qtarg)
    end

	if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end
	
	if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)
	end
	
 	if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    	self:Wings(ztarg)
    end

    if self.Menu.Combo.Exhaust:Value() and not self:CanCast(_E) and not self:CanCast(_Q) then
		self:Exhaust(xtarg)
	end
end

function Riven:Harass() 
	if _G.SDK.TargetSelector:GetTarget(700) == nil then return end

	if self.Menu.Harass.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end
	if self.Menu.Harass.UseQ:Value() and self:CanCast(_Q) then
		self:CastQ(qtarg)
	end

	if self.Menu.Harass.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)
	end
		
end

function Riven:JungleClear()
  	if self:GetValidMinion(620) == false then return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 300 or 200 then
			if self:IsValidTarget(minion,620) and myHero.pos:DistanceTo(minion.pos) < 620 and self.Menu.JungleClear.E:Value() and self:CanCast(_E) then
				Control.CastSpell(HK_E, minion.pos)
			break
			end    		
			if self:IsValidTarget(minion,440) and myHero.pos:DistanceTo(minion.pos) < 440 and self.Menu.JungleClear.Q:Value() and self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_Q,minion.pos)
				Control.Attack(minion)
			break
			end
			if self:IsValidTarget(minion,260) and myHero.pos:DistanceTo(minion.pos) < 260 and self.Menu.JungleClear.W:Value() and self:CanCast(_W) then
				Control.CastSpell(HK_W)
			break
			end
		end
	end
end

function Riven:Flee()
	local ftarg = _G.SDK.TargetSelector:GetTarget(1900)
		--if _G.SDK.TargetSelector:GetTarget(1900) == nil then return end   --this will break just fast lane movement if active.
	
		if self.Menu.Flee.UseE:Value() and self:CanCast(_E) then
		Control.CastSpell(HK_E)
		end

		if self.Menu.Flee.UseQ:Value() and self:CanCast(_Q) then
		Control.CastSpell(HK_Q)
		end

		if self.Menu.Flee.UseW:Value() and self:CanCast(_W) then
		Control.CastSpell(HK_W)
		end
end

function Riven:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 620 
end

function Riven:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 620 then
        return true
        end
    	end
    	return false
end

function Riven:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Riven:KS()
	if _G.SDK.TargetSelector:GetTarget(900) == nil then return end
    	local EKS = _G.SDK.TargetSelector:GetTarget(900)
			if EKS and self:CanCast(_R) and self:HasBuff(myHero, "rivenwindslashready") then
				local lvl = myHero:GetSpellData(_R).level
				local RRdmg = (({100, 150, 200})[lvl] + 2.0 * myHero.bonusDamage)  
				local EEdmg = (({100, 150, 200})[lvl] + 1.73 * myHero.bonusDamage)
				local DDdmg = (({100, 150, 200})[lvl] + 1.46 * myHero.bonusDamage)
				local pred=EKS:GetPrediction(R.speed, .25 + Game.Latency()/1000)
				if DDdmg >= EKS.health + EKS.shieldAD and self.Menu.Killsteal.UseR:Value() then
					DisableOrb()
					Control.CastSpell(HK_R,pred)
					EnableOrb()	
				elseif EEdmg >= EKS.health + EKS.shieldAD and self.Menu.Killsteal.UseR:Value() then
					DisableOrb()
					Control.CastSpell(HK_R,pred)
					EnableOrb()
				elseif RRdmg >= EKS.health + EKS.shieldAD and self.Menu.Killsteal.UseR:Value() then
					DisableOrb()
					Control.CastSpell(HK_R,pred)
					EnableOrb()
				end
			end
end

function Riven:Wings(target)
	local ztarg = _G.SDK.TargetSelector:GetTarget(850)
	if ztarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
			if self:HasBuff(myHero, "rivenwindslashready") then
				if ztarg.distance<=900 and ztarg.health/ztarg.maxHealth <= 0.15 then
					local pred=ztarg:GetPrediction(R.del, .25 + Game.Latency()/1000)
					DisableOrb()
					Control.CastSpell(HK_R,pred)
					DelayAction(function() EnableOrb(true) end, 0.3)
				end
			end
	end

end

function Riven:Exhaust(target)
	local xtarg = _G.SDK.TargetSelector:GetTarget(950)
	if self.Menu.Combo.Exhaust:Value() and not self:CanCast(_E) and not self:CanCast(_Q) then
	if xtarg then 
   		if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and self:IsReady(SUMMONER_1) then
       		if self:IsValidTarget(target, 600, true, myHero) and target.health/target.maxHealth <= 0.4 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and self:IsReady(SUMMONER_2) then
        	if self:IsValidTarget(target, 600, true, myHero) and target.health/target.maxHealth <= 0.4 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end
		end
	end
end
end

function Riven:GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0 
end

function Riven:HasBuff(unit, buffname)
for i = 0, unit.buffCount do
local buff = unit:GetBuff(i)
if buff.name == buffname and buff.count > 0 then 
return true
end
end
return false
end

function Riven:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 620 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

LastCancel = Game.Timer()
function Riven:CastQ(target)
    local qrange = 420 --myHero:GetSpellData(_Q).range
    local qtarg = _G.SDK.TargetSelector:GetTarget(qrange)
    if qtarg then
        if qtarg.dead or qtarg.isImmune then return end
        if myHero.pos:DistanceTo(qtarg.pos) < 420 and self:HasBuff(myHero, "rivenwindslashready") then    --myHero.range
            if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
                local pred=qtarg:GetPrediction(Q.speed, 0.267 + Game.Latency()/1000)
                DisableOrb()
                Control.CastSpell(HK_Q,qtarg)
                Control.Attack(qtarg)
                DelayAction(function() EnableOrb() end, 0.3)
                if Game.Timer() - LastCancel > 0.13 then
                LastCancel = Game.Timer()
                    DelayAction(function()
                    local Vec = Vector(myHero.pos):Normalized() * - (myHero.boundingRadius*1.1)
                    Control.Move(Vec)
                    end, (0.267 + Game.Latency()/1000))
                end
            end
        else
        	if myHero.pos:DistanceTo(qtarg.pos) < 275 and not self:HasBuff(myHero, "rivenwindslashready") then    --Q without buff less range wont chase with q but aa more reliable
            	if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
                	local pred=qtarg:GetPrediction(Q.speed, 0.267 + Game.Latency()/1000)
                	DisableOrb()
                	Control.CastSpell(HK_Q,qtarg)
                	Control.Attack(qtarg)
                	DelayAction(function() EnableOrb() end, 0.3)
                	if Game.Timer() - LastCancel > 0.13 then
                	LastCancel = Game.Timer()
                    	DelayAction(function()
                    	local Vec = Vector(myHero.pos):Normalized() * - (myHero.boundingRadius*1.1)
                    	Control.Move(Vec)
                    	end, (0.267 + Game.Latency()/1000))
                	end
            	end
        	end
        end
    end
end

function Riven:CastW(target) 
	local wtarg = _G.SDK.TargetSelector:GetTarget(460)
	if wtarg and self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		if myHero.pos:DistanceTo(wtarg.pos) < 260 then
			Control.CastSpell(HK_W)
			Control.Attack(wtarg)
		end
	end
end
				

function Riven:CastE(target)
	local etarg = _G.SDK.TargetSelector:GetTarget(620)
	if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		if myHero.pos:DistanceTo(etarg.pos) < 420 then
			local pred=etarg:GetPrediction(E.speed,.25 + Game.Latency()/1000)
			Control.CastSpell(HK_E,pred)
			Control.Attack(etarg)
		end
	end
end


function Riven:CastR(target)
    local rtarg = _G.SDK.TargetSelector:GetTarget(420)
    if rtarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) and not self:HasBuff(myHero, "rivenwindslashready") then
    	if self:CountEnemys(260) >= self.Menu.Combo.ER:Value() then
    		Control.CastSpell(HK_R)
    		Control.Attack(rtarg)
      	end
    end
end

--KS
function Riven:Misc()
	if _G.SDK.TargetSelector:GetTarget(650) == nil then return end
     	for i = 1,Game.HeroCount() do
        local Enemy = Game.Hero(i)
            if myHero:GetSpellData(5).name == "SummonerDot" and self.Menu.Misc.UseIgnite:Value() and self:IsReady(SUMMONER_2) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_2, Enemy)
                    return;
                end
            end
            if myHero:GetSpellData(4).name == "SummonerDot" and self.Menu.Misc.UseIgnite:Value() and self:IsReady(SUMMONER_1) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_1, Enemy)
                    return;
                end
            end
        end
end

function DisableOrb()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)
	end
end

function EnableOrb()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end
end

function Riven:GetAllyHeroes()
	local _AllyHeroes
	if _AllyHeroes then return _AllyHeroes end
	_AllyHeroes = {}
	for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isAlly then
      table.insert(_AllyHeroes, unit)
    end
	end
	return _AllyHeroes
end

function Riven:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Riven:CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	Riven()
end
