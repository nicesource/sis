--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "Promote me to admin first!")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  lock_arabic = 'no',
		  lock_link = "no",
          flood = 'yes',
		  lock_spam = 'yes',
		  lock_sticker = 'no',
		  member = 'no',
		  public = 'no',
		  lock_rtl = 'no',
		  lock_tgservice = 'yes',
		  lock_contacts = 'no',
		  strict = 'no'
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
	 local hash = 'group:'..msg.to.id
     local group_lang = redis:hget(hash,'lang')
     save_data(_config.moderation.data, data)
     if group_lang then 
     local textfa = "سوپرگروه[" ..string.gsub(msg.to.print_name, "_", " ").. "]باموفقت ثبت شد"
     return reply_msg(msg.id, textfa, ok_cb, false)
     else
     local text = "SuperGroup[" ..string.gsub(msg.to.print_name, "_", " ").. "]added"
     return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end
end
--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
	  local hash = 'group:'..msg.to.id
      local group_lang = redis:hget(hash,'lang')
      if group_lang then
	  local textfa = "سوپرگروه[" ..string.gsub(msg.to.print_name, "_", " ").. "]ازلیست گروه هاحذف شد"
      return reply_msg(msg.id, textfa, ok_cb, false)
      else
	  local text = "SuperGroup[" ..string.gsub(msg.to.print_name, "_", " ").. "]removed"
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end
end
--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type.." for "..chat_name..":\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

