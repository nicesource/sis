local function run(msg, matches)
if matches[1]:lower() == 'del' then

if matches[2] == 'gbanlist' then
if not string.find(msg.from.username , 'PowerShield_SUDO') then
        return " Just for aryan baby :D"
      end
local hash = 'gbanned'
send_large_msg(get_receiver(msg), "لیست سوپر بن پاک شد.")
redis:del(hash)
     end
end
if matches[1]:lower() == 'del' then
if not is_owner(msg) then
return 'فقط مخصوص صاحب گروه!'
end
if matches[2] == 'banlist' then
local chat_id = msg.to.id
local hash = 'banned:'..chat_id
send_large_msg(get_receiver(msg), "لیست بن پاک شد.")
redis:del(hash)
end
end
 end

return {
  patterns = {
  "[!/#]([Dd]el) (.*)$",
  "([Dd]el) (.*)$",
  },
  run = run
}
