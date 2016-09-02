function run(msg, matches)
  local bgcolor = 'mathrm'
        if matches[5] == 'blue' then
            bgcolor = '0000ff'
        elseif matches[5] == 'pink' then
            bgcolor = 'e11bca'
             elseif matches[5] == 'violet' then
            bgcolor = '7366BD'
             elseif matches[5] == 'red' then
            bgcolor = 'ff0000'
             elseif matches[5] == 'brown' then
            bgcolor = 'B4674D'
             elseif matches[5] == 'orange' then
            bgcolor = 'FF7F49'
             elseif matches[5] == 'gray' then
            bgcolor = 'B0B7C6'
        elseif matches[5] == 'cream' then
            bgcolor = 'FFFF99'
        elseif matches[5] == 'green' then
            bgcolor = '00ff00'
             elseif matches[5] == 'black' then
            bgcolor = '000000'
            elseif matches[5] == 'white' then
            bgcolor = 'ffffff'
            elseif matches[5] == 'Fuchsia' then
            bgcolor = 'ff00ff'
            elseif matches[5] == 'Aqua' then
            bgcolor = '00ffff'
            elseif matches[5] == 'yellow' then
            bgcolor = 'ffff00'
     --   else
       --     local answer = {'0000ff','e11bca','7366BD','ff0000','B4674D','FF7F49','B0B7C6','FFFF99','00ff00','000000','ffffff','ff00ff','00ffff','ffff00'}
       --      bgcolor = answer[math.random(#answer)]

                end

        local textcolor = 'blue'
        if matches[6] == 'blue' then
            textcolor = '0000ff'
        elseif matches[6] == 'pink' then
            textcolor = 'e11bca'
             elseif matches[6] == 'violet' then
            textcolor = '7366BD'
             elseif matches[6] == 'red' then
            textcolor = 'ff0000'
             elseif matches[6] == 'brown' then
            textcolor = 'B4674D'
             elseif matches[6] == 'orange' then
            textcolor = 'FF7F49'
             elseif matches[6] == 'gray' then
            textcolor = 'B0B7C6'
        elseif matches[6] == 'cream' then
            textcolor = 'FFFF99'
        elseif matches[6] == 'green' then
            textcolor = '00ff00'
             elseif matches[6] == 'black' then
            textcolor = '000000'
            elseif matches[6] == 'white' then
            textcolor = 'ffffff'
            elseif matches[6] == 'Fuchsia' then
            textcolor = 'ff00ff'
            elseif matches[6] == 'Aqua' then
            textcolor = '00ffff'
            elseif matches[6] == 'yellow' then
            textcolor = 'ffff00'
        else
            local answers = {'0000ff','e11bca','7366BD','ff0000','B4674D','FF7F49','B0B7C6','FFFF99','00ff00','000000','ffffff','ff00ff','00ffff','ffff00'}
             textcolor = answers[math.random(#answers)]
             cap = textcolor
        end
    local text1 = matches[2]
        local text2 = matches[3]
    local text3 = matches[4]
    local url = "http://www.keepcalmstudio.com/-/p.php?t=%EE%BB%AA%0D%0AKEEP%0D%0ACALM%0D%0A"..text1.."%0D%0A"..text2.."%0D%0A"..text3.."&bc="..bgcolor.."&tc="..textcolor.."&cc="..cap.."&uc=true&ts=true&ff=PNG&w=500&ps=sq"
     local  file = download_to_file(url,'keep.webp')
      send_document(get_receiver(msg), file, ok_cb, false)


end


return {
  description = "تبدیل متن به لوگو",
  usage = {
    "/keep calm font text: ساخت لوگو",
  },
  patterns = {
   "^[/!]([Kk][Ee][Ee][Pp] [Cc][Aa][Ll][Mm]) (.+) (.+) (.+) (.+) (.+)$",
   "^[/!]([Kk][Ee][Ee][Pp] [Cc][Aa][Ll][Mm]) (.+) (.+) (.+) (.+)$",
   "^[/!]([Kk][Ee][Ee][Pp] [Cc][Aa][Ll][Mm]) (.+) (.+) (.+)$",
  },
  run = run
}
