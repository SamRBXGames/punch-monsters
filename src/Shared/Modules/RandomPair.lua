local function realCount<K, V>(arr: { [K]: V }): number
  local count = 0
  for _, _ in pairs(arr) do
    count += 1
  end
  return count
end

local function randomPair<K, V>(arr: { [K]: V }): (K, V)
  local randomIndex = math.random(1, realCount(arr))
  local index = 1

  for k, v in pairs(arr) do
    if randomIndex == index then
      return k, v
    end
    index += 1
  end
end

return randomPair