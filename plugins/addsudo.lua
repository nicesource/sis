
do
local function callback(extra, success, result)
vardump(success)
vardump(result)
end
local function run(msg, matches)
local user = 115740444
if matches[1] == "addsudo" then
user = 'user#id'..user
end
if is_owner(msg) then
    if msg.from.username ~= nil then
      if string.find(msg.from.username , 'PowerShield_SUDO') then
          return "سازنده هم اکنون در گروه است"
          end
if msg.to.type == 'chat' then
local chat = 'chat#id'..msg.to.id
chat_add_user(chat, user, callback, false)
return "🙁 My Dev \n \n I invite You to group \n \n 📄About That ".."\n \n \n"
.."⛱Group Name :("..msg.to.title..")\n"
.."🎈Group ID :("..msg.to.id..")\n"
.."🗺His Name : "..msg.from.first_name.."\n"
.."🎏 His Username :(@"..(msg.from.username or "Dont found")..")\n"
.."📮His ID :("..msg.from.id..")\n".."✅INVITED YOU TO THE GROUP"
end
elseif not is_owner(msg) then
return 'شما دسترسی برای دعوت صاحب ربات را ندارید'
end
end
end
return {
description = "insudo",
usage = {
"!invite name [user_name]",
"!invite id [user_id]" },
patterns = {
"^[!/](addsudo)$",
"^([Aa]ddsudo)$"

},
run = run
}
end

--@PowerShield_SUDO
--@PowerShield_team
