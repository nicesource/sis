local function run(msg)
   if msg.to.type == 'channel' and not is_momod(msg) then
	delete_msg(msg.id,ok_cb,false)
	else
	kick_user(msg.from.id, msg.to.id)
        return 'Do not swear'
    end
end

return {
    patterns = {
    "[Kk][Oo][Ss]",
	"[Nn][Nn][Tt]",
	"[Nn][Aa][Nn][Aa][Tt]",
    "کص",
    "کیر",
	"کون",
	"koon",
	"ننت",
	"ناموس",
	"شل",
    "کس ننه"
    }, 
run = run
}
