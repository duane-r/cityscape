local node = cityscape.node


local function breaker(node)
	if math.random(50) <= cityscape.desolation then
		return "air"
	elseif cityscape.desolation > 0 and math.random(10) <= cityscape.desolation then
		return node.."_broken"
	else
		return node
	end
end


local function crates(data, pos1, pos2)
	local y = math.min(pos2.y, pos1.y)
	for z = pos1.z,pos2.z do
		for x = pos1.x,pos2.x do
			if (data[x][y][z] == node["air"] or data[x][y][z] == nil) and math.random(1000) == 1 then
				data[x][y][z] = node["crate"]
			end
		end
	end
end


local function lights(data, param, pos1, pos2)
	local y = math.max(pos2.y, pos1.y)
	for z = pos1.z,pos2.z do
		for x = pos1.x,pos2.x do
			if (data[x][y][z] == node["air"] or data[x][y][z] == nil) and (data[x][y+1][z] == node["floor_ceiling"] or data[x][y+1][z] == node["roof"]) and math.random(20) == 1 then
				if cityscape.desolation > 0 then
					data[x][y][z] = node["light_panel_broken"]
				else
					data[x][y][z] = node["light_panel"]
				end
				param[#param+1] = {x, y, z, 20} -- 20-23
			end
		end
	end
end


local function roof_box(data, off, sy, dx, dz, tex)
	for z = off,dz-off+1 do
		for x = off,dx-off+1 do
			for y = sy+1,sy+3 do
				if z == off or z == dz-off+1 or x == off or x == dx-off+1 then
					if y < sy + 3 and x == dx - off + 1 and z == math.floor(dz / 2) then
						data[x][y][z] = node["air"]
					else
						data[x][y][z] = node[breaker(tex)]
					end
				end
			end
			if z > off and z < dz-off+1 and x > off and x < dx-off+1 then
				data[x][sy+3][z] = node[breaker("roof")]
			end
		end
	end
end


local function stairwell(data, param, pos1, pos2, left)
	local dz, px, py, pz
	if left then
		dz = 0
	else
		dz = 2
	end

	px = math.floor((pos2.x - pos1.x - 4) / 2)
	py = math.min(pos2.y, pos1.y)
	pz = math.floor((pos2.z - pos1.z - 6) / 2)
	local walls = px > 2 and pz > 2

	if walls then
		for z = 1+dz,6+dz do
			for x = 1,4 do
				for y = 1,3 do
					if z == 1+dz or z == 6+dz or x == 1 or x == 4 then
						if left and x == 2 and z == 1 and y < 3 then
							data[x + px][y + py][z + pz] = node["air"]
						elseif not left and x == 3 and z == 6+dz and y < 3 then
							data[x + px][y + py][z + pz] = node["air"]
						else
							data[x + px][y + py][z + pz] = node[breaker("plaster")]
						end
					end
				end
			end
		end
	end

	if left then
		for i = 1,4 do
			data[2 + px][i + py][2 + i + pz] = node["stair_stone"]
		end
		for i = 1,3 do
			data[2 + px][4 + py][2 + i + pz] = node["air"]
		end
	else
		for i = 1,4 do
			data[3 + px][i + py][7 - i + pz] = node["stair_stone"]
			param[#param+1] = {3+px, i+py, 7-i+pz, 4}
		end
		for i = 1,3 do
			data[3 + px][4 + py][7 - i + pz] = node["air"]
		end
	end
end


local function gotham(data, param, dx, dy, dz)
	local develop, wall_x, wall_x_2, wall_z, wall_z_2
	local dir, y, floors, conc

	local c = math.random(5)
	if c == 1 then
		conc = "concrete"
	else
		conc = "concrete"..c
	end

	local ra = 0
	if math.random(2) == 1 then
		ra = 1
	end
	floors = math.random(2, math.floor(dy / 4) - (1 - ra))

	-- all this for gargoyles...
	if math.random(2) == 1 and floors > 5 then
		for z = 0,dz+1 do
			for x = 0,dx+1 do
				y = floors * 4
				y = y - (y % 4)
				if (x == 0 or x == dx + 1) and z % 5 == 4 then
					data[x][y][z] = node["gargoyle"]
					if x == 0 then
						dir = 18
					else
						dir = 12
					end
					param[#param+1] = {x, y, z, dir}
				elseif (z == 0 or z == dz + 1) and x % 5 == 4 then
					data[x][y][z] = node["gargoyle"]
					if z == 0 then
						dir = 9
					else
						dir = 7
					end
					param[#param+1] = {x, y, z, dir}
				end
			end
		end
	end

	for z = 1,dz do
		for x = 1,dx do
			develop = x > 1 and x < dx and z > 1 and z < dz
			wall_x = x == 1 or x == dx
			wall_z = z == 1 or z == dz
			wall_x_2 = x == 2 or x == dx - 1
			wall_z_2 = z == 2 or z == dz - 1
			for y = 0,(floors * 4) do
				if y % 4 == 0 and x > 2 and z > 2 and x < dx - 1 and z < dz - 1 then
					if floors * 4 - y < 4 then
						data[x][y][z] = node[breaker("roof")]
					else
						data[x][y][z] = node[breaker("floor_ceiling")]
					end
				elseif wall_x then
					if y == 0 then
						data[x][y][z] = node[breaker(conc)]
					elseif z % 5 == 4 then
						data[x][y][z] = node[breaker(conc)]
					else
						data[x][y][z] = node["air"]
					end
				elseif wall_x_2 and develop then
					if y == 0 then
						data[x][y][z] = node[breaker(conc)]
					elseif z % 12 == 3 and y <= 2 and y > 0 then
						data[x][y][z] = node["air"]
					elseif y % 4 ~= 2 or z % 5 == 4 then
						data[x][y][z] = node[breaker(conc)]
					else
						data[x][y][z] = node[breaker("plate_glass")]
					end
				elseif wall_z then
					if y == 0 then
						data[x][y][z] = node[breaker(conc)]
					elseif x % 5 == 4 then
						data[x][y][z] = node[breaker(conc)]
					else
						data[x][y][z] = node["air"]
					end
				elseif wall_z_2 and develop then
					if y == 0 then
						data[x][y][z] = node[breaker(conc)]
					elseif x % 12 == 3 and y <= 2 and y > 0 then
						data[x][y][z] = node["air"]
					elseif y % 4 ~= 2 or x % 5 == 4 then
						data[x][y][z] = node[breaker(conc)]
					else
						data[x][y][z] = node[breaker("plate_glass")]
					end
				else
					data[x][y][z] = node["air"]
				end
			end
		end
	end

	for f = 1,floors-ra do
		stairwell(data, param, {x=2,y=((f-1)*4),z=2}, {x=dx-1,y=(f*4-1),z=dz-1}, (f / 2 == math.floor(f / 2)))
		lights(data, param, {x=3,y=((f-1)*4),z=3}, {x=dx-2,y=(f*4-1),z=dz-2})
		crates(data, {x=3,y=((f-1)*4+1),z=3}, {x=dx-2,y=((f-1)*4+1),z=dz-2})
	end

	if ra == 0 then
		roof_box(data, 6, floors * 4, dx, dz, conc)
	end
end


local function glass_and_steel(data, param, dx, dy, dz)
	local develop, wall_x, wall_z, floors, conc
	local c = math.random(5)
	if c == 1 then
		conc = "concrete"
	else
		conc = "concrete"..c
	end

	local ra = 0
	if math.random(2) == 1 then
		ra = 1
	end
	floors = math.random(2, math.floor(dy / 4) - (1 - ra))

	for z = 1,dz do
		for x = 1,dx do
			wall_x = x == 1 or x == dx
			wall_z = z == 1 or z == dz
			for y = 0,(floors * 4) do
				if y % 4 == 0 and x > 1 and z > 1 and x < dx and z < dz then
					if floors * 4 - y < 4 then
						data[x][y][z] = node[breaker("roof")]
					else
						data[x][y][z] = node[breaker("floor_ceiling")]
					end
				elseif wall_x then
					if (z - 2) % 5 == 2 then
						data[x][y][z] = node[breaker(conc)]
					elseif y == 0 then
						data[x][y][z] = node[breaker(conc)]
					elseif z == 6 and y <= 2 then
						data[x][y][z] = node["air"]
					else
						data[x][y][z] = node[breaker("plate_glass")]
					end
				elseif wall_z then
					if (x - 2) % 5 == 2 then
						data[x][y][z] = node[breaker(conc)]
					elseif y == 0 then
						data[x][y][z] = node[breaker(conc)]
					elseif x == 6 and y <= 2 then
						data[x][y][z] = node["air"]
					else
						data[x][y][z] = node[breaker("plate_glass")]
					end
				end
			end
		end
	end

	for f = 1,floors-ra do
		stairwell(data, param, {x=1,y=((f-1)*4),z=1}, {x=dx,y=(f*4-1),z=dz}, (f / 2 == math.floor(f / 2)))
		lights(data, param, {x=1,y=((f-1)*4),z=1}, {x=dx,y=(f*4-1),z=dz})
		crates(data, {x=1,y=((f-1)*4+1),z=1}, {x=dx,y=((f-1)*4+1),z=dz})
	end

	if ra == 0 then
		roof_box(data, 6, floors * 4, dx, dz, conc)
	end
end


local function simple(data, param, dx, dy, dz, slit)
	local develop, wall_x, wall_z, floors, conc, c

	local ra = 0
	if math.random(2) == 1 then
		ra = 1
	end
	floors = math.random(2, math.floor(dy / 4) - (1 - ra))

	if floors < 6 then
		c = math.random(9)
	else
		c = math.random(5)
	end

	if c == 1 then
		conc = "concrete"
	elseif c == 6 then
		conc = "brick"
	elseif c == 7 then
		conc = "sandstone_brick"
	elseif c == 8 then
		conc = "stone_brick"
	elseif c == 9 then
		conc = "desert_stone_brick"
	else
		conc = "concrete"..c
	end

	for z = 1,dz do
		for x = 1,dx do
			wall_x = x == 1 or x == dx
			wall_z = z == 1 or z == dz
			for y = 0,(floors * 4) do
				if y % 4 == 0 and x > 1 and z > 1 and x < dx and z < dz then
					if floors * 4 == y then
						data[x][y][z] = node[breaker("roof")]
					else
						data[x][y][z] = node[breaker("floor_ceiling")]
					end
				elseif wall_x then
					if z == 6 and y <= 2 and y > 0 then
						data[x][y][z] = node["air"]
					elseif slit and z % 2 == 0 and y % 4 > 1 then
						data[x][y][z] = node[breaker("plate_glass")]
					elseif not slit and math.floor(z / 2) % 2 == 1 and y % 4 > 1 then
						data[x][y][z] = node[breaker("plate_glass")]
					else
						data[x][y][z] = node[breaker(conc)]
					end
				elseif wall_z then
					if x == 6 and y <= 2 and y > 0 then
						data[x][y][z] = node["air"]
					elseif slit and x % 2 == 0 and y % 4 > 1 then
						data[x][y][z] = node[breaker("plate_glass")]
					elseif not slit and math.floor(x / 2) % 2 == 1 and y % 4 > 1 then
						data[x][y][z] = node[breaker("plate_glass")]
					else
						data[x][y][z] = node[breaker(conc)]
					end
				end
			end
		end
	end

	for f = 1,floors-ra do
		stairwell(data, param, {x=1,y=((f-1)*4),z=1}, {x=dx,y=(f*4-1),z=dz}, (f / 2 == math.floor(f / 2)))
		lights(data, param, {x=1,y=((f-1)*4),z=1}, {x=dx,y=(f*4-1),z=dz})
		crates(data, {x=1,y=((f-1)*4+1),z=1}, {x=dx,y=((f-1)*4+1),z=dz})
	end

	if ra == 0 then
		roof_box(data, 6, floors * 4, dx, dz, conc)
	end
end


function cityscape.build(data, param, dx, dy, dz)
	local sr = math.random(4)

	if math.random(10) <= cityscape.vacancies then
		return
	end

	if sr == 1 then
		gotham(data, param, dx, dy, dz)
	elseif sr == 2 then
		glass_and_steel(data, param, dx, dy, dz)
	elseif sr == 3 then
		simple(data, param, dx, dy, dz)
	elseif sr == 4 then
		simple(data, param, dx, dy, dz, true)
	end
end
