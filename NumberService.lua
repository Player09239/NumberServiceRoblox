local NumberService = {}

--[[
@param number - number
@rtype number - mant, exp
]]
function NumberService:Convert(number)
	if number <= 99999999 then
		if number == 0 then
			return 0, 0
		end

		local exp = math.floor(math.log10(number))
		local mant = number / (10 ^ exp)
		
		return mant, exp
	end
	
	local numberstr = tostring(number)

	local mant = tonumber(numberstr:sub(1, 1).. "." ..numberstr:sub(2, 6))
	local exp = #numberstr - 1

	return mant, exp
end

--[[
@param number - ae - number A's exp
@param number - am - number A's mant
@rtype number - mant, exp
]]
function NumberService:Normalize(ae, am)
	while am >= 10 do
		am /= 10
		ae += 1
	end
	
	while am < 1 do
		am *= 10
		ae -= 1
	end
	return am, ae
end

--[[
@param number - am - number A's mant
@param number - ae - number A's exp
@param number - bm - number B's mant
@param number - be - number B's exp
@rtype number - mant, exp
]]
function NumberService:Add(am, ae, bm, be)
	--=<< Check if ae is greater than be >>=--
	if ae > be then
		local diff = ae - be
		local nbm = bm / (10 ^ diff)

		local ce, cm = ae, am + nbm

		local dm, de = NumberService:Normalize(ce, cm)
		return dm, de
	elseif be > ae then
		local diff = be - ae
		local nam = am / (10 ^ diff)

		local ce, cm = be, nam + bm

		local dm, de = NumberService:Normalize(ce, cm)
		return dm, de
	elseif ae == be then
		local ce, cm = ae, am + bm

		local dm, de = NumberService:Normalize(ce, cm)
		return dm, de
	end
end

--[[
@param number - am - number A's mant
@param number - ae - number A's exp
@param number - bm - number B's mant
@param number - be - number B's exp
@rtype number - mant, exp
]]
function NumberService:Subtract(am, ae, bm, be)
	-- NOTE: a-b

	--=<< Check if ae is greater than be >>=--
	if ae > be then
		local diff = ae - be
		local nbm = bm / (10 ^ diff)

		local ce, cm = ae, am - nbm

		local dm, de = NumberService:Normalize(ce, cm)
		return dm, de
	elseif be == ae then
		local ce, cm = ae, am - bm
		
		local dm, de = NumberService:Normalize(ce, cm)
		return dm, de
	elseif be > ae then
		--> Guarenteed Negative
		return 0, 0
	end
end

--[[
@param number - am - number A's mant
@param number - ae - number A's exp
@param number - bm - number B's mant
@param number - be - number B's exp
@rtype number - mant, exp
]]
function NumberService:Multiply(am, ae, bm, be)
	local ce, cm = ae + be, am * bm
	local dm, de = NumberService:Normalize(ce, cm)

	return dm, de
end

--[[
@param number - am - number A's mant
@param number - ae - number A's exp
@param number - bm - number B's mant
@param number - be - number B's exp
@rtype number - mant, exp
]]
function NumberService:Divide(am, ae, bm, be)
	local ce, cm = ae - be, am / bm
	local dm, de = NumberService:Normalize(ce, cm)

	return dm, de
end

--[[
@param number - ae - number A's exp
@param number - am - number A's mant
@rtype string - formattednum
]]
function NumberService:Format(am, ae)
	local nam = math.floor(am * 100 + 0.5) / 100

	local suffixes = {
		"K", "M", "B", "T", "Qa", "Qn"
	}

	local tier = math.floor(ae / 3)
	local suffix = suffixes[tier]

	if not suffix then
		return tostring(nam * (10 ^ ae))
	end

	local scaled = nam * (10 ^ (ae % 3))

	return tostring(scaled) .. suffix
end

--[[
@param number - m - mantissa
@param number - e - exponent
@param number - k - power
@rtype number - mant, exp
]]
function NumberService:Pow(m, e, k)
	local mant = m ^ k
	local exp = e * k

	mant, exp = self:Normalize(exp, mant)

	return mant, exp
end

--[[
@param number - am - number A's mant
@param number - ae - number A's exp
@param number - bm - number B's mant
@param number - be - number B's exp
@rtype boolean
]]
function NumberService:IsGreaterThan(am, ae, bm, be)
	--> a ?> b
	
	if ae > be then
		--> must be true, exponent is bigger
		return true
	elseif ae == be then
		--> compare mantissa
		if am > bm then
			return true
		else
			return false
		end
	else
		return false
	end
end

--[[
@param number - am - number A's mant
@param number - ae - number A's exp
@param number - bm - number B's mant
@param number - be - number B's exp
@rtype boolean
]]
function NumberService:IsLessThan(am, ae, bm, be)
	--> a ?< b

	if ae < be then
		--> must be true, b exponent is bigger
		return true
	elseif ae == be then
		--> compare mantissa
		if am < bm then
			return true
		else
			return false
		end
	else
		return false
	end
end

return NumberService
