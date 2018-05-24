local Heroes = {"Riven","Olaf","Irelia","Xerath","Ryze","Kled","Cassiopeia","Malzahar","Lucian","Morgana","Twitch","Jhin","Ashe","Alistar","Ahri","Azir","Blitzcrank","Draven","Ezreal","Fizz","Jinx","Kalista","KogMaw","Leblanc","LeeSin","Lux","Nasus","Nidalee","Orianna","Syndra","Teemo","Thresh","Tristana","Caitlyn","Veigar","Yasuo","Zed", "Annie","Akali"}
if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"
require "MapPosition"

local AIOIcon = "https://raw.githubusercontent.com/Kypos/GOS-External/master/misc/AIOIcon.png"
local EssentialsIcon = "https://raw.githubusercontent.com/Kypos/GOS-External/master/misc/Essentials.png"

local _wards = {2055, 2049, 2050, 2301, 2302, 2303, 3340, 3361, 3362, 3711, 1408, 1409, 1410, 1411, 2043, 2055}
local ultimocast = 0
local Position=mousePos
local RedPos = {Vector(14300,172,14380)}
local BluePos = {Vector(408,183,418)}
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local barHeight = 8
local barWidth = 103
local barXOffset = 24
local barYOffset = -8
local Version,Author,LVersion = "v0.4","Kypos","8.5"
local EDMG = {}

local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
hkitems = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6,[ITEM_7] = HK_ITEM_7, [_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R }


if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
	PrintChat("TPred library loaded")
elseif FileExist(COMMON_PATH .. "Collision.lua") then
	require 'Collision'
	PrintChat("Collision library loaded")
end

function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end

function GetPercentHP(unit)
  return 100 * unit.health / unit.maxHealth
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

function DisableAA()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetAttack(false)
		end
end

function EnableAA()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetAttack(true)	
		end
end

function DisableMovement()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(false)
		end
end

function EnableMovement()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(true)
		end
end

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end