local function callback_clean_bots (extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	for k,v in pairs(result) do
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
	end
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "Members for "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
--vardump(result)
local text = "Kicked Members for SuperGroup "..cb_extra.receiver.."\n\n"
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		name = name.." @"..v.username
	end
	text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "لینک از قبل قفل بود"
	else
    return "Link posting is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "لینک قفل شد"
	else
    return "Link posting has been locked"
  end
 end
end
local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
  	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "لینک قفل نشده"
	else
    return " Link posting is not locked"
	end
else
  ------------
  local function lock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "ربات از قبل قفل بود"
	else
    return "Bots is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_bots'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "لینک قفل شد"
	else
    return "Bots has been locked"
  end
 end
end
local function unlock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'no' then
  	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "ادد کردن ربات از قبل آزاد بود"
	else
    return "Bots lock is not locked"
	end
  else
    data[tostring(target)]['settings']['lock_bots'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "ربات آزاد شد"
	else
    return "bots has been unlocked"
  end
 end
end
------------
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل لینک ازاد شد"
	else
    return "Link posting has been unlocked"
  end
 end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
  	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل اسپم از قبل فعال بود"
	else
    return "SuperGroup spam is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل اسپم فعال شد"
	else
    return "SuperGroup spam has been locked"
  end
 end
end
local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return "قفل اسپم فعال نبوده"
  else
  return " spam is not locked"
  end
  else
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل اسپم ازادشد"
	else
    return "SuperGroup spam has been unlocked"
  end
 end
end
----
local function lock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "فوروارد از قبل قفل بود"
	else
    return "Forward is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_fwd'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "فوروارد قفل شد"
	else
    return "Forward has been locked"
  end
 end
end
local function unlock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == 'no' then
  	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "فوروارد از قبل آزاد بود"
	else
    return "Forward is not locked"
	end
  else
    data[tostring(target)]['settings']['lock_fwd'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "فوروارد آزاد شد"
	else
    return "Forward has been unlocked"
  end
 end
end
-----
local function lock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_lock = data[tostring(target)]['settings']['lock_fosh']
  if group_fosh_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "فحش از قبل قفل بود"
	else
    return "Fosh is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_fosh'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "فحش قفل شد"
	else
    return "Fosh has been locked"
  end
 end
end
local function unlock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_lock = data[tostring(target)]['settings']['lock_fosh']
  if group_fosh_lock == 'no' then
  	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "فحش از قبل آزاد بود"
	else
    return "Fosh is not locked"
	end
  else
    data[tostring(target)]['settings']['lock_fosh'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "فحش آزاد شد"
	else
    return "fosh has been unlocked"
  end
 end
end
----
local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "قفل فلود از قبل فعال بود"
	else
    return "Flood is already locked"
	end
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل فعال شد"
	else
    return "Flood has been locked"
  end
 end
end
local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "فلود قفل نبوده"
	else
    return " Flood is not locked"
	end
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل قلو ازاد شد"
	else
    return "Flood has been unlocked"
  end
 end
end
local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "قفل عربی ازقبل فعال بود"
	else
    return "Arabic/persian is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "عربی قفل شد"
	else
    return "Arabic/persian has been locked"
  end
 end
end
local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
    local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل عربی فعال نبوده"
	else
    return "Arabic/Persian is not unlocked"
	end
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل عربی ازاد شد"
	else
    return "Arabic/Persian has been unlocked"
  end
 end
end
local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
  	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفال اعضا ازقبل فعال بود"
	else
    return "SuperGroup members are already locked"
	end
  else
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل اعضا فعال شد"
	else
    return "SuperGroup members has been locked"
  end
 end
end
local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "قفل اعضا فعال نیست"
	else
    return " supergroup member not lock"
	end
  else
    data[tostring(target)]['settings']['lock_member'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل اعضا ازاد شد"
	else
    return "SuperGroup members has been unlocked"
  end
 end
end
local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "قفل ار تی ال از قبل فعال بود"
	else
    return "RTL is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل ار تی ال فعال شد"
	else
    return "RTL has been locked"
  end
 end
end
local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "قفل ار تی ال فعال نیست"
	else
    return " RTL not lock"
	end
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل ار تی ال ازادشد"
	else
    return "RTL has been unlocked"
  end
 end
end
local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "سرویس تلگرام ازقبل قفل بود"
	else
    return "Tgservice is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "سرویس تلگرام قفل شد"
	else
    return "Tgservice has been locked"
  end
 end
end
local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "سرویس تلگرام قفل نیست"
	else
    return " TgService Is Not Locked!"
	end
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل سرویس تلگرام ازادشد"
	else
    return "Tgservice has been unlocked"
  end
 end
end
local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "قفل استیکرازقبل فعال بود"
	else
    return "Sticker posting is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "استیکر قفل شد"
	else
    return "Sticker posting has been locked"
  end
 end
end
local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "استیکر قفل نشده"
	else
    return "Sticker Is Not Locked!"
	end
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل استیکر ازادشد"
	else
    return "Sticker posting has been unlocked"
  end
 end
end
local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "قفل شماره ازقبل فعال بود"
	else
    return "Contact posting is already locked"
	end
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "شماره قفل شد"
	else
    return "Contact posting has been locked"
  end
 end
end
local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "شماره قفل نبوده"
	else
    return " contacts Is Not Locked!"
	end
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "قفل شماره ازاد شد"
	else
    return "Contact posting has been unlocked"
  end
 end
end
local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "تنظیمات سخت فعال بود"
	else
    return "Settings are already strictly enforced"
	end
  else
    data[tostring(target)]['settings']['strict'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "تنظیمات سخت فعال شد"
	else
    return "Settings will be strictly enforced"
  end
 end
end
local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'no' then
  	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	return "تنظیمات اسان شد"
	else
    return "Settings are not strictly enforced"
	end
  else
    data[tostring(target)]['settings']['strict'] = 'no'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
    return "تنظیمات اسان بود"
	else
    return "Settings will not be strictly enforced"
  end
 end
end
--End supergroup locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return "قوانین تنظیم شد"
  else
  return "SuperGroup rules set"
 end
end
--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "قوانینی ثبت نشده"
	else
    return "No rules available."
  end
 end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = group_name..' rules:\n\n'..rules:gsub("/n", " ")
  return rules
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return "گروه عمومی شد"
  else
  return "Group is already public"
  end
  else
    data[tostring(target)]['settings']['public'] = 'yes'
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
    return "گروه عمومی بود"
    else
    return "SuperGroup is now: public"
  end
 end
end
local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'no' then
  	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
    return "گروه عمومی نبود"
    else
    return "Group is not public."
	end
    else
    data[tostring(target)]['settings']['public'] = 'no'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
    return "گروه از عمومی خارج شد"
    else
    return "SuperGroup is now: not public"
   end
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 5
      	end
    end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = 'no'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_fosh'] then
			data[tostring(target)]['settings']['lock_fosh'] = 'no'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_fwd'] then
			data[tostring(target)]['settings']['lock_fwd'] = 'no'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_bots'] then
			data[tostring(target)]['settings']['lock_bots'] = 'no'
		end
end
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = 'no'
		end
	end
    local groupmodel = "normal"
    if data[tostring(msg.to.id)]['settings']['groupmodel'] then
    	groupmodel = data[tostring(msg.to.id)]['settings']['groupmodel']
   	end
	local version = "1.5"
    if data[tostring(msg.to.id)]['settings']['version'] then
    	version = data[tostring(msg.to.id)]['settings']['version']
   	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
        if not data[tostring(msg.to.id)]['settings']['warn_max'] then
            data[tostring(msg.to.id)]['settings']['warn_max'] = 'not set'
        end
     end
    if data[tostring(target)]['settings'] then
        if not data[tostring(msg.to.id)]['settings']['warn_mod'] then
           data[tostring(msg.to.id)]['settings']['warn_mod'] = 'not set'
     end
   end
   -------
local group_owner = data[tostring(msg.to.id)]['set_owner']
local expiretime = redis:hget('expiretime', get_receiver(msg))
    local expire = ''
  if not expiretime then
  expire = expire..'Not Set'
  else
   local now = tonumber(os.time())
   expire =  expire..math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
 end
 -------
  local settings = data[tostring(target)]['settings']
  local i = 1
  local messagefa = ' 👥<code>لیست مدیران گروه :</code>\n'
  local message = '👥<i>moderators list:</i>\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
   messagefa = messagefa ..i..' -> <code>'..v..'</code><b> [' ..k.. ']</b> \n'
   message = message ..i..' -> <code>'..v..'</code><b>[' ..k.. ']</b> \n'

  i = i + 1
  end
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  local textfa = "⚙تنظیمات سوپرگروه "..string.gsub(msg.to.print_name, "_", " ")..""..messagefa.."\n🔰قفل لینک: "..settings.lock_link.."\n🔰قفل استیکر: "..settings.lock_sticker.."\n🔰قفل فحش : "..settings.lock_fosh.."\n🔰قفل فلود: "..settings.flood.."\n🔰قفل فوروارد:"..settings.lock_fwd.."\n🔰قفل اسپم: "..settings.lock_spam.."\n🔰قفل عربی: "..settings.lock_arabic.."\n🔰قفل اعضا: "..settings.lock_member.."\n🔰قفل ار تی ال: "..settings.lock_rtl.."\n🔰قفل سرویس تلگرام: "..settings.lock_tgservice.."\n🔰قفل استیکر: "..settings.lock_sticker.."\n🔰تنظیمات عمومی: "..settings.public.."\n🔰سخت گیرانه: "..settings.strict.."\n〰〰〰〰〰〰〰〰〰〰\n🚨مدل حساسیت: "..NUM_MSG_MAX.."\nمدل گروه : "..groupmodel.."\n💭زبان: 🇮🇷فارسی🇮🇷\n📍ورژن:"..version.."\n"
  textfa = string.gsub(textfa, 'no', 'خیر')
  textfa = string.gsub(textfa, 'yes', 'بله')
  textfa = string.gsub(textfa, 'free', 'رایگان')
  textfa = string.gsub(textfa, 'vip', 'اختصاصی')
  textfa = string.gsub(textfa, 'realm', 'ریلیم')
  textfa = string.gsub(textfa, 'support', 'ساپورت')
  textfa = string.gsub(textfa, 'feedback', 'پشتیبانی')
  textfa = string.gsub(textfa, 'normal', 'متوسط')
  return reply_msg(msg.id, textfa, ok_cb, false)
  else
  local text = "💠️<i>Supergroup settings for :</i>\n <code>"..string.gsub(msg.to.print_name, "_", " ").."</code>\n"
  local text = text..""..message.."\n"
  local text = text.."▫️<b> Lock Contacts </b><code>= "..settings.lock_contacts.." </code>\n"
  local text = text.."▪️<b> Lock links </b><code>= "..settings.lock_link.." </code>\n"
  local text = text.."▫️<b> Lock flood </b><code>= "..settings.flood.." </code>\n"
  local text = text.."▪️<b> Lock Fosh </b><code>= "..settings.lock_fosh.." </code>\n"
  local text = text.."▪️<b> Lock Bots </b><code>= "..settings.lock_bots.." </code>\n"
  local text = text.."▫️<b> Lock spam </b><code>= "..settings.lock_spam.." </code>\n"
  local text = text.."▪️<b> Lock Arabic </b><code>= "..settings.lock_arabic.." </code>\n"
  local text = text.."▫️<b> Lock RTL </b><code>= "..settings.lock_rtl.." </code>\n"
  local text = text.."▪️<b> Lock Tgservice </b><code>= "..settings.lock_tgservice.." </code>\n"
  local text = text.."▫️<b> Lock Forward(fwd) </b><code>= "..settings.lock_fwd.." </code>\n"
  local text = text.."▪️<b> Lock Member </b><code>= "..settings.lock_member.." </code>\n"
  local text = text.."▫️<b> Lock sticker </b><code>= "..settings.lock_sticker.." </code>\n"
  local text = text.."▪️<b> Public </b><code>= "..settings.public.." </code>\n"
  local text = text.."▫️<b> Strict settings </b><code>= "..settings.strict.." </code>\n"
  local text = text.."▪️<b> Flood sensitivity </b><code>= "..NUM_MSG_MAX.." </code>\n"
  local text = text.."<i>〰〰〰〰〰〰〰〰〰〰</i>\n"
  local text = text.."🔇🔊<b>"..mutes_list(msg.to.id).." </b>"
  local text = text.."<i>〰〰〰〰〰〰〰〰〰〰</i>\n"
  local text = text.."▫️<b> Max warn </b><code>= "..settings.warn_max.." </code>\n"
  local text = text.."▪️<b> Mod warn </b><code>= "..settings.warn_mod.." </code>\n"
  local text = text.."▫️<b> Group model </b><code>= "..groupmodel.." </code>\n"
  local text = text.."▪️<b> Expire Time </b><code>= "..expire.." </code>\n"
  local text = text.."▫️<b> lang </b><code>= 🇬🇧EN🇲🇾 </code>\n"
  local text = text.."▪️<b> version </b><code>= "..version.." </code>\n\n"
  local text = text..'<a href="https://telegram.me/joinchat/DHi5Sz4zV0qEZhWsSzXXqw">🔗 PowerShield_Team</a>'
	if string.match(text, 'yes') then text = string.gsub(text, 'yes', 'Del') end
	if string.match(text, 'ok') then text = string.gsub(text, 'ok', 'No') end
	if string.match(text, 'no') then text = string.gsub(text, 'no', 'No') end
  return reply_msg(msg.id, text, ok_cb, false)
 end
end
--end settings
local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, 'SuperGroup is not added.')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' has been promoted.')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group is not added.')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' has been demoted.')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "سوپر گروه اد نشده"
	else
    return "SuperGroup is not added."
   end
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return "هیچ مدیری دراین گروه وجود ندارد"
	else
    return "No moderator in this group."
  end
 end
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  local i = 1
  local messagefa = '\nلیست مدیران گروه : ' .. string.gsub(msg.to.print_name, '_', ' ') .. '\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
  messagefa = messagefa ..i..' -> '..v..' [' ..k.. '] \n'
  i = i + 2
  end
  return messagefa
  else
  local i = 1
  local message = '\nList of moderators for ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
  message = message ..i..' -> '..v..' [' ..k.. '] \n'
  i = i + 1
  end
  return message
 end
end
-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
    if get_cmd == "id" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			id1 = send_large_msg(channel, user_id)
		end
    elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
    elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "setadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." set as an admin"
		else
			text = "[ "..user_id.." ]set as an admin"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "demoteadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." has been demoted from admin"
		else
			text = "[ "..user_id.." ] has been demoted from admin"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "setowner" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "@"..result.from.username.." [ "..result.from.peer_id.." ] added as owner"
			else
				text = "[ "..result.from.peer_id.." ] added as owner"
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "promote" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "demote" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		print(user_id)
		print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "["..user_id.."] removed from the muted user list")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] added to the muted user list")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	--[[if get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
		else
			text = "[ "..result.peer_id.." ] has been set as an admin"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "demoteadmin" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "You can't demote global admins!")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] has been demoted from admin"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "promote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "demote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "id" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "invite" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been set as an admin"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "promote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "demote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "demoteadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been demoted from admin"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] removed from muted user list")
		elseif is_owner(extra.msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] added to muted user list")
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'No user @'..member..' in this SuperGroup.'
  else
    text = 'No user ['..memberid..'] in this SuperGroup.'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
      end
      if v.username then
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
elseif get_cmd == "setadmin" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == 'setowner' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				    textfa = member_username.." ["..v.peer_id.."]اضافه شد به عنوان صاحب گروه"
					else
					text = member_username.." ["..v.peer_id.."] added as owner"
					end
				else
					text = "["..v.peer_id.."] added as owner"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] as owner by username")
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				textfa = "اضافه شدبه عنوان صاحب گروه\n ایدی کاربر:"..memberid.."یوزرنیم کاربر:\n"..v.peer_id..""
				else
				text = "added as owner\nID:["..memberid.."]"
			end
		 end
	  end
   end
