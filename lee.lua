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

class "Azir"



function Azir:LoadSpells()

	Q = {Range = 740, Width = 0, Delay = 0, Speed = 500, Collision = false, aoe = false, Type = "line"}
	W = {Range = 570, Width = 0, Delay = 0, Speed = 500, Collision = false, aoe = false, Type = "line"}
	E = {Range = 1100, Width = 0, Delay = 0, Speed = 500, Collision = false, aoe = true, Type = "line"}
	R = {Range = 250, Width = 0, Delay = 0, Speed = 500, Collision = false, aoe = false, Type = "line"}

end

function Azir:LoadMenu()
	AIO = MenuElement({type = MENU, id = "Azir", name = "Kypo's AIO: Azir", leftIcon = AIOIcon})
	AIO:MenuElement({id = "Combo", name = "Combo", type = MENU})
	AIO.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Combo:MenuElement({id = "UseW", name = "W", value = true})
	-- AIO.Combo:MenuElement({id = "ESet", name = "E Settings", type = MENU})
	-- AIO.Combo.ESet:MenuElement({id = "EE", name = "Blah1", value = true})
	-- AIO.Combo.ESet:MenuElement({id = "EEE", name = "Blah2", value = true})
	AIO.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})

	-- AIO:MenuElement({id = "Clear", name = "Clear", type = MENU})
	-- AIO.Clear:MenuElement({id = "UseQ", name = "Q", value = true})
	-- AIO.Clear:MenuElement({id = "QCount", name = "Use Q on X minions", value = 3, min = 1, max = 5, step = 1})
	-- AIO.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("C")})
	
	AIO:MenuElement({id = "Flee", name = "Flee", type = MENU})
	AIO.Flee:MenuElement({id = "WE", name = "E to Soldier [READ]", key = string.byte("T"), tooltip = "If has no soldier on your mouse pos, it will cast one"})	
	AIO.Flee:MenuElement({id = "FlashInsec", name = "Flash Insec", key = string.byte("S")})
	AIO.Flee:MenuElement({id = "blank", type = SPACE , name = ""})
	AIO.Flee:MenuElement({id = "KickPos", name = "Kick Position", key = string.byte("6")})
	
	AIO:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	AIO.Killsteal:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Killsteal:MenuElement({id = "UseR", name = "R", value = true})	
	
	AIO:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	--Q
	AIO.Drawings:MenuElement({id = "Q", name = "Draw Q Range", type = MENU})
    AIO.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--W
	AIO.Drawings:MenuElement({id = "W", name = "Draw W Range", type = MENU})
    AIO.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.W:MenuElement({id = "Soldier", name = "Draw Soldier?", value = true})       
    AIO.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})		
	--E
	AIO.Drawings:MenuElement({id = "E", name = "Draw E Range", type = MENU})
    AIO.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--R 
	AIO.Drawings:MenuElement({id = "R", name = "Draw R Range", type = MENU})
    AIO.Drawings.R:MenuElement({id = "Enabled", name = "Normal", value = true})       
    AIO.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	
	AIO.Drawings:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
    AIO.Drawings:MenuElement({id = "HPColor", name = "HP Color", color = Draw.Color(200, 255, 255, 255)})
		
	AIO:MenuElement({id = "blank", type = SPACE , name = ""})
	AIO:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	AIO:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


function Azir:__init()
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

function Azir:Tick()
        if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true or ExtLibEvade and ExtLibEvade.Evading == true then return end
	if AIO.Combo.comboActive:Value() then
		self:Combo()
		self:ComboW()
	end
	-- if AIO.Clear.clearActive:Value() then
		-- self:Clear()
		-- self:ClearQ()
		-- self:ClearEJng()
	-- end
	-- if AIO.Lasthit.lasthitActive:Value() then
		-- self:Lasthit()
		-- self:LasthitE()
	-- end
	if AIO.Flee.KickPos:Value() then
		Position=mousePos
	end	
	if AIO.Flee.FlashInsec:Value() then
		self:FK(Position)
	end	
		self:KillstealQ()
		-- self:KillstealE()
		self:KillstealR()
		self:WQ()
		self:WQE()
		SoldierPos()
		flashslot = self:getFlash()

	end

function Azir:getFlash()
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

Soldier = {}	

function SoldierPos()
		for i = 0, Game.ParticleCount() do
			local particle = Game.Particle(i)
			local particlePos = particle.pos
			if particle and not particle.dead and particle.name:find("Azir_base_W_Sandbib.troy") then
			Soldier[particle.networkID] = particle
			end
		end	
end

function Azir:Draw()
Draw.Circle(Position,150,Draw.Color(170,255, 255, 255))
-- for i, soldier in pairs(Soldier) do
 -- Draw.Circle(soldier,280,Draw.Color(170,255, 255, 255)) end
