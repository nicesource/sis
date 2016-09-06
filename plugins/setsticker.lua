local function tosticker(msg, success, result)
  local receiver = get_receiver(msg)
  if success then
    local file = './files/mysticker/'..msg.from.id..'.webp'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    --send_document(get_receiver(msg), file, ok_cb, false)
    redis:del("photo:setsticker")
	send_large_msg(receiver, 'عکس تبدیل به استیکر و ثبت شد', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'دوباره امتحان کنید', ok_cb, false)
  end
end
local function tosticker2(msg, success, result)
  local receiver = get_receiver(msg)
  if success then
    local file = './files/mysticker/'..msg.from.id..'.webp'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    --send_document(get_receiver(msg), file, ok_cb, false)
    redis:del("photo:setsticker")
	send_large_msg(receiver, 'استیکر شما ثبت شد', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'دوباره امتحان کنید', ok_cb, false)
  end
end

local function run(msg,matches)
    local receiver = get_receiver(msg)
    local group = msg.to.id
	if not msg.reply_id then
    if msg.media then
       if msg.media.type == 'photo' and redis:get("photo:setsticker") then
        if redis:get("photo:setsticker") == 'waiting' then
          load_photo(msg.id, tosticker, msg)
        end
       end
    end
    if matches[1]:lower() == "setsticker" then
     redis:set("photo:setsticker", "waiting")
     send_large_msg(receiver, 'لطفا برای ثبت استیکر مخصوص خود یک عکس را ارسال کنید یا \n میتوانید استیکری را فرستاده و آنرا ریپلای کنید و دستور setsticker را بفرستید', ok_cb, false)
    end
	end
if msg.reply_id then
	 if msg.to.type == 'photo' and redis:get("photo:sticker") then
        if redis:set("photo:sticker", "waiting") then
        end
       end
    if matches[1]:lower() == "setsticker" then
     redis:get("photo:sticker")
     load_photo(msg.reply_id, tosticker2, msg)
    end
	end
	local files = './files/mysticker/'..msg.from.id..'.webp'
	
	if matches[1]:lower() == 'info' and not msg.reply_id then
	if not files then
	send_large_msg(receiver, 'دوباره امتحان کنید', ok_cb, false)
	else
	send_document(get_receiver(msg), './files/mysticker/'..msg.from.id..'.webp', ok_cb, false)
end
end
end
return {
  patterns = {
 "^([Ss]etsticker)$",
 "^[!/]([Ss]etsticker)$",
"^([Ii]nfo)$",
"^[!/]([Ii]nfo)$",
 "%[(photo)%]",
  },
  run = run,
}