end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
    send_large_msg(receiver, 'عکس ذخیره شد', ok_cb, false)
	else
	send_large_msg(receiver, 'Photo saved!', ok_cb, false)
	end
  else
    print('Error downloading: '..msg.id)
	local hash = 'group:'..msg.to.id
    local group_lang = redis:hget(hash,'lang')
    if group_lang then
	send_large_msg(receiver, 'لطفا دوباره تلاش کنید!', ok_cb, false)
	else
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
   end
  end
 end
--Run function
   local function run(msg, matches)
   local hash = 'group:'..msg.to.id
   local group_lang = redis:hget(hash,'lang')
   if msg.to.type == 'chat' then
   if matches[1] == 'tosuper' then 
   if not is_admin1(msg) then
   return
      end
  local receiver = get_receiver(msg)
  chat_upgrade(receiver, ok_cb, false)
      end
  elseif msg.to.type == 'channel'then
  if matches[1] == 'tosuper' then
  if not is_admin1(msg) then
  return
      end
  return "Already a SuperGroup"
  end
end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1]:lower() == '+' or matches[1]:lower() == "فعال" and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
	        local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			    return reply_msg(msg.id, "سوپرگروه[" ..string.gsub(msg.to.print_name, "_", " ").. "]ازقبل اضافه شدبود\nتوسط:["..msg.from.id.."]", ok_cb, false)
				else
				return reply_msg(msg.id, "SuperGroup[" ..string.gsub(msg.to.print_name, "_", " ").. "]already added\nby:["..msg.from.id.."]", ok_cb, false)
			 end
			end
			print("supergroup"..msg.to.print_name.."("..msg.to.id..") added")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end
		if matches[1] == '-' or matches[1]:lower() == "سیک" and is_admin1(msg) and not matches[2] then
			if not is_super_group(msg) then
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
				return reply_msg(msg.id,"سوپرگروه[" ..string.gsub(msg.to.print_name, "_", " ").. "]اضافه نشده بود" , ok_cb, false)
				else
				return reply_msg(msg.id,"SuperGroup[" ..string.gsub(msg.to.print_name, "_", " ").. "]not added", ok_cb, false)
			 end
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end

		if matches[1] == "admins" or matches[1] == 'ادمین ها' then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "owner" or matches[1] == 'صاحب' then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
		    local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			    return "صاحبی برای این گروه انتخاب نشده لطفا  با سودو ها صحبت کنید"
				else
				return "no owner,ask admins in support groups to set owner for your SuperGroup"
			 end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
		    local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			return " صاحب سوپرگروه\n ⚜["..group_owner.."]⚜"
			else
			return "SuperGroup owner is\n ⚜["..group_owner.."]⚜"
		 end
        end
		if matches[1] == "modlist" or matches[1] == 'لیست مدیران' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1] == "bots" or matches[1] == 'ربات ها' and is_momod(msg) then
			member_type = 'Bots'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup bots list")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "who" or matches[1] == 'افراد' and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1] == "kicked" or matches[1] == 'لیست افراد حذف شده' and is_momod(msg) then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1] == 'del' or matches[1] == 'پاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1] == 'block' or matches[1] == 'اخراج' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'block' or matches[1] == 'اخراج' and matches[2] and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local get_cmd = 'channel_block'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == "block" or matches[1] == "اخراج" and matches[2] and not string.match(matches[2], '^%d+$') then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'ids' or matches[1] == 'ایدی' then
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'id',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
				  local hash = 'group:'..msg.to.id
                  local group_lang = redis:hget(hash,'lang')
                  if group_lang then
				local textfa ="ایدی سوپر گروه:"..msg.to.id.."\nایدی کاربری:"..msg.from.id.."\nیوزرنیم کاربری:@"..msg.from.username
				return reply_msg(msg.id, textfa, ok_cb, false)
				else
				local text = "supergroup ID:"..msg.to.id.."\nYour ID:"..msg.from.id.."\nYour user:@"..msg.from.username
				return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end
		if matches[1] == 'kickme' or matches[1] == 'خروج' then
			if msg.to.type == 'channel' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1] == 'newlink' or matches[1] == 'لینک جدید' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
					send_large_msg(receiver, 'هشدار:\nاین گروه برای ربات نیست شما میتونید از دستور[ست لینک]استفاده کنید\nباتشکرتیم پارت\n@PartTeam')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, '*Error: Failed to retrieve link* \nReason: Not creator.\n\nIf you have the link, please use /setlink to set it\nThanks to the Part\n@PartTeam')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
					end
					else
					if group_lang then
					send_large_msg(receiver, "لینک جدید ساخته شد\nتوسط:"..string.gsub(msg.from.print_name, "_", " ").."")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
					else
				    send_large_msg(receiver, "Created a new link\nby:"..string.gsub(msg.from.print_name, "_", " ").."")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
		end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1] == 'setlink' or matches[1] == 'ست لینک' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			return ""..string.gsub(msg.from.print_name, "_", " ").." لطفا لینک جدید ارسال کنید"
			else
			return ""..string.gsub(msg.from.print_name, "_", " ").." Please send the new group link now"
		end
     end
		if msg.text then
			if msg.text:match("^(https://telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				return "لینک ست شد"
				else
				return "New link set"
			end
		end
    end
		if matches[1] == 'link' or matches[1] == 'لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
		    local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			    return ""..strning.gsub(msg.from.print_name, "_", " ").." شما هنوز لینکی نساختید برای ساخت لینک جدید از دستور[/newlink]ومیتونید برای تعویض لینک از دستور[/setlink]استفاده کنید\n باتشکرتیم پارت\n@PartTeam"
				else
				return ""..string.gsub(msg.from.print_name, "_", " ").." Create a link using [/newlink] first!\nOr if I am not creator use [/setlink] to set your link\nThanks to the Part\n@PartTeam"
			 end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			return '<code>لینک سوپرگروه:</code>\n<a href="'..group_link..'">'..string.gsub(msg.to.print_name, "_", " ")..'</a>'
			else
			return '<b>Supergroup link:</b>\n<a href="'..group_link..'">'..string.gsub(msg.to.print_name, "_", " ")..'</a>'
		end
      end
	   if matches[1] == 'linkpv' or matches[1] == 'لینک پیوی' then
      if not is_momod(msg) then
        return "فقط برای مدیران"
      end
      local group_link = data[tostring(msg.to.id)]['settings']['set_link']
      if not group_link then 
        return "اول با لینک جدید یک لینک جدید بسازید"
      end
     savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
	 		local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
     send_large_msg('user#id'..msg.from.id, '<code>لینک سوپرگروه:</code>\n<a href="'..group_link..'">'..string.gsub(msg.to.print_name, "_", " ")..'</a>')
	 else
	 send_large_msg('user#id'..msg.from.id, '<b>Supergroup link:</b>\n<a href="'..group_link..'">'..string.gsub(msg.to.print_name, "_", " ")..'</a>')
    end
	end
		if matches[1] == "invite" or matches[1] == 'اینوایت' and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "invite"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1] == 'res' or matches[1] == 'اطلاعات' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1] == 'kick' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1] == 'setadmin' or matches[1] == 'ادمین' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setadmin',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'setadmin' or matches[1] == 'ادمین' and matches[2] and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'setadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local get_cmd = 'setadmin'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'setadmin' or matches[1] == 'ادمین' and matches[2] and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'setadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local get_cmd = 'setadmin'
				local msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'demoteadmin' or matches[1] == 'تنزل ادمین' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demoteadmin',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'demoteadmin' or matches[1] == 'تنزل ادمین' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demoteadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'demoteadmin' or matches[1] == 'تنزل ادمین' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demoteadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1]:lower() == 'setowner' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'setowner' and matches[2] and string.match(matches[2], '^%d+$') then

				local	get_cmd = 'setowner'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1]:lower() == 'setowner' and matches[2] and not string.match(matches[2], '^%d+$') then
				local	get_cmd = 'setowner'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'promote' or matches[1] == 'ترفیع' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
		    local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			    return "فقط برای صاحب گروه امکان پذیر است"
				else
				return "Only owner/admin can promote"
				end
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'promote' or matches[1] == 'ترفیع' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'promote' or matches[1] == 'ترفیع' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "ok"
		end
		if matches[1] == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "ok"
		end

		if matches[1] == 'demote' or matches[1] == 'تنزل' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			    return "فقط برای صاحب گروه"
				else
				return "Only owner/support/admin can promote"
			 end
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'demote' or matches[1] == 'تنزل' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'demote' or matches[1] == 'تنزل' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "setname" or matches[1] == 'تنظیم نام' and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "setabout" or matches[1] == 'تنظیم موضوع' and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			return "توضیحات سوپرگروه ذخیره شد"
			else
			return "Description has been set.\n\nSelect the chat again to see the changes."
			end
		end

		if matches[1] == "setusername" or matches[1] == 'تنظیم یوزرنیم' and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "SuperGroup username Set.\n\nSelect the chat again to see the changes.")
				elseif success == 0 then
					send_large_msg(receiver, "Failed to set SuperGroup username.\nUsername may already be taken.\n\nNote: Username can use a-z, 0-9 and underscores.\nMinimum length is 5 characters.")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end

		if matches[1] == 'setrules' or matches[1] == 'تنظیم قوانین' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'setphoto' or matches[1] == 'تنظیم عکس' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			return "لطفا عکس جدیدسوپرگروه را ارسال کیند"..string.gsub(msg.from.print_name, "_", " ")..""
			else
			return ""..string.gsub(msg.from.print_name, "_", " ").."Please send the new group photo now"
			end
		end

		if matches[1] == 'clean' or matches[1] == 'پاکردن' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			    return "فقط برای صاحب گروه"
				else
				return "Only owner can clean"
				end
			end
			if matches[2] == 'modlist' or matches[2] == 'لیست مدیران' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
			    local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				    return "هیچ مدیری درگروه وجود ندارد"
					else
					return 'No moderator(s) in this SuperGroup.'
				 end
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				return "همه مدیران پاک شدن"
				else
				return 'Modlist has been cleaned'
				end
			end
			if matches[2] == 'rules' or matches[2] == 'قوانین' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				    return "قوانینی درگروه ثبت نشده"
					else
					return "Rules have not been set"
					end
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				return "قوانین این گروه پاک شد"
				else
				return "Rules have been cleaned"
				end
			end
			if matches[2] == 'about' or matches[2] == 'موضوع' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				    return "توضیحاتی در این گروه وجود ندارد"
					else
					return 'About is not set'
					end
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				return "توضیحات این گروه حذف شدند"
				else
				return "About has been cleaned"
				end
			end
			if matches[2] == 'mutelist' or matches[2] == 'لیست افراد سکوت' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				local hash = 'group:'..msg.to.id
                local group_lang = redis:hget(hash,'lang')
                if group_lang then
				return "همه لیست افراد سایلنت  حذف شدند"
				else
				return "Mutelist Cleaned"
				end
			end
			if matches[2] == 'username' or matches[2] == 'یوزرنیم' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "SuperGroup username cleaned.")
					elseif success == 0 then
						send_large_msg(receiver, "Failed to clean SuperGroup username.")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
			if matches[2] == "bots" or matches[2] == 'ربات ها' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked all SuperGroup bots")
				channel_get_bots(receiver, callback_clean_bots, {msg = msg})
			end
		end
		if matches[1] == 'lock' or matches[1] == 'قفل' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'links' or matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
			if matches[2] == 'spam' or matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'fwd' or matches[2] == 'فوروارد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fwd ")
				return lock_group_fwd(msg, data, target)
			end
			if matches[2] == 'flood' or matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
				if matches[2] == 'bots' or matches[2] == 'ربات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked bots ")
				return lock_group_bots(msg, data, target)
			end
			if matches[2] == 'arabic' or matches[2] == 'عربی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_arabic(msg, data, target)
			end
			if matches[2] == 'member' or matches[2] == 'اعضا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return lock_group_membermod(msg, data, target)
			end
				if matches[2] == 'fosh' or matches[2] == 'فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fosh ")
				return lock_group_fosh(msg, data, target)
			end
			if matches[2]:lower() == 'rtl' or matches[2] == 'ار تی ال' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked rtl chars. in names")
				return lock_group_rtl(msg, data, target)
			end
			if matches[2] == 'tgservice' or matches[2] == 'سرویس تلگرام' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'sticker' or matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2] == 'contacts' or matches[2] == 'شماره' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'strict' or matches[2] == 'سخت گیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == 'unlock' or matches[1] == 'بازکردن' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'links' or matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'fosh' or matches[2] == 'فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fosh")
				return unlock_group_fosh(msg, data, target)
			end
			if matches[2] == 'spam' or matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'flood' or matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'bots' or matches[2] == 'ربات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked bots")
				return unlock_group_bots(msg, data, target)
			end
			if matches[2] == 'fwd' or matches[2] == 'فوروارد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fwd")
				return unlock_group_fwd(msg, data, target)
			end
			if matches[2] == 'arabic' or matches[2] == 'عربی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_arabic(msg, data, target)
			end
			if matches[2] == 'member' or matches[2] == 'اعضا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end
			if matches[2]:lower() == 'rtl' or matches[2] == 'ار تی ال' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end
				if matches[2] == 'tgservice' or matches[2] == 'سرویس تلگرام' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'sticker' or matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == 'contacts' or matches[2] == 'شماره' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'strict' or matches[2] == 'سخت گیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == 'setflood' or matches[1] == 'حساسیت' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 1 or tonumber(matches[2]) > 200 then
			local hash = 'group:'..msg.to.id
            local group_lang = redis:hget(hash,'lang')
            if group_lang then
			    return "شما میتوانید حساسیت را از[1-200]تنظیم کنید"
				else
				return "Wrong number,range is [1-200]"
				end
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return 'Flood has been set to: '..matches[2]
		end
		if matches[1] == 'public' or matches[1] == 'حالت عمومی' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'yes' or matches[2] == 'بله' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == 'no' or matches[2] == 'خیر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1] == 'mute' or matches[1] == 'سکوت' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio' or matches[2] == 'صدا' then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." has been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'photo' or matches[2] == 'عکس' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." has been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'video' or matches[2] == 'ویدیو' then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." has been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'gifs' or matches[2] == 'گیف' then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." have been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'documents' or matches[2] == '' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." have been muted"
				else
					return "SuperGroup mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'text' or matches[2] == 'متن' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." has been muted"
				else
					return "Mute "..msg_type.." is already on"
				end
			end
			if matches[2] == 'all' or matches[2] == 'همه' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "Mute "..msg_type.."  has been enabled"
				else
					return "Mute "..msg_type.." is already on"
				end
			end
		end
		if matches[1] == 'unmute' or matches[1] == 'بازکردن سکوت' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio' or matches[2] == 'صدا' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'photo' or matches[2] == 'عکس' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'video' or matches[2] == 'ویدیو' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'gifs' or matches[2] == 'گیف' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." have been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'documents' or matches[2] == 'اسناد' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." have been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'text' or matches[2] == 'متن' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute text is already off"
				end
			end
			if matches[2] == 'all' or matches[2] == 'همه' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "Mute "..msg_type.." has been disabled"
				else
					return "Mute "..msg_type.." is already disabled"
				end
			end
		end


		if matches[1] == "muteuser" or matches[1] == 'سکوت' and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1] == "muteuser" or matches[1] == 'سکوت' and matches[2] and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return "["..user_id.."] removed from the muted users list"
				elseif is_owner(msg) then
					mute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return "["..user_id.."] added to the muted user list"
				end
			elseif matches[1] == "muteuser" or matches[1] == 'سکوت' and matches[2] and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

		if matches[1] == "muteslist" or matches[1] == 'تنظیمات سکوت' and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
			return mutes_list(chat_id)
		end
		if matches[1] == "mutelist" or matches[1] == 'لیست افراد سکوت' and is_momod(msg) then
			local chat_id = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
			return muted_user_list(chat_id)
		end

		if matches[1] == 'settings' or matches[1] == 'تنظیمات' and is_momod(msg) then
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'rules' or matches[1] == 'قوانین' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end
		    if matches[1] == 'setversion' or matches[1] == 'تنظیم ورژن' then
	  if not is_sudo(msg) then
       return "فقط برای سودو❗️"
      end
	    if matches[2] == '0.6' then
        if version ~= '0.6' then
          data[tostring(msg.to.id)]['settings']['version'] = '0.6'
          save_data(_config.moderation.data, data)
        end
        return 'group version has been changed to 0.6'
      end
      if matches[2] == '1.0' then
        if version ~= '1.0' then
          data[tostring(msg.to.id)]['settings']['version'] = '1.0'
          save_data(_config.moderation.data, data)
        end
        return 'group version has been changed to 1.0'
      end
	    if matches[2] == '1.5' then
        if version ~= '1.5' then
          data[tostring(msg.to.id)]['settings']['version'] = '1.5'
          save_data(_config.moderation.data, data)
        end
        return 'group version has been changed to 1.5'
      end
      if matches[2] == '2.0' then
        if version ~= '2.0' then
          data[tostring(msg.to.id)]['settings']['version'] = '2.0'
          save_data(_config.moderation.data, data)
        end
        return 'group version has been changed to 2.0'
      end
	    if matches[2] == '2.5' then
        if version ~= '2.5' then
          data[tostring(msg.to.id)]['settings']['version'] = '2.5'
          save_data(_config.moderation.data, data)
        end
        return 'group version has been changed to 2.5'
      end
      if matches[2] == '3.0' then
        if version ~= '3.0' then
          data[tostring(msg.to.id)]['settings']['version'] = '3.0'
          save_data(_config.moderation.data, data)
		  end
          return 'group version has been changed to 3.0'
        end
		 if matches[2] == '3.7' then
        if version ~= '3.7' then
          data[tostring(msg.to.id)]['settings']['version'] = '3.7'
          save_data(_config.moderation.data, data)
        end
        return 'group version has been changed to 3.7'
      end
	        if matches[2] == '4.1' then
        if version ~= '4.1' then
          data[tostring(msg.to.id)]['settings']['version'] = '4.1'
          save_data(_config.moderation.data, data)
        end
        return 'group version has been changed to 4.1'
      end
	        if matches[2] == '5.3' then
        if version ~= '5.3' then
          data[tostring(msg.to.id)]['settings']['version'] = '5.3'
          save_data(_config.moderation.data, data)
        end
        return 'group version has been changed to 5.3'
        end
      end
    if matches[1] == 'setgpmodel' or matches[1] == 'تنظیم مدل گروه' then
	  if not is_sudo(msg) then
       return "فقط برای سودو❗️"
      end
      if matches[2] == 'realm' or matches[2] == 'ریلیم' then
        if groupmodel ~= 'realm' then
          data[tostring(msg.to.id)]['settings']['groupmodel'] = 'realm'
          save_data(_config.moderation.data, data)
        end
        return 'Group model has been changed to realm'
      end
      if matches[2] == 'support' or matches[2] == 'ساپورت' then
        if groupmodel ~= 'support' then
          data[tostring(msg.to.id)]['settings']['groupmodel'] = 'support'
          save_data(_config.moderation.data, data)
        end
        return 'Group model has been changed to support'
      end
      if matches[2] == 'feedback' or matches[2] == 'پشتیبانی' then
        if groupmodel ~= 'feedback' then
          data[tostring(msg.to.id)]['settings']['groupmodel'] = 'feedback'
          save_data(_config.moderation.data, data)
        end
        return 'Group model has been changed to feedback'
      end
      if matches[2] == 'vip' or matches[2] == 'اختصاصی' then
        if groupmodel ~= 'vip' then
          data[tostring(msg.to.id)]['settings']['groupmodel'] = 'vip'
          save_data(_config.moderation.data, data)
        end
        return 'Group model has been changed to vip'
      end
	    if matches[2] == 'free' or matches[2] == 'رایگان' then
        if groupmodel ~= 'free' then
          data[tostring(msg.to.id)]['settings']['groupmodel'] = 'free'
          save_data(_config.moderation.data, data)
        end
        return 'Group model has been changed to free'
      end
	     if matches[2] == 'name' or matches[2] == 'نام' then
        if groupmodel ~= ""..string.gsub(msg.to.print_name, "_", " ").."" then
          data[tostring(msg.to.id)]['settings']['groupmodel'] = ""..string.gsub(msg.to.print_name, "_", " ")..""
          save_data(_config.moderation.data, data)
        end
        return 'Group model has been changed to name'
      end
      if matches[2] == 'normal' or matches[2] == 'متوسط' then
        if groupmodel ~= 'normal' then
          data[tostring(msg.to.id)]['settings']['groupmodel'] = 'normal'
          save_data(_config.moderation.data, data)
		  end
          return 'Group model has been changed to normal'
      end
    end
      if matches[1] == 'help' and not is_momod(msg) then
			text = "لیست دستورات برای اعضای معمولی:\n\n➖➖➖➖➖➖\n#topstats\nنشان دادن ۳ نفر از فعال ترین اعضای گروه!\n➖➖➖➖➖➖\n#filterlist\nنشان دادن کلمه های فیلتر شده.\n➖➖➖➖➖➖\n#id\nنمایش اطلاعات اکانت شما .\n➖➖➖➖➖➖\n#sticker [reply]\nبا ریپلای کردن عکس میتوانید آن را به استیکر تبدیل کنید!\n#sticker [text]\nتبدیل متن شما به استیکر ...\n#sticker [text] [color]\nتبدیل متن شما به استیکر با تنظیم رنگ ...\n#sticker [text] [color] [font]\n\nتبدیل متن شما به استیکر با تنظیم رنگ و فونت...\n( Supported fonts : [fun|italic|bold|arial] )\n( Supported colors : [black|red|blue|yellow|pink|orange|brown] )\nتبدیل متن شما به استیکر ...\n➖➖➖➖➖➖\n#photo [reply]\nبا ریپلای کردن استیکر میتوانید آن را به عکس تبدیل کنید!\n➖➖➖➖➖➖\n#vc [kalame](زبان ها : Farsi,En)\nتبدیل کلمه به صدا\n➖➖➖➖➖➖\n#weather [اسم شهر]\nدریافت اطلاعات آب و هوای یک منطقه\n➖➖➖➖➖➖\n#aparat [کلمه] \nجستوجو در آپارات!\n➖➖➖➖➖➖\n#me\nنمایش تعداد پیام های ارسال شده از شما\n➖➖➖➖➖➖\n#qr [کلمه]\nتبدیل کلمه،لینک،... شما به بارکد\n➖➖➖➖➖➖\n#insta [id, Post Link]\nدریافت اطلاعات ایدی و ... از اینستاگرام!\n➖➖➖➖➖➖\n#calc [2*2]\nمحاسبه جمع تفریق ضرب و...\n➖➖➖➖➖➖\n#porn [text]\nجستجو در 7 سایت +18\n➖➖➖➖➖➖\n#time\nدریافت زمان دقیق!\n➖➖➖➖➖➖\n#support \nدریافت لینک گروه پشتیبانی!\n➖➖➖➖➖➖\n#version\nنمایش ورژن و ادمین های ربات!\n➖➖➖➖➖➖\n#plist\nدریافت لیست قیمت برای خرید گروه...\n➖➖➖➖➖➖\n#write [text]\nطراحی کلمه مورد تظر با 17 فونت!\n➖➖➖➖➖➖\n#feedback [text]\nشما میتوانید با این دستور نظرات و پیشنهادات خود را برای ما ارسال کنید...\n➖➖➖➖➖➖\n| Channel : @Black_CH |\n"
			reply_msg(msg.id, text, ok_cb, false)
		elseif matches[1] == 'help' and is_momod(msg) then
			text = "راهنمای بات ضد اسپم بلک\nدرصورت ابهام میتونید با دستور /support لینک گروه پشتیبانی را دریافت کنید و  مشکلتون رو مطرح کنید! \n\n➖➖➖➖➖➖\n#ban @username\nاخراج کردن یک فرد از گروه به صورت دائمی\n#unban @username\nخارج کردن یک فرد از حالت اخراج دائمی!\n#banlist\nلیست افراد بن شده.\n➖➖➖➖➖➖\n#info\nنمایش اطلاعات اصلی گروه\n➖➖➖➖➖➖\n#del [reply|number]\nپاک کردن تعداد پیام های مورد نظر با ریپلی و تعداد!\n➖➖➖➖➖➖\n#topstats\nنشان دادن ۳ نفر از فعال ترین اعضای گروه!\n➖➖➖➖➖➖\n#admins\nنمایش لیست ادمین های گروه\n➖➖➖➖➖➖\n#filter [word]\nفیلتر کردن یک کلمه\n#remword [word]\nحذف کردن کلمه از لیست فیلتر کلمات\n#filterlist\nنشان دادن کلمه های فیلتر شده.\n➖➖➖➖➖➖\n#owner\nنمایش آیدی خریدار گروه.\n➖➖➖➖➖➖\n#modlist\nنمایش لیست ناظم ها.\n➖➖➖➖➖➖\n#bots\nلیست روبات های گروه.\n➖➖➖➖➖➖\n#who\nلیست اعضای گروه در یک فایل متنی.\n(.txt)\n➖➖➖➖➖➖\n#kick [reply|id]\nبلاک کردن و کیک کردن فرد از گروه.\n➖➖➖➖➖➖\n#setwlc [your text]\nتنظیم یک متن به عنوان متن خوشامد گویی\n➖➖➖➖➖➖\n#setwlc rules [your text]\nتنظیم کردن یک متن به عنوان پلام خوشامد گویی + قوانین گروه.\n➖➖➖➖➖➖\n#delwlc\nحذف پیام خوشامد گویی.\n➖➖➖➖➖➖\n#id\nنمایش اطلاعات اکانت شما .\n➖➖➖➖➖➖\n#sticker [reply]\nبا ریپلای کردن عکس میتوانید آن را به استیکر تبدیل کنید!\n#sticker [text]\nتبدیل متن شما به استیکر ...\n#sticker [text] [color]\nتبدیل متن شما به استیکر با تنظیم رنگ ...\n#sticker [text] [color] [font]\n\nتبدیل متن شما به استیکر با تنظیم رنگ و فونت...\n( Supported fonts : [fun|italic|bold|arial] )\n( Supported colors : [black|red|blue|yellow|pink|orange|brown] )\nتبدیل متن شما به استیکر ...\n➖➖➖➖➖➖\n#photo [reply]\nبا ریپلای کردن استیکر میتوانید آن را به عکس تبدیل کنید!\n➖➖➖➖➖➖\n#vc [kalame](زبان ها : Farsi,En)\nتبدیل کلمه به صدا\n➖➖➖➖➖➖\n#weather [اسم شهر]\nدریافت اطلاعات آب و هوای یک منطقه\n➖➖➖➖➖➖\n#aparat [کلمه] \nجستوجو در آپارات!\n➖➖➖➖➖➖\n#me\nنمایش تعداد پیام های ارسال شده از شما\n➖➖➖➖➖➖\n#qr [کلمه]\nتبدیل کلمه،لینک،... شما به بارکد\n➖➖➖➖➖➖\n#insta [id, Post Link]\nدریافت اطلاعات ایدی و ... از اینستاگرام!\n➖➖➖➖➖➖\n#write [text]\nطراحی کلمه مورد تظر با 17 فونت!\n➖➖➖➖➖➖\n#calc [2*2]\nمحاسبه جمع تفریق ضرب و...\n➖➖➖➖➖➖\n#porn [text]\nجستجو در 7 سایت +\n➖➖➖➖➖➖\n#time\nدریافت زمان دقیق!\n➖➖➖➖➖➖\n#support \nدریافت لینک گروه پشتیبانی!\n➖➖➖➖➖➖\n#setowner [reply, username]\nست کردن کاربر به عنوان خریدار گروه\n#promote [username|id]\nارتقاء مقام کاربر به ناظم گروه\n#demote [username|id]\nخلع مقام کردن کاربر از سمت ناظم ها\n➖➖➖➖➖➖\n#setname [text]\nتغییر اسم گروه\n#setphoto\nجایگزین کردن عکس گروه\n#setrules [text]\nگذاشتن قوانین برای گروه\n#setabout [text]\nگذاشتن متن توضیحات برای سوپر گروه(این متن در بخش توضیحات گروه هم نمایش داده میشه)\n➖➖➖➖➖➖\n#newlink\nساختن لینک جدید\n#link\nگرفتن لینک\n#linkpv\nارسال لینک گروه در پیوی شما!\n➖➖➖➖➖➖\n#rules\nنمایش قوانین\n➖➖➖➖➖➖\n#lock [links|flood|spam|Arabic|member|rtl|sticker|TgService|contacts|forward|badword|emoji|english|tag|webpage|strict]\nقفل کردن لینک گروها-اسپم-متن و اسم های بزرگ -زبان فارسی-تعداد اعضا-کاراکتر های غیر عادی-استیکر-مخاطبین-فروارد-فوش-اموجی-انگلیسی-تگ-لینک سایت\n\nدقت کنید اگر گذینه اخری strict روشن باشد کاربر از گروه کیک میشود و پیغام پاک میشه در غیر این صورت فقط پیغام پاک میشود\n➖➖➖➖➖➖\n#unlock [links|flood|spam|Arabic|member|rtl|sticker|contacts|TgService|strict|forward|badword|emoji|english]\nباز کردن قفل امکانات بالا\n➖➖➖➖➖➖\n#mute [all|audio|gifs|photo|video|text]\nپاک کردن سریع همه پیغام ها-عکس ها-گیف ها-صدا های ضبط شده-فیلم-متن\n➖➖➖➖➖➖\n#unmute [all|audio|gifs|photo|video|text]\nباز کردن قفل امکانات بالا\n➖➖➖➖➖➖\n#setflood [value]\nگذاشتن value به عنوان حساسیت اسپم\n➖➖➖➖➖➖\n#settings\nنمایش تنظیمات گروه\n➖➖➖➖➖➖\n#muteslist\nنمایش نوع پیغام های سایلنت شده\n*A \"muted\" message type is auto-deleted if posted\n➖➖➖➖➖➖\n#muteuser [username]\nسایلنت کردن یک کاربر خاص در گروه\nفقط خریدار (owner) میتونه کسیو سایلنت کنه ولی ناظم ها (Mods) میتونند فرد را از سایلنتی در بیاورند\n➖➖➖➖➖➖\n#mutelist\nنمایش لیست افراد سایلنت شده\n➖➖➖➖➖➖\n#clean [rules|about|modlist|mutelist|bots]\nپاک کردن لیست ناظم ها-درباره-لیست سایلنت شده ها-قوانین-بات ها\n➖➖➖➖➖➖\n#log\nبرگرداندن تاریخچه گروه در یک فایل متنی\n➖➖➖➖➖➖\n#version\nنمایش ورژن و ادمین های ربات!\n➖➖➖➖➖➖\n#plist\nدریافت لیست قیمت برای خرید گروه...\n➖➖➖➖➖➖\n#feedback [text]\nشما میتوانید با این دستور نظرات و پیشنهادات خود را برای ما ارسال کنید...\n➖➖➖➖➖➖\n| Channel : @Black_CH |\n"
			reply_msg(msg.id, text, ok_cb, false)
		end
   
		if matches[1] == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1] == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1] == 'msg.to.peer_id' then
			post_large_msg(receiver, msg.to.peer_id)
		end
	end