if Ready(_Q) and AIO.Drawings.Q.Enabled:Value() then Draw.Circle(myHero.pos, Q.Range, AIO.Drawings.Q.Width:Value(), AIO.Drawings.Q.Color:Value()) end
if Ready(_W) and AIO.Drawings.W.Enabled:Value() then Draw.Circle(myHero.pos, W.Range, AIO.Drawings.W.Width:Value(), AIO.Drawings.W.Color:Value()) end
if Ready(_E) and AIO.Drawings.E.Enabled:Value() then Draw.Circle(myHero.pos, E.Range, AIO.Drawings.E.Width:Value(), AIO.Drawings.E.Color:Value()) end
if Ready(_R) and AIO.Drawings.R.Enabled:Value() then Draw.Circle(myHero.pos, R.Range, AIO.Drawings.R.Width:Value(), AIO.Drawings.R.Color:Value()) end

			if AIO.Drawings.DrawDamage:Value() then
		for i, hero in pairs(GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (Ready(_Q) and getdmg("Q",hero,myHero) or 0)
				local EDamage = (Ready(_E) and getdmg("E",hero,myHero) or 0)
				local RDamage = (Ready(_R) and getdmg("R",hero,myHero) or 0)
				local AA = (getdmg("AA",hero,myHero)) * 3
				local damage = QDamage + RDamage + EDamage + AA
				if damage > hero.health then
					Draw.Text("KILLABLE", 30, hero.pos2D.x - 50, hero.pos2D.y - 195,Draw.Color(200, 255, 87, 51))
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, AIO.Drawings.HPColor:Value())
				end
				end
				end
end
end

function Azir:ultimapos(targetx,from)
	local from=from or Vector(myHero.pos)
	local targetx=targetx or target
	return self:Normalized2(Vector(targetx.pos),from:DistanceTo(Vector(targetx.pos))+700,from)
end

function Azir:Normalized2(q,x,i)
	local x=x or 1
	local qx=(q-i)
	qx=Vector(0,0,0)+qx
	qx=qx:Normalized()
	qx=qx*x
	qx=i+qx
	return qx
end

function Azir:FK(poz)
    local target = CurrentTarget(E.Range)
	if target == nil then return end
	if target and Ready(_R) then
			local posicao1=self:Normalized2(Vector(target.pos),poz:DistanceTo(Vector(target.pos))+180,poz)
			local posicao2=self:Normalized2(Vector(target.pos),poz:DistanceTo(Vector(target.pos))-700,poz)
			if Vector(myHero.pos):DistanceTo(posicao1)<=500 and Vector(myHero.pos):DistanceTo(Vector(target.pos))<= 375 then
				if Azir:ultimapos(target):DistanceTo(posicao2)<=350 and Ready(flashslot) then
					Control.CastSpell(flashslot == SUMMONER_1 and HK_SUMMONER_1 or HK_SUMMONER_2,posicao1)
					DelayAction(function()Control.CastSpell(HK_R, target)end,0.1)
				elseif Ready(flashslot) and not MapPosition:inWall(posicao1) then
					Control.CastSpell(flashslot == SUMMONER_1 and HK_SUMMONER_1 or HK_SUMMONER_2,posicao1)
					DelayAction(function()Control.CastSpell(HK_R, target)end,0.1)
					end
			elseif Ready(flashslot) and GetDistance(myHero.pos, target.pos) < E.Range and GetDistance(myHero.pos, target.pos) > W.Range and Ready(_W) then
			local pos = target:GetPrediction(W.Speed,0.943)
			pos = myHero.pos + (pos - myHero.pos):Normalized()*(W.Range)
			Control.CastSpell(HK_W, pos)
			elseif Ready(_Q) and GetDistance(myHero.pos, target.pos) < E.Range - 100 then
			Control.CastSpell(HK_Q,target)
			elseif Ready(_E) and GetDistance(target.pos, target.pos) < 1000 then
			Control.CastSpell(HK_E,target)
			elseif not Ready(flashslot) and GetDistance(myHero.pos, posicao1.pos) < 100 then
			Control.CastSpell(HK_R,target)
			end
		end
	end

function Azir:IsImmobileTarget(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 24 or buff.type == 28 or buff.type == 21 or buff.type == 29) and buff.count > 0 then
				return true
			end
		end
	return false	
end

function Azir:Combo()
    local target = CurrentTarget(Q.Range)
    if target == nil then return end
	for i, soldier in pairs(Soldier) do
    if AIO.Combo.UseQ:Value() and target and Ready(_Q) and soldier and GetDistance(target.pos, soldier.pos) < Q.Range then
			Control.CastSpell(HK_Q, target)
		end
	end
	end

