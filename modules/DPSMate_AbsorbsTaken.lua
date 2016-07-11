-- Global Variables
DPSMate.Modules.AbsorbsTaken = {}
DPSMate.Modules.AbsorbsTaken.Hist = "Absorbs"
DPSMate.Options.Options[1]["args"]["absorbstaken"] = {
	order = 120,
	type = 'toggle',
	name = DPSMate.L["absorbstaken"],
	desc = DPSMate.L["show"].." "..DPSMate.L["absorbstaken"]..".",
	get = function() return DPSMateSettings["windows"][DPSMate.Options.Dewdrop:GetOpenedParent().Key]["options"][1]["absorbstaken"] end,
	set = function() DPSMate.Options:ToggleDrewDrop(1, "absorbstaken", DPSMate.Options.Dewdrop:GetOpenedParent()) end,
}

-- Register the moodule
DPSMate:Register("absorbstaken", DPSMate.Modules.AbsorbsTaken, DPSMate.L["absorbstaken"])

local tinsert = table.insert
local strformat = string.format

function DPSMate.Modules.AbsorbsTaken:GetSortedTable(arr,k)
	local b, a, total = {}, {}, 0
	local temp = {}
	for cat, val in pairs(arr) do -- 28 Target
		if DPSMate:ApplyFilter(k, DPSMate:GetUserById(cat)) then
			local PerPlayerAbsorb = 0
			for ca, va in pairs(val) do -- 28 Owner
				local PerOwnerAbsorb = 0
				for c, v in pairs(va) do -- Power Word: Shield
					if c~="i" then
						local PerAbilityAbsorb = 0
						for ce, ve in pairs(v) do -- 1
							local PerShieldAbsorb = 0
							for cet, vel in pairs(ve) do
								if cet~="i" then
									local p = 5
									if DPSMateDamageTaken[1][cat] then
										if DPSMateDamageTaken[1][cat][cet] then
											if DPSMateDamageTaken[1][cat][cet][vel[1]] then
												if DPSMateDamageTaken[1][cat][cet][vel[1]][14]~=0 then
													p=ceil(DPSMateDamageTaken[1][cat][cet][vel[1]][14])
												end
											end
										end
									end
									PerShieldAbsorb=PerShieldAbsorb+vel[2]*p
								end
							end
							if ve["i"][1]==1 then
								PerShieldAbsorb=PerShieldAbsorb+ve["i"][2]
							end
							PerAbilityAbsorb = PerAbilityAbsorb+PerShieldAbsorb
						end
						PerOwnerAbsorb = PerOwnerAbsorb+PerAbilityAbsorb
					end
				end
				PerPlayerAbsorb = PerPlayerAbsorb+PerOwnerAbsorb
			end
			total = total+PerPlayerAbsorb
			local i = 1
			while true do
				if (not b[i]) then
					tinsert(b, i, PerPlayerAbsorb)
					tinsert(a, i, cat)
					break
				else
					if b[i] < PerPlayerAbsorb then
						tinsert(b, i, PerPlayerAbsorb)
						tinsert(a, i, cat)
						break
					end
				end
				i=i+1
			end
		end
	end
	return b, total, a
end

