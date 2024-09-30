local tableUtil = {}

function tableUtil.size(tabl)
	local size = 0

	for _ in tabl do
		size += 1
	end

	return size
end

function tableUtil.find(tabl, value)
	for k, v in tabl do
		if v == value then
			return k
		end
	end

	return nil
end

function tableUtil.merge(t1, t2)
	local n = table.clone(t1)

	for key, value in t2 do
		n[key] = value
	end

	return n
end

return table.freeze(tableUtil)