function Azir:WQ()
    if AIO.Flee.WE:Value() and Ready(_W) and Ready(_E) then
			Control.CastSpell(HK_W, mousePos)
			end
end

function Azir:WQE()
    if AIO.Flee.WE:Value() and Ready(_E) then
	for i, soldier in pairs(Soldier) do
	if soldier and GetDistance(soldier.pos, mousePos) < 350 then
			Control.CastSpell(HK_E, mousePos)
			end
end
end
end

function Azir:ComboW()
    local target = CurrentTarget(E.Range)
    if target == nil then return end
    if AIO.Combo.UseW:Value() and target and Ready(_W) and myHero:GetSpellData(1).ammo > 0 then
	local pos = target:GetPrediction(W.Speed,0.943)
	pos = myHero.pos + (pos - myHero.pos):Normalized()*(E.Range - 500)
			Control.CastSpell(HK_W, pos)
		end
	end

	-- if isReady(0) and isReady(2) and SyndraMenu.Combo.UseQE:Value() then
		-- local target = GetTarget(QE.Range)
		-- if target then
			-- local pos = target:GetPrediction(QE.Speed,0.943)
			-- pos = myHero.pos + (pos - myHero.pos):Normalized()*(Q.Range - 65)
			-- Control.SetCursorPos(pos) 
			-- Control.KeyDown(HK_Q)
			-- DelayAction(function() Control.KeyDown(HK_E) Control.KeyUp(HK_Q) Control.KeyUp(HK_E) end, 0.25)



function Azir:QDMG()
    local level = myHero:GetSpellData(_Q).level
    local qdamage = ({70,95,120,145,170})[level] + 0.3 * myHero.ap
	return qdamage
end

function Azir:RDMG()
    local level = myHero:GetSpellData(_R).level
    local rdamage = ({150, 250, 450})[level] + 0.60 * myHero.ap
	return rdamage
end

function Azir:KillstealQ()
for i, soldier in pairs(Soldier) do
	local target = CurrentTarget(E.Range)
	if target == nil then return end
	if AIO.Killsteal.UseQ:Value() and soldier and Ready(_Q) then
	if not soldier then return end
		if EnemyInRange(Q.Range) then 
		   	local Qdamage = Azir:QDMG()
			if Qdamage >= HpPred(target,1) + target.hpRegen * 1 then
			if target.pos:DistanceTo(soldier.pos) < E.Range then
			    Control.CastSpell(HK_Q,target)
				end
			end
		end
	end
end
end

function Azir:KillstealR()
	local target = CurrentTarget(R.Range)
	if target == nil then return end
	if AIO.Killsteal.UseR:Value() and target and Ready(_R) then
		if EnemyInRange(R.Range) then 
		   	local Rdamage = Azir:RDMG()
			if Rdamage >= HpPred(target,1) + target.hpRegen * 1 then
			    Control.CastSpell(HK_R,target)
				end
			end
		end
	end


function Azir:KillstealRSmart()
	local target = CurrentTarget(R.Range)
	if target == nil then return end
	if AIO.Killsteal.UseQR:Value() and target and Ready(_R) then
		if EnemyInRange(R.Range) then 
		   	local damage = Azir:QRDMG()
			if damage >= HpPred(target,1) + target.hpRegen * 1 then
			if target.pos:DistanceTo(myHero.pos) < 700 and Ready(_R) and HasBuff(target, "AzirMota") and myHero:GetSpellData(3).ammo > 0 then
			    Control.CastSpell(HK_R,target)
				end
			end
		end
	end
end


-- Utilities menu

class "Essentials"
local mapID = Game.mapID;
local wards = {}
local quality = 1

function Essentials:__init()
	self:BaseUltData()
	Essentials:Menu()
	Callback.Add("ProcessRecall", function(unit, recall) self:ProcessRecall(unit, recall) end)
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"
end
end

function Essentials:Tick()
GetMode()
-- Summoner KS
	ChillingSmiteKS()
	IgniteKS()
-- Item KS
	TiamatKS()
	HydraKS()
	BladeKingKS()
	THydraKS()
	GLPKS()
	GunbladeKS()
	ProtobeltKS()
-- Items cast
if GetMode() == "Combo" then
	EdgeNightCast()
	TiamatCast()	
	HydraCast()
	BladeKingCast()
	THydraCast()
	GLPCast()	
	GunbladeCast()
	ProtobeltCast()
	YoumuuCast()
	end
	-- Awareness
	
	
	-- Baseult
	self:BaseultB()
	self:BaseultR()
	-- Other
	
	
end

function Essentials:Draw()
end


function GetMode()
	if _G.SDK and _G.SDK.Orbwalker then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "Lasthit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
	end
