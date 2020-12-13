-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2

    -- Load and initialize the include file.
    include('Mote-Include.lua')
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff.Migawari = buffactive.migawari or false
    state.Buff.Doom = buffactive.doom or false
    state.Buff.Yonin = buffactive.Yonin or false
    state.Buff.Innin = buffactive.Innin or false
    state.Buff.Futae = buffactive.Futae or false

    determine_haste_group()
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal', 'Acc')
    state.HybridMode:options('Normal', 'Evasion', 'PDT')
    state.WeaponskillMode:options('Normal', 'Acc', 'Mod')
    state.CastingMode:options('Normal', 'Resistant')
    state.PhysicalDefenseMode:options('PDT', 'Evasion')

    gear.default.ElementalObi = "Eschan Stone"

    gear.MovementFeet = {name="Danzo Sune-ate"}
    gear.DayFeet = "Danzo Sune-ate"
    gear.NightFeet = gear.DayFeet --"Hachiya Kyahan"

    gear.WSDayEar1 = "Brutal Earring"
    gear.WSDayEar2 = "Cessance Earring"
    gear.WSNightEar1 = "Lugra Earring +1"
    gear.WSNightEar2 = "Lugra Earring"
    gear.WSEarBrutal = {name=gear.WSDayEar1}
    gear.WSEarCessance = {name=gear.WSDayEar2}

    ticker = windower.register_event('time change', function(myTime)
        if (myTime == 17*60 or myTime == 7*60) then 
            procTime(myTime)
            if (player.status == 'Idle' or state.Kiting.value) then
                update_combat_form()
            end
        end
    end)
    
    --procTime(world.time) -- initial setup of proctime

    select_default_macro_book()
end

function procTime(myTime) 
    if isNight() then
        gear.WSEarBrutal.name = gear.WSNightEar1
        gear.WSEarCessance.name = gear.WSNightEar2
        gear.MovementFeet = gear.NightFeet
    else
        gear.WSEarBrutal.name = gear.WSDayEar1
        gear.WSEarCessance = gear.WSDayEar2
        gear.MovementFeet = gear.DayFeet
    end
end

function isNight() -- this originally was used a lot more, so I just left it.
    return (world.time >= 17*60 or world.time < 7*60)
end

function user_unload()
    windower.unregister_event(ticker)
end