end
local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
  	"^(فعال)$",
	"^(سیک)$",
	"^(ادمین ها)$",
    "^(صاحب)$",
	"^(لیست افراد حذف شده)$",
    "^(پاک)$",
	"^(کیک) (.*)$",
	"^(ایدی) (.*)$",
	"^(ایدی)$",
	"^(خروج)$",
	"^(لینک جدید)$",
	"^(ست لینک)$",
	"^(لینک)$",
    "^(لینک پیوی)$",
	"^(اینوایت) (.*)$",
  	"^(اطلاعات) (.*)$",
	"^(ادمین) (.*)$",
	"^(ادمین)",
	"^(تنزل ادمین) (.*)$",
	"^(تنزل ادمین)",
	"^(صاحب گروه) (.*)$",
	"^(صاحب گروه)",
	"^(ترفیع) (.*)$",
	"^(ترفیع)",
	"^(تنزل) (.*)$",
	"^(تنزل)",
	"^(تنظیم نام) (.*)$",
	"^(تنظیم موضوع) (.*)$",
	"^(تنظیم قوانین) (.*)$",
	"^(تنظیم عکس)$",
	"^(پاکردن) (.*)$",
	"^(قفل) (.*)$",
	"^(بازکردن) (.*)$",
	"^(حساسیت) (.*)$",
	"^(حالت عمومی) (.*)$",
	"^(سکوت) ([^%s]+)$",
	"^(بازکردن سکوت) ([^%s]+)$",
	"^(سکوت)$",
	"^(سکوت) (.*)$",
	"^(تنظیمات سکوت)$",
	"^(لیست افراد سکوت)$",
	"^(تنظیمات)$",
	"^(قوانین)$",
    "^(تنظیم ورژن) (.*)$",
	"^(تنظیم مدل گروه) (.*)$",
	"^(راهنما)$",
	---------------------
    "^[#!/](setversion) (.*)$",
  	"^[#!/](setgpmodel) (.*)$",
	"^[#!/]([Mm]ove) (.*)$",
	"^[#!/]([Aa]dmins)$",
	"^[#!/]([Oo]wner)$",
	"^[#!/]([Mm]odlist)$",
	"^[#!/]([Bb]ots)$",
	"^[#!/]([Ww]ho)$",
	"^[#!/]([Kk]icked)$",
    "^[#!/]([Kk]ick) (.*)",
	"^[#!/]([Bb]lock)",
	"^[#!/]([Tt]osuper)$",
	"^[#!/]([Ii][Dd]s)$",
	"^[#!/]([Ii][Dd]s) (.*)$",
	"^[#!/]([Kk]ickme)$",
	"^[#!/]([Kk]ick) (.*)$",
	"^[#!/]([Nn]ewlink)$",
	"^[#!/]([Ss]etlink)$",
	"^[#!/]([Ll]ink)$",
	"^[#!/]([Rr]es) (.*)$",
	"^[#!/]([Ss]etadmin) (.*)$",
	"^[#!/]([Ss]etadmin)",
	"^[#!/]([Dd]emoteadmin) (.*)$",
	"^[#!/]([Dd]emoteadmin)",
	"^[#!/]([Ss]etowner) (.*)$",
	"^[#!/]([Ss]etowner)$",
	"^[#!/]([Pp]romote) (.*)$",
	"^[#!/]([Pp]romote)",
	"^[#!/]([Dd]emote) (.*)$",
	"^[#!/]([Dd]emote)",
	"^[#!/]([Ss]etname) (.*)$",
	"^[#!/]([Ss]etabout) (.*)$",
	"^[#!/]([Ss]etrules) (.*)$",
	"^[#!/]([Ss]etphoto)$",
	"^[#!/]([Ss]etusername) (.*)$",
	"^[#!/]([Dd]el)$",
	"^[#!/]([Ll]ock) (.*)$",
	"^[#!/]([Uu]nlock) (.*)$",
	"^[#!/]([Mm]ute) ([^%s]+)$",
	"^[#!/]([Uu]nmute) ([^%s]+)$",
	"^[#!/]([Mm]uteuser)$",
	"^[#!/]([Mm]uteuser) (.*)$",
	"^[#!/]([Pp]ublic) (.*)$",
	"^[#!/]([Ss]ettings)$",
	"^[#!/]([Rr]ules)$",
	"^[#!/]([Ss]etflood) (%d+)$",
	"^[#!/]([Cc]lean) (.*)$",
	"^[#!/]([Hh]elp)$",
	"^[#!/]([Mm]uteslist)$",
	"^[#!/]([Mm]utelist)$",
	"^[!/#](linkpv)$",
    "[#!/](mp) (.*)",
	"[#!/](md) (.*)",
	"^(+)$",
	"^(-)$",
	"^([Mm]ove) (.*)$",
	"^([Aa]dmins)$",
	"^([Oo]wner)$",
	"^([Mm]odlist)$",
	"^([Kk]ick)$",
	"^([Ww]ho)$",
	"^([Kk]icked)$",
    "^([Bb]lock) (.*)",
	"^([Bb]lock)",
	"^([Tt]osuper)$",
	"^([Ii][Dd]s)$",
	"^([Ii][Dd]s) (.*)$",
	"^([Kk]ickme)$",
	"^([Kk]ick) (k)$",
	--"^([Ll]ink)$",
	"^([Rr]es) (.*)$",
	"^([Ss]etadmin) (.*)$",
	"^([Ss]etadmin)",
	"^([Dd]emoteadmin) (.*)$",
	"^([Dd]emoteadmin)",
	"^([Ss]etowner) (.*)$",
	"^([Ss]etowner)$",
	"^([Pp]romote) (.*)$",
	"^([Pp]romote)",
	"^([Dd]emote) (.*)$",
	"^([Dd]emote)",
	"^([Ss]etname) (.*)$",
	"^([Ss]etabout) (.*)$",
	"^([Ss]etrules) (.*)$",
	"^([Ss]etphoto)$",
	"^([Ss]etusername) (.*)$",
	"^([Dd]el)$",
	"^(linkpv)$",
	"^([Ll]ock) (.*)$",
	"^([Uu]nlock) (.*)$",
	"^([Mm]ute) ([^%s]+)$",
	"^([Uu]nmute) ([^%s]+)$",
	"^([Mm]uteuser)$",
	"^([Mm]uteuser) (.*)$",
	"^([Pp]ublic) (.*)$",
	"^([Ss]ettings)$",
	"^([Rr]ules)$",
	"^([Ss]etflood) (%d+)$",
	"^([Cc]lean) (.*)$",
	"^([Hh]elp)$",
	"^([Mm]uteslist)$",
	"^([Mm]utelist)$",
    "^(https://telegram.me/joinchat/%S+)$",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
--by @soheilDkta