end
	

function Essentials:Menu()
	Essentials = MenuElement({type = MENU, id = "Essentials", name = "Kypo's Essentials", leftIcon = EssentialsIcon})
	Essentials:MenuElement({id = "Activator", name = "Activator", type = MENU})
	
	-- Offensive
	
	Essentials.Activator:MenuElement({id = "Offensive", name = "Offensive", type = MENU})
	Essentials.Activator.Offensive:MenuElement({id = "Tiamat", name = "Tiamat", value = true})
	Essentials.Activator.Offensive:MenuElement({id = "Hydra", name = "Ravenous Hydra", value = true})
	Essentials.Activator.Offensive:MenuElement({id = "THydra", name = "Titanic Hydra", value = true})
	
	Essentials.Activator.Offensive:MenuElement({id = "GLP", name = "Hextech GLP", type = MENU})
	Essentials.Activator.Offensive.GLP:MenuElement({id = "Enable", name = "Enable", value = true})
	Essentials.Activator.Offensive.GLP:MenuElement({id = "HP", name = "Max enemy HP", value = 50, min = 1, max = 100})
	
	Essentials.Activator.Offensive:MenuElement({id = "Gunblade", name = "Hextech Gunblade", type = MENU})
	Essentials.Activator.Offensive.Gunblade:MenuElement({id = "Enable", name = "Enable", value = true})
	Essentials.Activator.Offensive.Gunblade:MenuElement({id = "HP", name = "Max enemy HP", value = 50, min = 1, max = 100})
	
	Essentials.Activator.Offensive:MenuElement({id = "Protobelt", name = "Hextech Protobelt", type = MENU})
	Essentials.Activator.Offensive.Protobelt:MenuElement({id = "Enable", name = "Enable", value = true})
	Essentials.Activator.Offensive.Protobelt:MenuElement({id = "HP", name = "Max enemy HP", value = 50, min = 1, max = 100})
	
	Essentials.Activator.Offensive:MenuElement({id = "BladeKing", name = "Blade of the Ruined King", type = MENU})
	Essentials.Activator.Offensive.BladeKing:MenuElement({id = "Enable", name = "Enable", value = true})
	Essentials.Activator.Offensive.BladeKing:MenuElement({id = "HP", name = "Max Enemy HP", value = 80, min = 1, max = 100})
	
	Essentials.Activator.Offensive:MenuElement({id = "YG", name = "Youmuu's Ghostblade", type = MENU})
	Essentials.Activator.Offensive.YG:MenuElement({id = "Enable", name = "Enable", value = true})
	Essentials.Activator.Offensive.YG:MenuElement({id = "Dist", name = "Enemy Distance", value = 1000, min = 300, max = 1500, step = 50})
	
	-- Defensive
	Essentials.Activator:MenuElement({id = "Defensive", name = "Defensive", type = MENU})
	Essentials.Activator.Defensive:MenuElement({id = "EdgeNight", name = "Edge of Night", type = MENU})
	Essentials.Activator.Defensive.EdgeNight:MenuElement({id = "Enable", name = "Enable", value = true})
	Essentials.Activator.Defensive.EdgeNight:MenuElement({id = "MinEnemies", name = "Min Enemies", value = 2, min = 1, max = 5})

	-- Killsteal
	Essentials.Activator:MenuElement({type = MENU, id = "Killsteal", name = "Killsteal"})
	Essentials.Activator.Killsteal:MenuElement({id = "KSEnemies", name = "Select enemy heroes you want to KS", type = MENU})
	for i, target in pairs(GetEnemyHeroes()) do
	Essentials.Activator.Killsteal.KSEnemies:MenuElement({id = "EnemiesToKS"..target.charName, name = ""..target.charName, value = true})
	end
	
	Essentials.Activator.Killsteal:MenuElement({type = MENU, id = "Summoners", name = "Summoners"})
	Essentials.Activator.Killsteal.Summoners:MenuElement({id = "Ignite", name = "Ignite", value = true})
	Essentials.Activator.Killsteal.Summoners:MenuElement({id = "ChillingSmite", name = "Chilling Smite", value = true})
	Essentials.Activator.Killsteal:MenuElement({id = "blank", type = SPACE , name = ""})
	
	Essentials.Activator.Killsteal:MenuElement({id = "Tiamat", name = "Tiamat", value = true})
	Essentials.Activator.Killsteal:MenuElement({id = "Hydra", name = "Ravenous Hydra", value = true})
	Essentials.Activator.Killsteal:MenuElement({id = "THydra", name = "Titanic Hydra", value = true})
	Essentials.Activator.Killsteal:MenuElement({id = "GLP", name = "Hextech GLP", value = true})
	Essentials.Activator.Killsteal:MenuElement({id = "Gunblade", name = "Hextech Gunblade", value = true})
	Essentials.Activator.Killsteal:MenuElement({id = "Protobelt", name = "Hextech Protobelt", value = true})
	Essentials.Activator.Killsteal:MenuElement({id = "BladeKing", name = "Blade of the Ruined King", value = true})
	
	-- Awareness
	-- Essentials:MenuElement({id = "Awareness", name = "Awareness", type = MENU})

	-- Tracker
	-- Essentials:MenuElement({id = "Tracker", name = "Tracker", type = MENU})
	-- Essentials.Tracker:MenuElement({id = "SpellsMyhero", name = "My Spells", value = true})
	-- Essentials.Tracker:MenuElement({id = "SpellsEnemies", name = "Enemy Spells", value = true})
	-- Essentials.Tracker:MenuElement({id = "blank", type = SPACE , name = ""})
	-- Essentials.Tracker:MenuElement({id = "Recall", name = "Recall Track", value = true})

	-- Baseult
	Essentials:MenuElement({id = "Baseult", name = "Baseult", type = MENU})
  	Essentials.Baseult:MenuElement({type = MENU, id = "ultchamp", name = "Use ULT on:"})
  	for i, enemy in pairs(GetEnemyHeroes()) do
  	Essentials.Baseult.ultchamp:MenuElement({id = enemy.charName, name = enemy.charName, value = false})
  	end
	Essentials.Baseult:MenuElement({id = "Redside", name = "Enemy UP (minimap)",value = false})
	Essentials.Baseult:MenuElement({id = "Blueside", name = "Enemy DOWN (minimap)",value = false})
	Essentials.Baseult:MenuElement({id = "DontUlt", name = "Don't ult if pressed:", key = 32})
	Essentials.Baseult:MenuElement({id = "blank", type = SPACE , name = "Supported;"})
	Essentials.Baseult:MenuElement({id = "blank", type = SPACE , name = "Ashe, Draven, Ezreal, Jinx"})
	Essentials.Baseult:MenuElement({id = "blank", type = SPACE , name = "Lux, Gangplank, Ziggs"})

	-- Smite
	-- Essentials:MenuElement({id = "Smite", name = "Smite", type = MENU})	
	

	Essentials:MenuElement({id = "blank", type = SPACE , name = ""})
	Essentials:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	Essentials:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


