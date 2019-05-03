function find_race(name)
	for i,v in ipairs(df.global.world.raws.creatures.all) do
		if v.creature_id == name then
			return i
		end
	end
end

function find_entity(race)
	for i,v in ipairs(df.global.world.entities.all) do
		if v.flags.named_civ and v.race == race then
			return i
		end
	end
end

function find_cultural_identity(civ)
	for i,v in ipairs(df.global.world.cultural_identities.all) do
		if v.civ_id == civ then
			return i
		end
	end
end

a = df.army:new()
a.id = df.global.army_next_id
df.global.army_next_id = df.global.army_next_id + 1

a.pos.x = 1000 -- can be anything
a.pos.y = 1000
a.last_pos.x = -1
a.last_pos.y = -1
a.unk_10 = 8 -- wait timer, decreased by 16 each tick, siege occurs when reaches zero

b = df.army.T_unk_2c:new()
b.count = 10
b.race = find_race('HUMAN')
b.civ_id = find_entity(b.race)
b.population_id = df.historical_entity.find(b.civ_id).populations[0]
b.cultural_identity = find_cultural_identity(b.civ_id)

b.unk_10 = 0 -- -> unit.unk_c0
b.unk_18 = 0 -- from xml: made creatures undead, so not sure maybe affliction?
b.unk_1c = 0 -- from xml: crashed df...
b.unk_20 = 0 -- -> unit.enemy.anon_4
b.unk_24 = 0 -- -> unit.enemy.anon_5
b.unk_28 = 0

a.unk_2c:insert(0,b)
printall(b)

a.unk_3c = 50
a.unk_pos_x:insert(0,df.global.world.map.region_x*3)
a.unk_pos_y:insert(0,df.global.world.map.region_y*3)
a.unk_70:insert(0,100)
a.unk_80:insert(0,20)
a.unk_9c = 50
a.unk_a0 = 50
a.unk_a4 = 100

s=df.new('string')
s.value='GENERAL_POISON'
a.creature_class:insert(0,s)

-- don't seem to affect anything
a.item_type = 54
a.mat_type = 37
a.mat_index = 184

ac = df.army_controller:new()

ac.id=df.global.army_controller_next_id
df.global.army_controller_next_id = df.global.army_controller_next_id + 1
-- also ac.id -> unit.enemy.anon_6

ac.entity_id = b.civ_id
ac.unk_8 = df.global.ui.site_id
ac.pos_x = df.global.world.map.region_x*3
ac.pos_y = df.global.world.map.region_y*3
ac.unk_14 = 50
ac.unk_18 = -1
ac.year = df.global.cur_year
ac.year_tick = df.global.cur_year_tick

ac.unk_34 = -1 -- these two are ids of other army controllers, some kind of relationship
ac.unk_38 = -1

ac.unk_3c = 1321 -- these two are some histfig id, can be invalid so don't seem to affect anything
ac.unk_40 = 41164
ac.unk_54 = 0
ac.type = 2

t=df.new('char',100)

-- maybe affects weapons, maybe not
t[0]=4 --4
t[4]=1 --1

t[8]=-1 -- all -1
t[9]=-1
t[10]=-1
t[11]=-1

t[12]=-1 -- all -1
t[13]=-1
t[14]=-1
t[15]=-1

--0x42 0x07 0x00 0x00 0x7f 0x1b 0x00 0x00

t[0x5c] = 0x42 --1858
t[0x5d] = 0x7

t[0x60] = 0x7f --7039
t[0x61] = 0x1b

ac.unk_58 = t

print(a.id)
print(ac.id)

a.controller_id=ac.id
a.controller=ac

df.global.world.army_controllers.all:insert(#df.global.world.army_controllers.all,ac)
df.global.world.armies.all:insert(#df.global.world.armies.all,a)
