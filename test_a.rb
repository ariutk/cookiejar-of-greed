require 'greed/cookie'

set_cookies = [
  "bcookie=93f7d3bf753946bda1cb53a534439d20c76e246b0e654dfa89bedd3ad540597c; path=/",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "token=7b035cb6-6788-4da6-896d-3336aadf681c,7cc8b823c86988dd67edbd20da9994cf,gdiqTU2qtWt6wBbcUzWqK15OhLPoGY3BUTS0okVX/D790mZHsorMJeKhp1eOANxgpektE/BHRSjtEj21avDikg==; expires=Thu, 23-Jan-2020 13:55:13 GMT; path=/; secure; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "LyndaLoginStatus=Unknown-Not-Logged-In; domain=.lynda.com; expires=Wed, 23-Jan-2030 09:55:13 GMT; path=/",
  "throttle-66ae19c25d337eab52ef80bb97b39dd7=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-7566ffb605d4cb8c15225d8859a6efd3=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-b8b96eed8d81f42a88aadaadc5139c25=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-66ae19c25d337eab52ef80bb97b39dd7=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "player_settings_0_7=player_type=2&video_format=2&cc_status=2&window_extra_height=148&volume_percentage=50&resolution=0&reset_on_plugins=True; expires=Wed, 12-Feb-2020 09:55:13 GMT; path=/",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "litrk-srcveh=srcValue=direct/none&vehValue=direct/none&prevSrc=&prevVeh=; expires=Sun, 23-Feb-2020 09:55:13 GMT; path=/; HttpOnly",
  "throttle-d3ebbd09ec7ecff8c4948ff79599614d=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-9620ede73ab0b3b8d0fe1e62763ad939=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-ad15fee1459e8f3e1ae3d8d711f77883=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-20fc2dfb0a81016faeebb960e94da216=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "throttle-f9151a904e07fa0812b7b9fb20b6f1ab=1; domain=.lynda.com; expires=Thu, 23-Jul-2020 08:55:13 GMT; path=/; HttpOnly",
  "NSC_ed11_xxx-iuuqt_wt=ffffffff096d9e2e45525d5f4f58455e445a4a423661;expires=Thu, 23-Jan-2020 10:00:13 GMT;path=/;secure;httponly",
  "NSC_ed11_xxx-iuuqffff096d9e2e=45525d5f4f58455e445a4a423661;expires=Thu, 23-Jan-; 2020 10:00:13 GMT;path=/;secure;httponly",
]

# https://stackoverflow.com/questions/18492576/share-cookie-between-subdomain-and-domain


# parser = CParser.new
# set_cookies.lazy.map do |header|
#   parser.parse(header)
# end.to_a.yield_self do |all_cookies|
#   puts ::YAML.dump(all_cookies)
# end

jar = ::Greed::Cookie::Jar.new
set_cookies.each do |header|
  jar.parse_set_cookie('https://www.lynda.com/eeee', header)
end
puts ::YAML.dump(jar.dump)

# .each do |parsed_cookie|
#   # puts ::JSON.pretty_generate(
#   #   parsed_cookie,
#   # )
#   puts ::YAML.dump(
#     parsed_cookie,
#   )
# end