-- [ITEM DAMAGE]


function IgniteDMG()
	return 50+20*myHero.levelData.lvl
end

function ChillingSmiteDMG() --3706,1401,1400,1402,1416
	return 20+8*myHero.levelData.lvl
end 

function TiamatDMG() --3077
	return 100
end 

function THydraDMG() --3748
	return 200
end 

function GLPDMG() --3030
    local level = myHero.levelData.lvl
    local damage = ({100,106,112,118,124,130,136,141,147,153,159,165,171,176,182,188,194,200})[level] + 0.35 * myHero.ap
	return damage
end 

function GunbladeDMG() --3146
    local level = myHero.levelData.lvl
    local damage = ({175,180,184,189,193,198,203,207,212,216,221,225,230,235,239,244,248,253})[level] + 0.30 * myHero.ap
	return damage
end 

function ProtobeltDMG() --3152
    local level = myHero.levelData.lvl
    local damage = ({75,79,83,88,92,97,101,106,110,115,119,124,128,132,137,141,146,150})[level] + 0.25 * myHero.ap
	return damage
end

function BladeKingDMG() --3144,3153
	local target = CurrentTarget(550)
	if target == nil then return end
	return target.maxHealth * 0.1
end 



-- [ITEM KILLSTEAL]

function TiamatKS()
	local target = CurrentTarget(380)
	if target == nil then return end
	if Essentials.Activator.Killsteal.Tiamat:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		local Tiamat = GetInventorySlotItem(3077)
		local dmg = TiamatDMG()
		if Tiamat and EnemyInRange(380) and dmg >= HpPred(target,1) then
			Control.CastSpell(HKITEM[Tiamat])
			end
		end
	end
	
function HydraKS()
	local target = CurrentTarget(380)
	if target == nil then return end
	if Essentials.Activator.Killsteal.Hydra:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		local Hydra = GetInventorySlotItem(3074)
		local dmg = TiamatDMG()
		if Hydra and EnemyInRange(380) and dmg >= HpPred(target,1) then
			Control.CastSpell(HKITEM[Hydra])
			end
		end
	end
	
function THydraKS()
	local target = CurrentTarget(380)
	if target == nil then return end
	if Essentials.Activator.Killsteal.THydra:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		local THydra = GetInventorySlotItem(3748)
		local dmg = THydraDMG()
		if THydra and EnemyInRange(380) and dmg >= HpPred(target,1) then
			Control.CastSpell(HKITEM[THydra])
			end
		end
	end
	
