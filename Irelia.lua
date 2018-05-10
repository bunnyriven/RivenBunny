local Heroes = {"XinZhao","Olaf","Irelia","Xerath","Ryze","Kled","Cassiopeia","Malzahar","Lucian","Morgana","Twitch","Jhin","Ashe","Alistar","Ahri","Azir","Blitzcrank","Draven","Ezreal","Fizz","Jinx","Kalista","KogMaw","Leblanc","LeeSin","Lux","Nasus","Nidalee","Orianna","Syndra","Teemo","Thresh","Tristana","Caitlyn","Veigar","Yasuo","Zed", "Annie","Akali"}
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

class "Irelia"

local timer = Game.Timer()
local data = {casting = false, start = Game.Timer()}

function Irelia:LoadSpells()

	Q = {Range = 650, Width = 0, Delay = 0.35, Speed = 2200, Collision = false, aoe = false, Type = "line"}
	W = {Range = 130, Width = 0, Delay = 0.30, Speed = 1000, Collision = false, aoe = false, Type = "line"}
	E = {Range = 325, Width = 70, Delay = 0.25, Speed = 1200, Collision = false, aoe = false, Type = "line"}
	R = {Range = 1000, Width = 0, Delay = 0.25, Speed = 1200, Collision = false, aoe = false, Type = "line"}

end

function Irelia:LoadMenu()
	AIO = MenuElement({type = MENU, id = "Irelia", name = "Kypo's AIO: Irelia", leftIcon = AIOIcon})
	AIO:MenuElement({id = "Combo", name = "Combo", type = MENU})
	AIO.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Combo:MenuElement({id = "UseW", name = "W", value = true})
	AIO.Combo:MenuElement({id = "UseE", name = "E", value = true})
	AIO.Combo:MenuElement({id = "EStun", name = "Only E to Stun?", value = true})
	AIO.Combo:MenuElement({id = "RKey", name = "R Key", key = string.byte("T")})
	AIO.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})	
	
	AIO:MenuElement({id = "Harass", name = "Harass", type = MENU})
	AIO.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Harass:MenuElement({id = "UseW", name = "W", value = true})
	AIO.Harass:MenuElement({id = "UseE", name = "E", value = true})
	AIO.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("V")})

	AIO:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	AIO.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
	
	-- AIO:MenuElement({id = "Gapclose", name = "Gapclose", type = MENU})
	-- AIO.Gapclose:MenuElement({id = "QCombo", name = "Q on Combo", value = true})
	-- AIO.Gapclose:MenuElement({id = "QKS", name = "Q > Minion > KS Target", value = true})
	
	AIO:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	AIO.Killsteal:MenuElement({id = "KS", name = "Enemies to use:", type = MENU})
	for i, hero in pairs(GetEnemyHeroes()) do
	AIO.Killsteal.KS:MenuElement({id = "KS"..hero.charName, name = ""..hero.charName, value = true})
	end
	AIO.Killsteal:MenuElement({id = "UseQ", name = "Q", value = true})
	AIO.Killsteal:MenuElement({id = "UseE", name = "E", value = true})
	AIO.Killsteal:MenuElement({id = "UseR", name = "Use R? Calculates all 4!", value = true})
	
	AIO:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	--Q
	AIO.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
    AIO.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    AIO.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    AIO.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--W
	-- AIO.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU})
    -- AIO.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    -- AIO.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    -- AIO.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--E
	AIO.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU})
    AIO.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = false})       
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
	AIO:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
	AIO:MenuElement({id = "blank", type = SPACE , name = ""})
	AIO:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	AIO:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


function Irelia:__init()
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
