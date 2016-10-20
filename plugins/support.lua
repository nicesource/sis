do
    local function run(msg, matches)
    local support = '1051670668' 
    local data = load_data(_config.moderation.data)
    local name_log = user_print_name(msg.from)
        if matches[1] == 'support' or matches[1] == 'ساپورت' then
        local group_link = data[tostring(support)]['settings']['set_link']
    return "<i>نرخ ربات ضدلینک و ضداسپم پاورشیلد به شرح زیر است •</i>\n\n<code>• یک ماهه : 3 هزار تومان</code>\n<code>•دوماهه : 6 هزار تومان</code>\n<code>•همیشگی : 10 هزار تومان</code>\n<i>++برای خرید مبلغ مورد نظر خود را به شماره کارت زیر بفرستید، سپس از فیش عکس گرفته وبه ساپورت ارسال کنید، بعد ادمین ها ربات رو در گروه شما اضافه میکنند</i>\n\n<code>شماره کارت:</code>\n6037701303422858\nبنام آرین قاسمی\n\n<code>لینک ساپورت: </code>\n"..group_link.."\n•توجه: شارژ قبول نمیشود"
    end
end
return {
    patterns = {
    "^[!/#](support)$",
    "^([sS]upport)$",
    "^(ساپورت)$",
     },
    run = run
}
end