function GLPKS()
	local target = CurrentTarget(880)
	if target == nil then return end
	if Essentials.Activator.Killsteal.GLP:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		local GLP = GetInventorySlotItem(3030)
		local dmg = GLPDMG()
		if GLP and EnemyInRange(880) and dmg >= HpPred(target,1) then
			Control.CastSpell(HKITEM[GLP], target)
			end
		end
	end
	
function GunbladeKS()
	local target = CurrentTarget(700)
	if target == nil then return end
	if Essentials.Activator.Killsteal.Gunblade:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		local Gunblade = GetInventorySlotItem(3146)
		local dmg = GunbladeDMG()
		if Gunblade and EnemyInRange(700) and dmg >= HpPred(target,1) then
			Control.CastSpell(HKITEM[Gunblade], target)
			end
		end
	end
	
function ProtobeltKS()
	local target = CurrentTarget(850)
	if target == nil then return end
	if Essentials.Activator.Killsteal.Protobelt:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		local Protobelt = GetInventorySlotItem(3152)
		local dmg = ProtobeltDMG()
		if Protobelt and EnemyInRange(850) and dmg >= HpPred(target,1) then
			Control.CastSpell(HKITEM[Protobelt], target)
			end
		end
	end
	
function BladeKingKS()
	local target = CurrentTarget(550)
	if target == nil then return end
	if Essentials.Activator.Killsteal.BladeKing:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		local BladeKing = GetInventorySlotItem(3144) or GetInventorySlotItem(3153)
		local dmg = BladeKingDMG()
		if BladeKing and EnemyInRange(550) and dmg >= HpPred(target,1) then
			Control.CastSpell(HKITEM[BladeKing], target)
			end
		end
	end

-- [Summoner KILLSTEAL]

function IgniteKS()
	local target = CurrentTarget(600)
	if target == nil then return end
	if Essentials.Activator.Killsteal.Summoners.Ignite:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		if EnemyInRange(600) then 
			local IgniteDMG = IgniteDMG()
			if IgniteDMG >= HpPred(target,1) then
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) then
            Control.CastSpell(HK_SUMMONER_1, target)
        elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) then
            Control.CastSpell(HK_SUMMONER_2, target)				
			end
			end
		end
	end
	end
	
function ChillingSmiteKS()
	local target = CurrentTarget(500)
	if target == nil then return end
	if Essentials.Activator.Killsteal.Summoners.ChillingSmite:Value() and Essentials.Activator.Killsteal.KSEnemies["EnemiesToKS"..target.charName]:Value() then
		local dmg = ChillingSmiteDMG()
		if EnemyInRange(500) and dmg >= HpPred(target,1) then
        if myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_1) then
            Control.CastSpell(HK_SUMMONER_1, target)
        elseif myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_2) then
            Control.CastSpell(HK_SUMMONER_2, target)
			end
		end
	end
end
		
-- [Item Cast]
-- Offensive
function TiamatCast()
	local target = CurrentTarget(380)
	if target == nil then return end
	if Essentials.Activator.Offensive.Tiamat:Value() then
		local Tiamat = GetInventorySlotItem(3077)
		if Tiamat and EnemyInRange(380) then
			Control.CastSpell(HKITEM[Tiamat])
			end
		end
	end
	
function HydraCast()
	local target = CurrentTarget(380)
	if target == nil then return end
	if Essentials.Activator.Offensive.Hydra:Value() then
		local Hydra = GetInventorySlotItem(3074)
		local dmg = TiamatDMG()
		if Hydra and EnemyInRange(380) then
			Control.CastSpell(HKITEM[Hydra])
			end
		end
end
	
function THydraCast()
	local target = CurrentTarget(380)
	if target == nil then return end
	if Essentials.Activator.Offensive.THydra:Value()  then
		local THydra = GetInventorySlotItem(3074)
		local dmg = THydraDMG()
		if THydra and EnemyInRange(380) then
			Control.CastSpell(HKITEM[THydra])
			end
		end
	end
	
function GLPCast()
	local target = CurrentTarget(880)
	if target == nil then return end
	if Essentials.Activator.Offensive.GLP.Enable:Value() then
		local GLP = GetInventorySlotItem(3030)
		if GLP and EnemyInRange(880) and target.health/target.maxHealth <= Essentials.Activator.Offensive.GLP.HP:Value() / 100 then
			Control.CastSpell(HKITEM[GLP], target)
			end
		end
	end
	
