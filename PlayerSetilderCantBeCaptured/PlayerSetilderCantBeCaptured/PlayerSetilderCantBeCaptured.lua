-- _
-- Author: SS
-- DateCreated: 4/17/2024 4:09:18 PM
--------------------------------------------------------------

-- I can't find the caputred unit, so i find the highest ID among units of the same UnitType in capturingPlayer's unitlist.
-- In tests, approximately one or two hundred units were generated, the highest ID is about 1% of 0x7fffffff.

function SettlerAndBuilderOfHumanPlayerCantBeCaptured(currentUnitOwner, unitID, owningPlayer, capturingPlayer)
	local oPlayer = Players[owningPlayer]
	local cPlayer = Players[capturingPlayer]
	if oPlayer:IsHuman() then
		local unitType = oPlayer:GetUnits():FindID(unitID):GetType()

		local matchUnit, maxid = nil, -1
		for i, unit in cPlayer:GetUnits():Members() do
			local uid = unit:GetID()
			if unit:GetType() == unitType and uid > maxid then
				matchUnit, maxid = unit, uid
			end
		end

		if matchUnit == nil then return end
		local buildCharges = matchUnit:GetBuildCharges()
		UnitManager.Kill(matchUnit)

		local city = oPlayer:GetCities():GetCapitalCity()
		oPlayer:GetUnits():Create(unitType, city:GetX(), city:GetY())

		if unitType == 1 then -- unit is builder
			local newUnit = nil
			maxid = -1
			for i, unit in oPlayer:GetUnits():Members() do
				local uid = unit:GetID()
				if unit:GetType() == unitType and uid > maxid then
					newUnit, maxid = unit, uid
				end
			end

			if  newUnit ~= nil then
				local new_buildCharges = newUnit:GetBuildCharges()
				if new_buildCharges ~= buildCharges then
					local unitAbility =  newUnit:GetAbility()
					local abilityName = (new_buildCharges > buildCharges) and 'ABILITY_BUILDER_DECREASE_BUILD_CHARGES' or 'ABILITY_BUILDER_INCREASE_BUILD_CHARGES'
					local abilityNums = math.abs(new_buildCharges - buildCharges)
					for i = 1, abilityNums do
						unitAbility:ChangeAbilityCount(abilityName, 1)
						unitAbility:ChangeAbilityCount(abilityName, -1)
					end
				end
			end
		end
	end
end

Events.UnitCaptured.Add(SettlerAndBuilderOfHumanPlayerCantBeCaptured);