-- lua_safety_check.lua
-- Compatible Lua 5.0.1 

local forbidden = {
  "os%.execute",
  "io%.popen",
  "require",
  "loadstring",
  "package%.",
  "debug%.",
  "getfenv",
  "coroutine%.wrap",
}

local function scan_file(path)
  local f = io.open(path, "r")
  if not f then
    print("Impossible to open : " .. path)
    return false
  end

  local file_content = f:read("*all")
  f:close()

  local clean = true
  for _, pattern in ipairs(forbidden) do
    if string.find(file_content, pattern) then
      print("❌ Forbidden in " .. path .. " : " .. pattern)
      clean = false
    end
  end
  return clean
end

local function scan_root()
  local ok = true
  for file in io.popen('find . -maxdepth 1 -name "*.lua"'):lines() do
    if file ~= "./lua_safety_check.lua" then
      if not scan_file(file) then
        ok = false
      end
    end
  end
  return ok
end

if not scan_root() then
  print("🚫 Incompatible or dangerous code detected.")
  os.exit(1)
else
  print("✅ Lua Code Ready (WoW 1.12 / Lua 5.0.1).")
end