-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs
    sets.precast.JA['Mijin Gakure'] = {legs="Mochizuki Hakama"}
    sets.precast.JA['Futae'] = {legs="Iga Tekko +2"}
    sets.precast.JA['Sange'] = {legs="Mochizuki Chainmail +1"}

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {ammo="Sonia's Plectrum",
        head="Felistris Mask",
        body="Hachiya Chainmail +1",hands="Buremte Gloves",ring1="Spiral Ring",
        back="Iximulew Cape",waist="Caudata Belt",legs="Nahtirah Trousers",feet="Hizamaru Sune-ate"}
        -- Uk'uxkaj Cap, Daihanshi Habaki
        
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Set for acc on steps, since Yonin drops acc a fair bit
    sets.precast.Step = {
        head="Adhemar Bonnet +1",neck="Sanctity Necklace",
        body="Mochizuki Chainmail +1",hands="Buremte Gloves",ring1="Patricius Ring",
        back="Yokaze Mantle",waist="Chaac Belt",legs="Hizamaru Hizayoroi",feet="Hizamaru Sune-ate"}

    sets.precast.Flourish1 = {waist="Chaac Belt"}

    -- Fast cast sets for spells
    
    sets.precast.FC = {ear2="Loquacious Earring",hands="Malignance Gloves",ring2="Prolix Ring"}
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {ammo="Togakushi Shuriken",back="Andartia's Mantle",neck="Magoraga Beads",body="Mochizuki Chainmail +1"})

    -- Snapshot for ranged
    sets.precast.RA = {hands="Manibozho Gloves",legs="Nahtirah Trousers",feet="Wurrukatte Boots"}
       
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {ammo="Seething Bomblet +1",
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Moonshade Earring",ear2=gear.WSEarBrutal,
        body="Hizamaru Haramaki",hands="Hizamaru Kote",ring1="Karieyh Ring +1",ring2="Epona's Ring",
        back="Atheling Mantle",waist="Fotia Belt",legs="Hizamaru hizayoroi",feet="Hizamaru Sune-ate"}
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {ammo="Jukukik Feather",hands="Buremte Gloves",
        back="Yokaze Mantle"})
    sets.precast.WS.Magic = {ammo="Seething Bomblet +1",
        head="Herculean Helm",neck="Sanctity Necklace",ear1="Hecate's Earring",ear2="Friomisi Earring",
        body="Samnuha Coat",hands="Leyline Gloves", ring1="Karieyh Ring +1", ring2="Acumen Ring",
        back="Atheling Mantle",waist="Eschan Stone", legs="Herculean Trousers", feet="Malignance Boots"}

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.

    sets.precast.WS['Blade: Hi'] = set_combine(sets.precast.WS,
        {ammo="yetshila +1",head="Adhemar Bonnet +1",ear1=gear.WSEarBrutal,ear2="Odr Earring",body="Mummu Jacket",hands="Mummu Wrists +1",ring1="Karieyh Ring +1", ring2="Begrudging Ring",legs="Mummu Kecks",feet="Mummu Gamashes +1"})

    sets.precast.WS['Blade: Jin'] = set_combine(sets.precast.WS,
    {ammo="yetshila +1",ear1=gear.WSEarBrutal,ear2="Odr Earring",ring2="Begrudging Ring",feet="Daihanshi Habaki"})

    sets.precast.WS['Blade: Shun'] = set_combine(sets.precast.WS,{ear1=gear.WSEarBrutal,ear2="Odr Earring",ring1="Apate Ring"})

    sets.precast.WS['Eviscaration'] = sets.precast.WS['Blade: Jin']

    sets.precast.WS['Aeolian Edge'] = {ammo="Seething Bomblet +1",
        head="Herculean Helm",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Moonshade Earring",
        body="Malignance Tabard",hands="Herculean Gloves",ring1="Acumen Ring",ring2="Apate Ring",
        back="Toro Cape",waist=gear.ElementalObi,legs="Herculean Trousers",feet="Malignance Boots"}

    -- Magical Weaponskills
    sets.precast.WS['Blade: Teki'] = set_combine(sets.precast.WS.Magic, {})
    sets.precast.WS['Blade: Ei'] = set_combine(sets.precast.WS.Magic, {head="Pixie Hairpin +1", ring2="Archon Ring"})
    sets.precast.WS['Blade: Yu'] = set_combine(sets.precast.WS.Magic, {})

    
    
    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {
        head="Herculean Helm",ear2="Loquacious Earring",
        body="Hachiya Chainmail +1",hands="Herculean Gloves",ring1="Prolix Ring",
        legs="Hachiya Hakama",feet="Herculean Boots"}
        
    sets.midcast.Utsusemi = set_combine(sets.midcast.SelfNinjutsu, {ammo="Togakushi Shuriken",neck="Magoraga Bead Necklace",back="Andartia's Mantle",feet="Iga Kyahan +2"})

    sets.midcast.ElementalNinjutsu = {ammo="Yamarang",
        head="Hachiya Hatsuburi",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Hachiya Chainmail +1",hands="Iga Tekko +2",ring1="Icesoul Ring",ring2="Acumen Ring",
        back="Toro Cape",waist=gear.ElementalObi,legs="Malignance Tights",feet="Hachiya Kyahan"}

    sets.midcast.ElementalNinjutsu.Resistant = set_combine(sets.midcast.Ninjutsu, {
        head="Malignance Tabard",neck="Sanctity Necklace",ear1="Lifestorm Earring",ear2="Psystorm Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Sangoma Ring", ring2="Balrahn's Ring",
        back="Yokaze Mantle", waist="Eschan Stone", legs="Malignance Tights", boots="Malignance Boots"})

    sets.midcast.NinjutsuDebuff = {ammo="Yamarang",
        head="Hachiya Hatsuburi",neck="Sanctity Necklace",ear1="Lifestorm Earring",ear2="Psystorm Earring",
        hands="Mochizuki Tekko",ring1="Balrahn's Ring",ring2="Sangoma Ring",
        back="Yokaze Mantle",waist="Eschan Stone",legs="Malignance Rights",feet="Hachiya Kyahan"}
    sets.midcast['Kurayami: Ni'] = set_combine(sets.midcast.NinjutsuDebuff, {ring1="Archon Ring"})
    sets.midcast['Kurayami: Ichi'] = sets.midcast['Kurayami: Ni']
    sets.midcast['Yurin: Ichi'] = sets.midcast['Kurayami: Ni']

    sets.midcast.NinjutsuBuff = {head="Hachiya Hatsuburi",neck="Sanctity Necklace",back="Yokaze Mantle"}

    sets.midcast.RA = {
        head="Malignance Chapeau",neck="Sanctity Necklace",
        body="Malignance Tabard",hands="Hachiya Tekko",ring1="Longshot Ring",ring2="Paqichikaji Ring",
        back="Yokaze Mantle",legs="Malignance Tights",feet="Malignance Boots"}
    -- Hachiya Hakama/Thurandaut Tights +1

    --------------------------------------
    -- Idle/resting/defense/etc sets
    --------------------------------------
    
    -- Resting sets
    sets.resting = {neck="Sanctity Necklace",
        body="hizamaru haramaki",ring1="Sheltered Ring",ring2="Paguroidea Ring"}
    
    -- Idle sets
    sets.idle = {
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Hearty Earring",
        body="Hizamaru Haramaki",hands="Malignance Gloves",ring1="Sheltered Ring",ring2="Karieyh Ring +1",
        back="Atheling Mantle",waist="Flume Belt",legs="Malignance Tights",feet=gear.MovementFeet}

    sets.idle.Town = {main="Raimitsukane",sub="Kaitsuburi",ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Hearty Earring",
        body="Hizamaru Haramaki",hands="Malignance Gloves",ring1="Sheltered Ring",ring2="Paguroidea Ring",
        back="Atheling Mantle",waist="Shetal Stone",legs="Malignance Tights",feet=gear.MovementFeet}
    
    sets.idle.Weak = {
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Suppamonimi",ear2="Cessance Earring",
        body="Hizamaru Haramaki",hands="Malignance Gloves",ring1="Sheltered Ring",ring2="Paguroidea Ring",
        back="Shadow Mantle",waist="Flume Belt",legs="Malignance Tights",feet=gear.MovementFeet}
    
    -- Defense sets
    sets.defense.Evasion = {
        head="Malignance Chapeau",neck="Sanctity Necklace",
        body="Mochizuki Chainmail +1",hands="Malignance Gloves",ring1="Defending Ring",ring2="Beeline Ring",
        back="Yokaze Mantle",waist="Flume Belt",legs="Malignance Tights",feet="Hizamaru Sune-ate"}

    sets.defense.PDT = {ammo="Iron Gobbet",
        head="Malignance Chapeau",neck="Loricate Torque +1",
        body="Mochizuki Chainmail +1",hands="Malignance Gloves",ring1="Defending Ring",ring2=gear.DarkRing.physical,
        back="Shadow Mantle",waist="Flume Belt",legs="Malignance Tights",feet="Hizamaru Sune-ate"}

    sets.defense.MDT = {ammo="Demonry Stone",
        head="Malignance Chapeau",neck="Loricate Torque +1",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Shadow Ring",
        back="Engulfer Cape",waist="Flume Belt",legs="Malignance Tights",feet="Hizamaru Sune-ate"}


    sets.Kiting = {feet=gear.MovementFeet}


    --------------------------------------
    -- Engaged sets
    --------------------------------------

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    sets.engaged = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Iskur Gorget",ear1="Suppanomimi",ear2="Brutal Earring",
        body="Hizamaru Haramaki",hands="Adhemar Wristbands +1",ring1="Rajas Ring",ring2="Epona's Ring",
        back="Atheling Mantle",waist="Shetal Stone",legs="Hizamaru Hizayoroi",feet="Hizamaru sune-ate"}
    sets.engaged.Acc = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Malignance Gloves",ring1="Rajas Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.Evasion = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Malignance Tights",feet="Hizamaru Sune-ate"}
    sets.engaged.Acc.Evasion = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Malignance Tights",feet="Hizamaru Sune-ate"}
    sets.engaged.PDT = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.Acc.PDT = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Malignance Tights",feet="Malignance Boots"}

    -- Custom melee group: High Haste (~20% DW)
    sets.engaged.HighHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Iskur Gorget",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Petrov Ring",ring2="Epona's Ring",
        back="Atheling Mantle",waist="Shetal Stone",legs="Hachiya Hakama",feet="Hizamaru Sune-ate"}
    sets.engaged.Acc.HighHaste = {ammo="Yamagarang",
        head="Malignance Chapeau",neck="Iskur Gorget",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Petrov Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.Evasion.HighHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Hachiya Chainmail +1",hands="Adhemar Wristbands +1",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Hachiya Hakama",feet="Hizamaru Sune-ate"}
    sets.engaged.Acc.Evasion.HighHaste = {ammo="Yamarang",
        head="Adhemar Bonnet +1",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Hachiya Hakama",feet="Hizamaru Sune-ate"}
    sets.engaged.PDT.HighHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Defending Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Hachiya Hakama",feet="Hizamaru Sune-ate"}
    sets.engaged.Acc.PDT.HighHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Defending Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Shetal Stone",legs="Hachiya Hakama",feet="Hizamaru Sune-ate"}

    -- Custom melee group: Embrava Haste (7% DW)
    sets.engaged.EmbravaHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Iskur Gorget",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Rajas Ring",ring2="Epona's Ring",
        back="Atheling Mantle",waist="Windbuffet Belt",legs="Hizamaru Hizayoroi",feet="Hizamaru Sune-ate"}
    sets.engaged.Acc.EmbravaHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Iskur Gorget",ear1="Brutal Earring",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Rajas Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Hurch'lan Sash",legs="Hizamaru Hizayoroi",feet="Hizamaru Sune-ate"}
    sets.engaged.Evasion.EmbravaHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Windbuffet Belt",legs="Hachiya Hakama",feet="Hizamaru Sune-ate"}
    sets.engaged.Acc.Evasion.EmbravaHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Sanctity Necklace",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Hurch'lan Sash",legs="Hachiya Hakama",feet="Hizamaru Sune-ate"}
    sets.engaged.PDT.EmbravaHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Defending Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Windbuffet Belt",legs="Hizamaru Hizayoroi",feet="Hizamaru Sune-ate"}
    sets.engaged.Acc.PDT.EmbravaHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Loricate Torque +1",ear1="Suppanomimi",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Defending Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Hurch'lan Sash",legs="Hizamaru Hizayoroi",feet="Hizamaru Sune-ate"}

    -- Custom melee group: Max Haste (0% DW)
    sets.engaged.MaxHaste = {ammo="Togakushi Shuriken",
        head="Adhemar Bonnet +1",neck="Iskur Gorget",ear1="Brutal Earring",ear2="Cessance Earring",
        body="Mochizuki Chainmail +1",hands="Adhemar Wristbands +1",ring1="Petrov Ring",ring2="Epona's Ring",
        back="Atheling Mantle",waist="Kentarch Belt",legs="Hizamaru Hizayoroi",feet="Hizamaru Sune-ate"}
    sets.engaged.Acc.MaxHaste = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Iskur Gorget",ear1="Brutal Earring",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Petrov Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Hurch'lan Sash",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.Evasion.MaxHaste = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Brutal Earring",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Windbuffet Belt",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.Acc.Evasion.MaxHaste = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Brutal Earring",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Beeline Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Hurch'lan Sash",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.PDT.MaxHaste = {ammo="Togakushi Shuriken",
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Brutal Earring",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Windbuffet Belt",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.Acc.PDT.MaxHaste = {ammo="Yamarang",
        head="Malignace Chapeau",neck="Loricate Torque +1",ear1="Brutal Earring",ear2="Cessance Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Defending Ring",ring2="Epona's Ring",
        back="Yokaze Mantle",waist="Winbuffet Belt",legs="Malignance Tights",feet="Malignance Boots"}


    --------------------------------------
    -- Custom buff sets
    --------------------------------------

    --sets.buff.Migawari = {body="Iga Ningi +2"}
    --sets.buff.Doom = {ring2="Saida Ring"}
    sets.buff.Yonin = {}
    sets.buff.Innin = {}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if state.Buff.Doom then
        equip(sets.buff.Doom)
    end
end


-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if not spell.interrupted and spell.english == "Migawari: Ichi" then
        state.Buff.Migawari = true
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    -- If we gain or lose any haste buffs, adjust which gear set we target.
    if S{'haste','march','embrava','haste samba'}:contains(buff:lower()) then
        determine_haste_group()
        handle_equipping_gear(player.status)
    elseif state.Buff[buff] ~= nil then
        handle_equipping_gear(player.status)
    end
end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Get custom spell maps
function job_get_spell_map(spell, default_spell_map)
    if spell.skill == "Ninjutsu" then
        if not default_spell_map then
            if spell.target.type == 'SELF' then
                return 'NinjutsuBuff'
            else
                return 'NinjutsuDebuff'
            end
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.Buff.Migawari then
        idleSet = set_combine(idleSet, sets.buff.Migawari)
    end
    if state.Buff.Doom then
        idleSet = set_combine(idleSet, sets.buff.Doom)
    end
    return idleSet
end


-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.Buff.Migawari then
        meleeSet = set_combine(meleeSet, sets.buff.Migawari)
    end
    if state.Buff.Doom then
        meleeSet = set_combine(meleeSet, sets.buff.Doom)
    end
    return meleeSet
end

-- Called by the default 'update' self-command.
function job_update(cmdParams, eventArgs)
    procTime(world.time)
    determine_haste_group()
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function determine_haste_group()
    -- We have three groups of DW in gear: Hachiya body/legs, Iga head + Shetal Stone, and DW earrings
    
    -- Standard gear set reaches near capped delay with just Haste (77%-78%, depending on HQs)

    -- For high haste, we want to be able to drop one of the 10% groups.
    -- Basic gear hits capped delay (roughly) with:
    -- 1 March + Haste
    -- 2 March
    -- Haste + Haste Samba
    -- 1 March + Haste Samba
    -- Embrava
    
    -- High haste buffs:
    -- 2x Marches + Haste Samba == 19% DW in gear
    -- 1x March + Haste + Haste Samba == 22% DW in gear
    -- Embrava + Haste or 1x March == 7% DW in gear
    
    -- For max haste (capped magic haste + 25% gear haste), we can drop all DW gear.
    -- Max haste buffs:
    -- Embrava + Haste+March or 2x March
    -- 2x Marches + Haste
    
    -- So we want four tiers:
    -- Normal DW
    -- 20% DW -- High Haste
    -- 7% DW (earrings) - Embrava Haste (specialized situation with embrava and haste, but no marches)
    -- 0 DW - Max Haste
    
    classes.CustomMeleeGroups:clear()
    
    if buffactive.embrava and (buffactive.march == 2 or (buffactive.march and buffactive.haste)) then
        classes.CustomMeleeGroups:append('MaxHaste')
    elseif buffactive.march == 2 and buffactive.haste then
        classes.CustomMeleeGroups:append('MaxHaste')
    elseif buffactive.embrava and (buffactive.haste or buffactive.march) then
        classes.CustomMeleeGroups:append('EmbravaHaste')
    elseif buffactive.march == 1 and buffactive.haste and buffactive['haste samba'] then
        classes.CustomMeleeGroups:append('HighHaste')
    elseif buffactive.march == 2 then
        classes.CustomMeleeGroups:append('HighHaste')
    end
end

function select_weaponskill_ears()
    if world.time >= 17*60 or world.time < 7*60 then
        gear.WSEar1.name = gear.WSNightEar1
        gear.WSEar2.name = gear.WSNightEar2
    else
        gear.WSEar1.name = gear.WSDayEar1
        gear.WSEar2.name = gear.WSDayEar2
    end
end

function update_combat_form()
    --[[if areas.Adoulin:contains(world.area) and buffactive.ionis then
        state.CombatForm:set('Adoulin')
    --else]]
        state.CombatForm:reset()
    --[[end]]--   
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DNC' then
        set_macro_page(4, 13)
    elseif player.sub_job == 'THF' then
        set_macro_page(5, 13)
    else
        set_macro_page(2, 13)
    end
    send_command( "@wait 5;input /lockstyleset 2" )
end