function GunbladeCast()
	local target = CurrentTarget(700)
	if target == nil then return end
	if Essentials.Activator.Offensive.Gunblade.Enable:Value() then
		local Gunblade = GetInventorySlotItem(3146)
		if Gunblade and EnemyInRange(700) and target.health/target.maxHealth <= Essentials.Activator.Offensive.Gunblade.HP:Value() / 100 then
			Control.CastSpell(HKITEM[Gunblade], target)
			end
		end
	end
	
function ProtobeltCast()
	local target = CurrentTarget(850)
	if target == nil then return end
	if Essentials.Activator.Offensive.Protobelt.Enable:Value() and target.health/target.maxHealth <= Essentials.Activator.Offensive.Protobelt.HP:Value() / 100 then
		local Protobelt = GetInventorySlotItem(3152)
		if Protobelt and EnemyInRange(850) then
			Control.CastSpell(HKITEM[Protobelt], target)
			end
		end
	end
	
function BladeKingCast()
	local target = CurrentTarget(550)
	if target == nil then return end
	if Essentials.Activator.Offensive.BladeKing.Enable:Value() and target.health/target.maxHealth <= Essentials.Activator.Offensive.BladeKing.HP:Value() / 100 then
		local BladeKing = GetInventorySlotItem(3144) or GetInventorySlotItem(3153)
		if BladeKing and EnemyInRange(550) then
			Control.CastSpell(HKITEM[BladeKing], target)
			end
		end
	end
	
function YoumuuCast()
	local target = CurrentTarget(1500)
	if target == nil then return end
	if Essentials.Activator.Offensive.YG.Enable:Value() and target.distance < Essentials.Activator.Offensive.YG.Dist:Value() then
		local YG = GetInventorySlotItem(3142)
		if YG then
			Control.CastSpell(HKITEM[YG])
			end
		end
	end
	
-- Defensive
function EdgeNightCast()
	local target = CurrentTarget(1200)
	if target == nil then return end
	if Essentials.Activator.Defensive.EdgeNight.Enable:Value() and EnemyInRange(1200) >= Essentials.Activator.Defensive.EdgeNight.MinEnemies:Value() then
		local EdgeNight = GetInventorySlotItem(3814)
		if EdgeNight and EnemyInRange(1200) then
			Control.CastSpell(HKITEM[EdgeNight])
			end
		end
	end
	
----- BASEULT DATA

function Essentials:BaseUltData()
   	self.UltimateData = {
    		["Ashe"] = {Delay = 0.20, Speed = 1600, Width = 130, Collision = true, Damage = function(source, target) return getdmg("R", target, source) end},
    		["Draven"] = {Delay = 0.4, Speed = 2000, Width = 160, Collision = true, Damage = function(source, target) return getdmg("R", target, source) end},
    		["Ezreal"] = {Delay = 1, Speed = 2000, Width = 160, Damage = function(source, target) return getdmg("R", target, source) end},
    		["Jinx"] = {Delay = 0.7, Speed = 1700, Width = 140, Collision = true, Damage = function(source, target) return getdmg("R", target, source, 2) end},
    		["Lux"] = {Delay = 1, Speed = math.huge, Damage = function(source, target) return getdmg("R", target, source) end},
    		["Gangplank"] = {Delay = 1, Speed = math.huge, Damage = function(source, target) return getdmg("R", target, source) end},
    		["Ziggs"] = {Delay = 0, Speed = math.huge, Damage = function(source, target) return getdmg("R", target, source) end},
    	}
	self.tempodechegar = 0
	self.Caras, self.dadorecall, self.datadoenemigo, self.danoqpodev = {}, {}, {}, {}
	for i = 1, Game.HeroCount() do
	  	local unit = Game.Hero(i)
  	  	if unit.isMe then 
  	    		goto continue
  	  	end
  	  	if unit.isEnemy then 
  	    		self.datadoenemigo[unit.networkID] = 0
  	    		table.insert(self.Caras, unit)
  	  	end
  	  	::continue::
    	end
    	for i = 1, Game.ObjectCount() do
  	  	local object = Game.Object(i)
  	  	if object.isAlly or object.type ~= Obj_AI_SpawnPoint then 
  	    		goto continue
  	  	end
  	  	self.EnemySpawnPos = object
  	  	break
  	  	::continue::
    	end
end

function Essentials:vidapredicada(unit, time)
	if unit.health then return math.min(unit.maxHealth, unit.health+unit.hpRegen*(Game.Timer()-self.datadoenemigo[unit.networkID]+time)) end
end

function Essentials:pegoudanototal()
	local n = 0
	for i, damage in pairs(self.danoqpodev) do
    		n = n + damage
    	end
    	return n
end

function Essentials:GetRecallData(unit)
    	for i, recall in pairs(self.dadorecall) do
    		if recall.object.networkID == unit.networkID then
    			return {isRecalling = true, recall = recall.start+recall.duration-Game.Timer()}
	    	end
	end
	return {isRecalling = false, recall = 0}