function EnemyInRange(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

local function CircleCircleIntersection(c1, c2, r1, r2) 
	local D = GetDistance(c1, c2)
	if D > r1 + r2 or D <= math.abs(r1 - r2) then return nil end 
	local A = (r1 * r2 - r2 * r1 + D * D) / (2 * D) 
	local H = math.sqrt(r1 * r1 - A * A)
	local Direction = (c2 - c1):Normalized() 
	local PA = c1 + A * Direction 
	local S1 = PA + H * Direction:Perpendicular() 
	local S2 = PA - H * Direction:Perpendicular() 
	return S1, S2 
end	

function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

function EnemiesNear(pos,range)
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if ValidTarget(hero,range + hero.boundingRadius) and hero.isEnemy and not hero.dead then
			N = N + 1
		end
	end
	return N	
end

function GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

function GetAllyHeroes()
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Ready(spellSlot)
	return IsReady(spellSlot)
end

function EnableMovement()
	SetMovement(true)
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function CastSpell(spell,pos)
	local customcast = AIO.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = AIO.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				SetMovement(false)
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function GetDistanceSqrYas(a, b)
if a.z ~= nil and b.z ~= nil then
    local x = (a.x - b.x);
    local z = (a.z - b.z);
    return x * x + z * z;
else
  local x = (a.x - b.x);
  local y = (a.y - b.y);
  return x * x + y * y;
end
end

local sqrt = math.sqrt
local function GetDistanceSqr(p1, p2)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    return (dx * dx + dz * dz)
end

local function GetDistance(p1, p2)
    return sqrt(GetDistanceSqr(p1, p2))
end

local function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local function ClosestToMouse(p1, p2) 
	if GetDistance(mousePos, p1) > GetDistance(mousePos, p2) then return p2 else return p1 end
end

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in pairs(objects) do
        local hit = CountObjectsNearPos(object.pos, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object.pos
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in pairs(objects) do
        if GetDistanceSqr(pos, object.pos) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function GetHeroByHandle(handle)
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h.handle == handle then
			return h
		end
	end
end


-- CHAMPS:

class "Riven"

local Q3Icon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/4/4b/Steel_Tempest_3.png"

function Riven:LoadSpells()

	Q = {Range = 780, Width = 0, Delay = 0,30, Speed = 0, Collision = false, aoe = false, Type = "line"}
	W = {Range = 270, Width = 0, Delay = 0.25, Speed = 1500, Collision = false, aoe = false, Type = "circular"}
	E = {Range = 325, Width = 0, Delay = 0.25, Speed = 1450, Collision = false, aoe = false, Type = "line"}
	R = {Range = 1150, Width = 0, Delay = 0.20, Speed = 1200, Collision = false, aoe = false, Type = "line"}

end

function Riven:LoadMenu()
	AIO = MenuElement({type = MENU, id = "Riven", name = "Kypos AIO: Riven", leftIcon = AIOIcon})
	AIO:MenuElement({id = "Combo", name = "Combo", type = MENU})
	AIO.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Combo:MenuElement({id = "UseW", name = "W", value = true})
	AIO.Combo:MenuElement({id = "UseE", name = "E", value = false})
	AIO.Combo:MenuElement({id = "UseR", name = "R", value = false})
	AIO.Combo:MenuElement({id = "UseRHealth", name = "Use R if enemy health is below %",value=60,min=0,max=100})
	AIO.Combo:MenuElement({id = "ApproachTypes", name = "Approach Logic", value = 1,drop = {"W>Q>AA..", "E>W>Q>AA..","E>1Q>W>Q>.."}})
	AIO.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	AIO:MenuElement({id = "Burst", name = "Burst Combos", type = MENU})
	AIO.Burst:MenuElement({id = "BurstTypeKey1", name = "Burst Logic", value = 1,drop = {"The Shy Combo", "X","X","X"}})
	AIO.Burst:MenuElement({id = "burstkey1", name = "Burst key 1", key = string.byte("T")})
	AIO.Burst:MenuElement({id = "blank", type = SPACE , name = ""})
	AIO.Burst:MenuElement({id = "BurstTypeKey2", name = "Burst Logic", value = 1,drop = {"R>E>Q3>W>AA", "X","X","X"}})
	AIO.Burst:MenuElement({id = "burstkey2", name = "Burst key 2", key = string.byte("S")})
	AIO.Burst:MenuElement({id = "blank", type = SPACE , name = ""})
	AIO.Burst:MenuElement({id = "BurstTypeKey3", name = "Burst Logic", value = 1,drop = {"R>E>Q3>W>AA", "X","X","X"}})
	AIO.Burst:MenuElement({id = "burstkey3", name = "Burst key 3", key = string.byte("Y")})
	
	AIO:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	AIO.Killsteal:MenuElement({id = "RR", name = "Enemies to KS:", type = MENU})
	for i, hero in pairs(GetEnemyHeroes()) do
	AIO.Killsteal.RR:MenuElement({id = "KS"..hero.charName, name = ""..hero.charName, value = true})
	end
	AIO.Killsteal:MenuElement({id = "UseR", name = "R2", value = true})
	AIO.Killsteal:MenuElement({id = "UseW", name = "W", value = true})
	
	AIO:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	--Q
	AIO.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
    AIO.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--W
	AIO.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU})
    AIO.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--E
	AIO.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU})
    AIO.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--R
	AIO.Drawings:MenuElement({id = "R", name = "Draw R range", type = MENU})
    AIO.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	
	AIO.Drawings:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
    AIO.Drawings:MenuElement({id = "HPColor", name = "HP Color", color = Draw.Color(200, 255, 255, 255)})

	AIO:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	AIO:MenuElement({id = "delay", name = "Custom spellcast delay", value = 100, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
	AIO:MenuElement({id = "blank", type = SPACE , name = ""})
	AIO:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	AIO:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


function Riven:__init()
	local flashslot
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
	end
end

function Riven:Tick()
        if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true or ExtLibEvade and ExtLibEvade.Evading == true then return end
	if AIO.Combo.comboActive:Value() then
		self:ApproachTypes()
	end	
	if AIO.Burst.burstkey1:Value() then
		self:BurstCombos()
	end
		self:RksKnockedback()
		self:KillstealW()
		self:RKSNormal()
		self:test()
		
		flashslot = self:getFlash()

end

function Riven:getFlash()
	for i = 1, 5 do
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
			return SUMMONER_1
		end
		if myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
			return SUMMONER_2
		end
	end
	return 0
end

function Riven:Draw()
if Ready(_Q) and AIO.Drawings.Q.Enabled:Value() then Draw.Circle(myHero.pos, Q.Range, AIO.Drawings.Q.Width:Value(), AIO.Drawings.Q.Color:Value()) end
if Ready(_W) and AIO.Drawings.W.Enabled:Value() then Draw.Circle(myHero.pos, W.Range, AIO.Drawings.E.Width:Value(), AIO.Drawings.W.Color:Value()) end
if Ready(_E) and AIO.Drawings.E.Enabled:Value() then Draw.Circle(myHero.pos, E.Range, AIO.Drawings.E.Width:Value(), AIO.Drawings.E.Color:Value()) end
if Ready(_R) and AIO.Drawings.R.Enabled:Value() then Draw.Circle(myHero.pos, R.Range, AIO.Drawings.R.Width:Value(), AIO.Drawings.R.Color:Value()) end
			if AIO.Drawings.DrawDamage:Value() then
		for i, hero in pairs(GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (Ready(_Q) and getdmg("Q",hero,myHero) or 0) - hero.armor
				local WDamage = (Ready(_W) and getdmg("W",hero,myHero) or 0) - hero.armor
				local RDamage = (Ready(_R) and getdmg("R",hero,myHero) or 0) - hero.armor
				local AA = Riven:AADMG() - hero.armor
				local damage = QDamage + WDamage + RDamage + AA
				if damage > hero.health then
					Draw.Text("KILLABLE", 28, hero.pos2D.x - 40, hero.pos2D.y - 215,Draw.Color(200, 41, 219, 32))	
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, AIO.Drawings.HPColor:Value())
				end
			end
		end	
	end
		if Ready(_R) then
			local target = CurrentTarget(R.Range)
			if target == nil then return end
			local temppred
			if (TPred) then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(target, R.Delay , R.Width, R.Range,R.Speed, myHero.pos, R.ignorecol, R.Type )
				Draw.Circle(castpos, 60, 3, Draw.Color(200, 255, 255, 255))
			end
		end
end

function Riven:IsImmobileTarget(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24) and buff.count > 0 then
				return true
			end
		end
		return false	
	end

function Riven:IsKnockedUp(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 29 or buff.type == 30 or buff.type == 39) and buff.count > 0 then
				return true
			end
		end
		return false	
	end
	
function Riven:CountKnockedUpEnemies(range)
		local count = 0
		local rangeSqr = range * range
		for i = 1, Game.HeroCount()do
		local hero = Game.Hero(i)
			if hero.isEnemy and hero.alive and GetDistanceSqrYas(myHero.pos, hero.pos) <= rangeSqr then
			if Riven:IsKnockedUp(hero)then
			count = count + 1
    end
  end
end
return count
end


-- function CastQ(target)
    -- local target = CurrentTarget(335)
    -- if target == nil then return end
	    -- if myHero.attackData.state == STATE_WINDDOWN and myHero.attackData.windDownTime >= 0.0000000000001 then
			    -- DisableOrb()
				-- Control.CastSpell(HK_Q,target)
				-- DelayAction(function() EnableOrb() end, 0.1)
		-- elseif myHero.attackData.windUpTime >= 0.0000000000010 then
				-- Control.Attack(target)
		-- end
	-- end


-- function CastQMinion(minion)
	-- for i = 1, Game.MinionCount() do
	-- local minion = Game.Minion(i)
	-- if minion and minion.team == 300 or minion.team ~= myHero.team then
	    		-- local WINDDOWN = myHero.attackData.state == STATE_WINDDOWN
		-- local WINDUP = myHero.attackData.state == STATE_WINDUP
		-- local WINUPTIME = myHero.attackData.windUpTime
		-- local WINDOWNTIME = myHero.attackData.windDownTime
		-- local ANIMATIONTIME = myHero.attackData.animationTime
		
		-- local x = myHero.attackData.animationTime
		
	    -- if WINDDOWN and WINDOWNTIME >= 0.0000000000001 then
				-- DisableOrb()
				-- Control.CastSpell(HK_Q,minion)
		-- elseif ANIMATIONTIME >= WINUPTIME + 0.0000000000001 then
				-- Control.Move(minion.pos)
				-- print("moved")
		-- elseif ANIMATIONTIME >= WINDOWNTIME + 0.0000000000001 then
				-- Control.Attack(minion)
				-- DelayAction(function() EnableOrb() end, 0.45)
		-- end
	-- end
	-- end
	-- end
	
	-- function CastQMinion(minion)
	-- for i = 1, Game.MinionCount() do
	-- local minion = Game.Minion(i)
	-- if minion and minion.team == 300 or minion.team ~= myHero.team then
	    -- if myHero.attackData.state == STATE_WINDDOWN and myHero.attackData.windDownTime >= 0.0000000000001 then
			    -- DisableOrb()
				-- Control.CastSpell(HK_Q,minion)
				-- DelayAction(function() EnableOrb() end, 0.1)
		-- elseif myHero.attackData.windUpTime >= 0.0000000000010 then
		-- local Vec = Vector(myHero.pos):Normalized() * - (myHero.boundingRadius*1.1)
			    -- Control.Move(Vec)
				-- print("moved")
				-- Control.Attack(minion)
		-- end
	-- end
	-- end
	-- end

function Riven:test()
-- print("")

-- local q = false
-- local timer = 0
		-- if q == false and myHero:GetSpellData(Q).toggleState == 2 then
  -- timer = Game.Timer()
  -- q = true
-- end
		-- if q == true and myHero:GetSpellData(Q).toggleState == 1 then
  -- print(Game.Timer() - timer)
  -- q = false
-- end

-- print(myHero:GetSpellData(_Q).range)
-- print(myHero.attackData.endTime)
-- if myHero.attackData.state == STATE_WINDUP then
-- if myHero.attackData.windUpTime > 0.21577 then
-- Control.Move(mousePos)
-- print("finish aa")
end
-- end
-- end
-- end
-- end

	-- AIO:MenuElement({id = "Burst", name = "Burst Combos", type = MENU})
	-- AIO.Burst:MenuElement({id = "BurstTypeKey1", name = "Burst Logic", value = 1,drop = {"The Shy Combo", "X","X","X"}})
	-- AIO.Burst:MenuElement({id = "burstkey1", name = "Burst key 1", key = string.byte("T")})
	-- AIO.Burst:MenuElement({id = "blank", type = SPACE , name = ""})
	-- AIO.Burst:MenuElement({id = "BurstTypeKey2", name = "Burst Logic", value = 1,drop = {"R>E>Q3>W>AA", "X","X","X"}})
	-- AIO.Burst:MenuElement({id = "burstkey2", name = "Burst key 2", key = string.byte("S")})
	-- AIO.Burst:MenuElement({id = "blank", type = SPACE , name = ""})
	-- AIO.Burst:MenuElement({id = "BurstTypeKey3", name = "Burst Logic", value = 1,drop = {"R>E>Q3>W>AA", "X","X","X"}})
	-- AIO.Burst:MenuElement({id = "burstkey3", name = "Burst key 3", key = string.byte("Y")})
	
function Riven:BurstCombos(target)
local mode = AIO.Burst.BurstTypeKey1:Value() 
	if mode == 1 then
		self:TheShyCombo()
	elseif mode == 2 then
		self:Approach2E()	
		elseif mode == 3 then
		self:Approach3E()

end
end

function Riven:TheShyCombo()
		local WINDDOWN = myHero.attackData.state == STATE_WINDDOWN	-- Finish AA
		local WINDOWNTIME = myHero.attackData.windDownTime			-- 
		local Hydra = GetInventorySlotItem(3074)

local target = CurrentTarget(E.Range+400)
if target == nil then return end
		if Ready(_E) and Ready(_R) and Ready(_Q) and Ready(_W) and Ready(flashslot) then
			Control.CastSpell(HK_E, target)
		-- if not Ready(_E) then
			Control.CastSpell(HK_R)
		-- if myHero:GetSpellData(R).name == "RivenIzunaBlade" then
			-- Control.CastSpell(flashslot == SUMMONER_1 and HK_SUMMONER_1 or HK_SUMMONER_2,target)
		-- if not Ready(flashslot) and GetDistance(myHero.pos,target.pos) < W.Range then
			-- Control.CastSpell(HK_W)
		-- if not Ready(_W) then
			-- Control.Attack(target)
			-- print("attacked target")
		-- if WINDDOWN and WINDOWNTIME > 0.0000000005000 then	
		-- if Hydra and GetDistance(myHero.pos,target.pos) < 350 then
			-- Control.CastSpell(HKITEM[Hydra])
		-- if myHero:GetSpellData(R).name == "RivenIzunaBlade" and WINDDOWN and WINDOWNTIME > 0.0000000005000 then
			-- Control.CastSpell(HK_R, target)
		-- if not Ready(_R) then
			-- self:CastQ()
end
end
-- end
-- end
-- end
-- end
-- end
-- end
-- end
-- end

			
	
	
function CastQ(target)
    local target = CurrentTarget(500)
    if target == nil then return end
																	-- AA > Q > Move > ..
		local WINDDOWN = myHero.attackData.state == STATE_WINDDOWN	-- Finish AA
		local WINDUP = myHero.attackData.state == STATE_WINDUP 		-- About to AA
		local ATTACK = myHero.attackData.state == STATE_ATTACK		-- ATTACK
		local WINUPTIME = myHero.attackData.windUpTime				-- 
		local WINDOWNTIME = myHero.attackData.windDownTime			-- 
		local ANIMATIONTIME = myHero.attackData.animationTime		-- Animation time
	    if WINDDOWN and WINDOWNTIME > 0.0000000005000 then	
				DisableMovement()
				Control.CastSpell(HK_Q,target)
		-- elseif WINDDOWN and WINDOWNTIME > 0.0000000009000 then
				DelayAction(function() 
				Control.Move(target.pos)
				EnableMovement()
				Control.Attack(target)
				print("moved")
				end, 0.5)
				DelayAction(function() EnableMovement() end, 1.5)
	    -- if WINDDOWN and WINDOWNTIME >= 0.000030 then
				-- Control.Move(target.pos)
				-- print("moved")
		-- elseif ANIMATIONTIME >= WINDOWNTIME + 0.0000000000001 then
		end
		end

function Riven:ApproachTypes(target)
local mode = AIO.Combo.ApproachTypes:Value() 
	if mode == 1 then
		self:ApproachW()
		self:ApproachQ()
	elseif mode == 2 then
		self:Approach2E()
		self:Approach2W()
		self:ApproachQ()	
		elseif mode == 3 then
		self:Approach3E()
		self:Approach31Q()
		self:ApproachW()
		self:ApproachQ()
end
end

function Riven:ApproachQ()
    local target = CurrentTarget(335)
    if target == nil then return end
    if AIO.Combo.UseQ:Value() and target and Ready(_Q) then		
	    if EnemyInRange(335) then
			CastQ()
		end    
	end
end
		
function Riven:ApproachW()
    local target = CurrentTarget(W.Range)
    if target == nil then return end
if AIO.Combo.UseW:Value() and target and Ready(_W) then
	    if EnemyInRange(W.Range) then
			    Control.CastSpell(HK_W)
				end
			end
		end
function Riven:Approach2W()
    local target = CurrentTarget(270)
    if target == nil then return end
if AIO.Combo.UseW:Value() and target and Ready(_W) then
	    if EnemyInRange(270) then
			    Control.CastSpell(HK_W)
				end
			end
		end
		
function Riven:Approach2E()
    local target = CurrentTarget(E.Range+W.Range-80)
    if target == nil then return end
    if AIO.Combo.UseE:Value() and target and Ready(_E) and Ready(_W) then		
	    if EnemyInRange(E.Range+W.Range-80) then
			local pos = target:GetPrediction(E.Speed,0.25)
			pos = myHero.pos + (pos - myHero.pos):Normalized()*(E.Range)
			Control.CastSpell(HK_E, pos)
		end    
	end
end

function Riven:Approach3E()
    local target = CurrentTarget(E.Range+W.Range+275)
    if target == nil then return end
    if AIO.Combo.UseE:Value() and target and Ready(_E) and Ready(_W) then		
	    if EnemyInRange(E.Range+W.Range) then
			local pos = target:GetPrediction(E.Speed,0.25)
			pos = myHero.pos + (pos - myHero.pos):Normalized()*(E.Range)
			Control.CastSpell(HK_E, pos)
		end    
	end
end
function Riven:Approach31Q()
    local target = CurrentTarget(W.Range+275)
    if target == nil then return end
    if AIO.Combo.UseQ:Value() and target and Ready(_Q) then		
	    if EnemyInRange(E.Range+W.Range) and GetDistance(myHero.pos, target.pos) > E.Range+W.Range+275 and myHero:GetSpellData(Q).ammo == 0 and not myHero:GetSpellData(Q).ammo == 1 and not myHero:GetSpellData(Q).ammo == 2 then
			local pos = target:GetPrediction(Q.Speed,0.25)
			pos = myHero.pos + (pos - myHero.pos):Normalized()*(Q.Range)
			Control.CastSpell(HK_Q, pos)
		end    
	end
end

	-- for i = 1, Game.MinionCount() do
	-- local minion = Game.Minion(i)
	-- if minion and minion.team == 300 or minion.name == "SRU_Razorbeak" or minion.name == "SRU_Red" or minion.name == "SRU_Blue" or minion.name == "SRU_Krug" or minion.name == "SRU_Gromp" or minion.name == "SRU_MurkWolf" or minion.name == "SRU_KrugMini" or minion.name == "SRU_Dragon_Fire" or minion.name == "SRU_Dragon_Air" or minion.name == "SRU_Dragon_Earth" or minion.name == "SRU_Dragon_Water" or minion.name == "SRU_Dragon_Elder" or minion.name == "SRU_Baron" or minion.name == "SRU_Herald" then
		-- if Ready(_Q) then 
			-- local castpos,HitChance, pos = TPred:GetBestCastPosition(minion, Q3.Delay , Q3.Width, Q3.Range ,Q3.Speed, myHero.pos, Q3.ignorecol, Q3.Type )
			-- if AIO.Clear.UseQ:Value() and minion then
				-- if ValidTarget(minion, 900) and myHero.pos:DistanceTo(minion.pos) < 900 then
					-- if (HitChance > 0 ) and HasBuff(myHero, "RivenQ3W") then
					-- Control.CastSpell(HK_Q, castpos)
					-- end
				-- end
			-- end
		-- end
	-- end
	-- end
	-- end

-- SRU_Razorbeak
-- SRU_Red
-- SRU_Krug
-- SRU_Gromp
-- SRU_Blue
-- SRU_MurkWolf
-- SRU_KrugMini
-- SRU_MiniKrugB
-- Sru_Crab
-- SRU_Dragon_Fire
-- SRU_Dragon_Air
-- SRU_Dragon_Earth
-- SRU_Dragon_Water
-- SRU_Dragon_Elder

function Riven:AADMG()
    local aadamage = myHero.totalDamage * 4
	return aadamage
end

function Riven:QDMG()
    local level = myHero:GetSpellData(_Q).level
    local qdamage = ({15, 35, 55, 75, 95})[level] + myHero.totalDamage / 100 * ({45, 50, 55, 60, 65})[level]
	return qdamage
end

function Riven:WDMG()
    local level = myHero:GetSpellData(_W).level
    local wdamage = ({55, 85, 115, 145, 175})[level] + 1.0 * myHero.bonusDamage
	return wdamage
end

function Riven:RDMG()
for i = 1, Game.HeroCount() do
	local target = Game.Hero(i);
	if target and target.isEnemy then
    local level = myHero:GetSpellData(_R).level
    local rdamage = (({100, 150, 200})[level] + 0.6 * myHero.bonusDamage) * math.max(0.04 * math.min(100 - GetPercentHP(target), 75), 1) - target.armor
	return rdamage
end
end
end

function Riven:KillstealW()
	local target = CurrentTarget(W.Range)
	if target == nil then return end
	if AIO.Killsteal.UseW:Value() and AIO.Killsteal.RR["KS"..target.charName]:Value() and target and Ready(_W) then
		if EnemyInRange(W.Range) then 
		   	local Wdamage = Riven:WDMG()
			if Wdamage >= HpPred(target,1) + target.hpRegen * 1 then
			    Control.CastSpell(HK_W)
				end
			end
		end
	end

function Riven:RksKnockedback()
    local target = CurrentTarget(R.Range)
	if target == nil then return end
	if AIO.Killsteal.UseR:Value() and AIO.Killsteal.RR["KS"..target.charName]:Value() and Ready(_R) then
		if EnemyInRange(R.Range) then 
			local ImmobileEnemy = self:IsKnockedUp(target)
			local level = myHero:GetSpellData(_R).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, R.Delay , R.Width, R.Range,R.Speed, myHero.pos, R.ignorecol, R.Type )
		 	local Rdamage = Riven:RDMG()
			if Rdamage >= HpPred(target,1) + target.hpRegen * 1 then
			if ImmobileEnemy then
			if (HitChance > 0 ) and HasBuff(myHero, "rivenknockback") and HasBuff(myHero, "rivenwindslashready") then
			    CastSpell(HK_R,castpos)
				end
			end
		end
	end
end
end

function Riven:RKSNormal()
    local target = CurrentTarget(R.Range)
	if target == nil then return end
	if AIO.Killsteal.UseR:Value() and AIO.Killsteal.RR["KS"..target.charName]:Value() and Ready(_R) then
		if EnemyInRange(R.Range) then 
			local level = myHero:GetSpellData(_R).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, R.Delay , R.Width, R.Range,R.Speed, myHero.pos, R.ignorecol, R.Type )
		 	local Rdamage = Riven:RDMG()
			if Rdamage >= HpPred(target,1) + target.hpRegen * 1 then
			if (HitChance > 0 ) and HasBuff(myHero, "rivenwindslashready") then
			    CastSpell(HK_R,castpos)
				end
			end
		end
	end
end
