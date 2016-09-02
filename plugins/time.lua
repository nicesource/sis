function run(msg, matches)
local url , res = http.request('http://api.gpmod.ir/time/')
if res ~= 200 then return "No connection" end
local jdat = json:decode(url)
local text = '⌚️ساعت<><><><>'..os.date(' %X', os.time())..' \nامروز '..jdat.FAdate..'است \n    —--\n⌚️Time :'..os.date(' %X', os.time())..'\n📆Today : '..jdat.ENdate.. '\n@PowerShield_CH'
local url = "http://latex.codecogs.com/png.download?".."\\dpi{800}%20\\LARGE%20"..jdat.ENtime
local file = download_to_file(url,'time.webp')
send_document(get_receiver(msg) , file, ok_cb, false)
return text
end
return {
  patterns = {"^[/!]([Tt][iI][Mm][Ee])$"},
run = run
}
