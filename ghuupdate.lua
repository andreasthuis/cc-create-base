local installRepo = "andreasthuis/cc-create-base"
local ref = ""
local repoPath = ""
local minified = nil

if installRepo == "" then
    error("installRepo is not configured")
end

local repoString = installRepo
if ref ~= "" then
    repoString = repoString .. "@" .. ref
end
if repoPath ~= "" then
    repoString = repoString .. ":" .. repoPath
end

local existingRepos = settings.get("ghu.extraRepos", {})
local addRepoIndex = #existingRepos + 1
for index, repo in ipairs(existingRepos) do
    if #repo >= #installRepo then
        if repo:sub(1, #installRepo) == installRepo then
            local matched = false
            if repoPath == "" then
                if not repo:match(":") then
                    matched = true
                end
            elseif repo:sub(#repo - #repoPath + 1) == repoPath then
                matched = true
            end
            if matched then
                addRepoIndex = index
                break
            end
        end
    end
end
existingRepos[addRepoIndex] = repoString
settings.set("ghu.extraRepos", existingRepos)
if minified ~= nil then
    settings.set(string.format("ghu.minified.%s", repoString), minified)
end
settings.save()

local installBase = "/"

local ghBase = "https://raw.githubusercontent.com/"
local updaterRepo = "andreasthuis/cc-create-base"
local updaterRef = "master"
local updaterUrl = ghBase .. updaterRepo .. "/" .. updaterRef .. "/install.lua"

local ghuUpdatePath = installBase .. "ghuupdate.lua"

if fs.exists(ghuUpdatePath) then
    if shell.run(ghuUpdatePath) then
        print("Install complete at base directory")
    else
        print("Updater failed, trying online install...")
        shell.run(string.format("wget run %s", updaterUrl))
    end
else
    print("No local updater found, downloading from GitHub...")
    shell.run(string.format("wget run %s", updaterUrl))
end