function DPSMate.Modules.AbsorbsTaken:EvalTable(user, k)
	local arr = DPSMate:GetMode(k)
	local b, a, total = {}, {}, 0
	for cat, val in arr[user[1]] do -- 28 Target
		local PerTargetAbsorb, ta, tb = 0, {}, {}
		for ca, va in pairs(val) do -- Power Word Shield
			if ca~="i" then
				local PerAbilityAbsorb, taa, tbb, temp = 0, {}, {}, {}
				for c, v in pairs(va) do -- 1
					local PerShieldAbsorb = 0
					for ce, ve in pairs(v) do
						if ce~="i" then
							local p = 5
							if DPSMateDamageTaken[1][user[1]] then
								if DPSMateDamageTaken[1][user[1]][ce] then
									if DPSMateDamageTaken[1][user[1]][ce][ve[1]] then
										if DPSMateDamageTaken[1][user[1]][ce][ve[1]][14]~=0 then
											p=ceil(DPSMateDamageTaken[1][user[1]][ce][ve[1]][14])
										end
									end
								end
							end
							PerShieldAbsorb=PerShieldAbsorb+ve[2]*p
							if not temp[ce] then temp[ce] = {} end
							if not temp[ce][ve[1]] then temp[ce][ve[1]] = ve[2]*p else temp[ce][ve[1]] =temp[ce][ve[1]]+ve[2]*p end
						end
					end
					if v["i"][1]==1 then
						PerShieldAbsorb=PerShieldAbsorb+v["i"][2]
						if not temp[v["i"][4]] then temp[v["i"][4]] = {} end
						if not temp[v["i"][4]][v["i"][3]] then temp[v["i"][4]][v["i"][3]] = v["i"][2] else temp[v["i"][4]][v["i"][3]] = temp[v["i"][4]][v["i"][3]] + v["i"][2] end
					end
					PerAbilityAbsorb=PerAbilityAbsorb+PerShieldAbsorb
				end
				PerTargetAbsorb=PerTargetAbsorb+PerAbilityAbsorb
				for ut, utt in temp do
					local CVV, qa, qd = 0, {}, {}
					for qt, qtt in utt do
						CVV = CVV + qtt
						local i = 1
						while true do
							if (not qd[i]) then
								tinsert(qd, i, qtt)
								tinsert(qa, i, qt)
								break
							else
								if qd[i] < qtt then
									tinsert(qd, i, qtt)
									tinsert(qa, i, qt)
									break
								end
							end
							i=i+1
						end
					end
					local i = 1
					while true do
						if (not tbb[i]) then
							tinsert(tbb, i, {CVV, qa, qd})
							tinsert(taa, i, ut)
							break
						else
							if tbb[i][1] < CVV then
								tinsert(tbb, i, {CVV, qa, qd})
								tinsert(taa, i, ut)
								break
							end
						end
						i=i+1
					end
				end
				local i = 1
				while true do
					if (not tb[i]) then
						tinsert(tb, i, {PerAbilityAbsorb, taa, tbb})
						tinsert(ta, i, ca)
						break
					else
						if tb[i][1] < PerAbilityAbsorb then
							tinsert(tb, i, {PerAbilityAbsorb, taa, tbb})
							tinsert(ta, i, ca)
							break
						end
					end
					i=i+1
				end
			end
		end
		local i = 1
		while true do
			if (not b[i]) then
				tinsert(b, i, {PerTargetAbsorb, ta, tb})
				tinsert(a, i, cat)
				break
			else
				if b[i][1] < PerTargetAbsorb then
					tinsert(b, i, {PerTargetAbsorb, ta, tb})
					tinsert(a, i, cat)
					break
				end
			end
			i=i+1
		end
		total=total+PerTargetAbsorb
	end
	return a, total, b
end

function DPSMate.Modules.AbsorbsTaken:GetSettingValues(arr, cbt, k,ecbt)
	local name, value, perc, sortedTable, total, a, p, strt = {}, {}, {}, {}, 0, 0, "", {[1]="",[2]=""}
	if DPSMateSettings["windows"][k]["numberformat"] == 2 then p = "K" end
	sortedTable, total, a = DPSMate.Modules.AbsorbsTaken:GetSortedTable(arr,k)
	for cat, val in pairs(sortedTable) do
		local va, tot, sort = DPSMate:FormatNumbers(val, total, sortedTable[1], k)
		if va==0 then break end
		local str = {[1]="",[2]="",[3]="",[4]=""}
		local pname = DPSMate:GetUserById(a[cat])
		if DPSMateSettings["columnsabsorbstaken"][1] then str[1] = " "..va..p; strt[2] = " "..tot..p end
		if DPSMateSettings["columnsabsorbstaken"][2] then str[2] = " ("..strformat("%.1f", 100*va/tot).."%)" end
		if DPSMateSettings["columnsabsorbstaken"][3] then str[3] = " ("..strformat("%.1f", va/cbt)..p..")" end
		if DPSMateSettings["columnsabsorbstaken"][4] then str[4] = " ("..strformat("%.1f", va/(ecbt[pname] or cbt))..p..")" end
		tinsert(name, pname)
		tinsert(value, str[1]..str[3]..str[4]..str[2])
		tinsert(perc, 100*(va/sort))
	end
	return name, value, perc, strt
end

function DPSMate.Modules.AbsorbsTaken:ShowTooltip(user, k)
	local a,b,c = DPSMate.Modules.AbsorbsTaken:EvalTable(DPSMateUser[user], k)
	if DPSMateSettings["informativetooltips"] then
		for i=1, DPSMateSettings["subviewrows"] do
			if not a[i] then break end
			GameTooltip:AddDoubleLine(i..". "..DPSMate:GetUserById(a[i]),c[i][1].." ("..strformat("%2.f", 100*c[i][1]/b).."%)",1,1,1,1,1,1)
		end
	end
end

function DPSMate.Modules.AbsorbsTaken:OpenDetails(obj, key)
	DPSMate.Modules.DetailsAbsorbsTaken:UpdateDetails(obj, key)
end

function DPSMate.Modules.AbsorbsTaken:OpenTotalDetails(obj, key)
	--DPSMate.Modules.DetailsDamageTotal:UpdateDetails(obj, key)
	DPSMate:SendMessage("This feature will be added soon!")
end

