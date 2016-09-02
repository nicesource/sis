do

function run(msg, matches)
    if matches[1]:lower() == 'share' then
send_contact(get_receiver(msg), "+13027215751", "Power Shield", "BOT", ok_cb, false)
if matches[1]:lower() == 'sharesudo' then
send_contact(get_receiver(msg), "+989356200424", "aryan", "@PowerShield_CH", ok_cb, false)
end
end
end
return {
patterns = {
"^([Ss]hare)$",
"^([Ss]haresudo)$"

},
run = run
}

end