end

function Essentials:GetUltimateData(unit)
	return self.UltimateData[unit.charName]
end

function Essentials:ProcessRecall(unit, recall)
	if not unit.isEnemy then return end
	if recall.isStart then
    		table.insert(self.dadorecall, {object = unit, start = Game.Timer(), duration = (recall.totalTime*0.001)})
    	else
      	for i, rc in pairs(self.dadorecall) do
        	if rc.object.networkID == unit.networkID then
          		table.remove(self.dadorecall, i)
        	end
      	end
    end
end

function Essentials:pegoudanototal()
	local n = 0
	for i, damage in pairs(self.danoqpodev) do
    		n = n + damage
    	end
    	return n
end

function Essentials:tempodechegarbase(unit, data)
	if data.Speed == math.huge and data.Delay ~= 0 then return data.Delay end
	local distance = unit.pos:DistanceTo(self.EnemySpawnPos.pos)
	local delay = data.Delay
	local missilespeed = data.Speed 
	if unit.charName == "Ziggs" then
		delay = 1.5 + 1.5 * distance / unit:GetSpellData(3).range
	end
	if unit.charName == "Jinx" then
		missilespeed = distance > 1350 and (2295000 + (distance - 1350) * 2200) / distance or data.Speed
    	end
	return distance / missilespeed + delay
end
	
	
function Essentials:BaseultR()
if not Essentials.Baseult.Redside:Value() or myHero.dead or not Ready(_R) then return end
	for i, enemy in pairs(self.Caras) do
		if enemy.visible then
			self.datadoenemigo[enemy.networkID] = Game.Timer()
		end
	end
	for i, enemy in pairs(self.Caras) do
		if enemy.valid and not enemy.dead and Essentials.Baseult.ultchamp[enemy.charName]:Value() and self:GetRecallData(enemy).isRecalling then
			local tempodechegar = self:tempodechegarbase(myHero, self:GetUltimateData(myHero))
			local recall = self:GetRecallData(enemy).recall
            		if recall >= tempodechegar then
            			self.danoqpodev[myHero.networkID] = self:GetUltimateData(myHero).Damage(myHero, enemy)
            		else
            			self.danoqpodev[myHero.networkID] = 0
            		end
            		if self:pegoudanototal() < self:vidapredicada(enemy, recall) then return end
            		self.tempodechegar = tempodechegar
            		if recall - tempodechegar > 0.1 or Essentials.Baseult.DontUlt:Value() then return end
					self:BaseultRed()
            		self.tempodechegar = 0
        	end
    	end
end

function Essentials:BaseultB()
if not Essentials.Baseult.Blueside:Value() or myHero.dead or not Ready(_R) then return end
	for i, enemy in pairs(self.Caras) do
		if enemy.visible then
			self.datadoenemigo[enemy.networkID] = Game.Timer()
		end
	end
	for i, enemy in pairs(self.Caras) do
		if enemy.valid and not enemy.dead and Essentials.Baseult.ultchamp[enemy.charName]:Value() and self:GetRecallData(enemy).isRecalling then
			local tempodechegar = self:tempodechegarbase(myHero, self:GetUltimateData(myHero))
			local recall = self:GetRecallData(enemy).recall
            		if recall >= tempodechegar then
            			self.danoqpodev[myHero.networkID] = self:GetUltimateData(myHero).Damage(myHero, enemy)
            		else
            			self.danoqpodev[myHero.networkID] = 0
            		end
            		if self:pegoudanototal() < self:vidapredicada(enemy, recall) then return end
            		self.tempodechegar = tempodechegar
            		if recall - tempodechegar > 0.1 or Essentials.Baseult.DontUlt:Value() then return end
					self:BaseultBlue()
            		self.tempodechegar = 0
        	end
    	end
end


function Essentials:BaseultBlue()
		for i,pos in pairs(BluePos) do
			if pos:DistanceTo(myHero.pos) < 99999 then
				local mpos = Vector(pos.x,0,pos.z):ToMM()
				Control.SetCursorPos(mpos.x,mpos.y)
				Control.CastSpell(HK_R)
			end
		end
	end

function Essentials:BaseultRed()
		for i,pos in pairs(RedPos) do
			if pos:DistanceTo(myHero.pos) < 99999 then
				local mpos = Vector(pos.x,0,pos.z):ToMM()
				Control.SetCursorPos(mpos.x,mpos.y)
				Control.CastSpell(HK_R)
			end
		end
	end
	
----- BASEULT DATA

Callback.Add("Load",function()
	Essentials()
	_G[myHero.charName]()
end)
