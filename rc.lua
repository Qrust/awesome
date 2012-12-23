-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Hardware library
vicious = require("vicious")

require("lfs") 
-- {{{ Run programm once
local function processwalker()
   local function yieldprocess()
      for dir in lfs.dir("/proc") do
        -- All directories in /proc containing a number, represent a process
        if tonumber(dir) ~= nil then
          local f, err = io.open("/proc/"..dir.."/cmdline")
          if f then
            local cmdline = f:read("*all")
            f:close()
            if cmdline ~= "" then
              coroutine.yield(cmdline)
            end
          end
        end
      end
    end
    return coroutine.wrap(yieldprocess)
end

local function run_once(process, cmd)
   assert(type(process) == "string")
   local regex_killer = {
      ["+"]  = "%+", ["-"] = "%-",
      ["*"]  = "%*", ["?"]  = "%?" }

   for p in processwalker() do
      if p:find(process:gsub("[-+?*]", regex_killer)) then
   return
      end
   end
   return awful.util.spawn(cmd or process)
end
-- }}}

-- Usage Example
run_once("compton")
run_once("dropboxd", "-no-splash")
run_once("insync", "-no-splash")
--run_once("dropboxd")

-- Use the second argument, if the programm you wanna start, 
-- differs from the what you want to search.
--run_once("redshift", "nice -n19 redshift -l 51:14 -t 5700:4500")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/dunzor/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "gnome-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
--  names = {"_web_","_term_","_misc_","_music_","_mov_","_del_","_pgl_","_tor_"},
  names = {" Ѩ "," Ѭ "," Ѡ "," Ѻ "," Ѯ "," Ѱ "," Ѳ "," Ѵ "},
  layout = {layouts[10],layouts[1],layouts[1],layouts[1],layouts[1],layouts[1],layouts[1],layouts[1],layouts[1],layouts[1]},
  icons = {"/home/msjche/.config/awesome/Icons/Awesome/web.png","/home/msjche/.config/awesome/Icons/Awesome/terminal.png","","","","","","/home/msjche/.config/awesome/Icons/Awesome/pirate.png"}
      }
for s = 1, screen.count() do
      -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
    awful.tag.seticon(tags.icons[1],tags[s][1])
    awful.tag.seticon(tags.icons[2],tags[s][2])
    awful.tag.seticon(tags.icons[3],tags[s][3]) 
    awful.tag.seticon(tags.icons[4],tags[s][4])
    awful.tag.seticon(tags.icons[5],tags[s][5])
    awful.tag.seticon(tags.icons[6],tags[s][6])
    awful.tag.seticon(tags.icons[7],tags[s][7])
    awful.tag.seticon(tags.icons[8],tags[s][8])

end
-- }}}
--for a = 1, 8, 1 do
--awful.tag.setproperty(tags[1][a], "icon_only", 1)
--end

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Calendar widget to attach to the textclock
require('calendar2')
calendar2.addCalendarToWidget(mytextclock)

-------------------------------------------------------------------------------------------

-- MPD (ncmpcpp)

spacetxt = widget({ type = "textbox" })
  spacetxt.text = "   "

mpdimg = widget({ type = "imagebox"})
mpdimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/music.png")

mpdwidget = widget({ type = "textbox" })
vicious.register(mpdwidget, vicious.widgets.mpd,
      function (widget, args)
        if args["{state}"] == "Stop" then 
          return " - "
        else 
          return args["{Artist}"]..' - '.. args["{Title}"]
        end
      end, 10)

-------------------------------------------------------------------------------------------

-- Volume

volimg = widget({ type = "imagebox"})
volimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/volume.png")

volumecfg = {}
volumecfg.cardid  = 0
volumecfg.channel = "Master"
volumecfg.widget = widget({ type = "textbox", name = "volumecfg.widget", align = "right" })
volumecfg_t = awful.tooltip({ objects = { volumecfg.widget },})
volumecfg_t:set_text("Volume")

-- command must start with a space!
volumecfg.mixercommand = function (command)
       local fd = io.popen("amixer -c " .. volumecfg.cardid .. command)
       local status = fd:read("*all")
       fd:close()

       local volume = string.match(status, "(%d?%d?%d)%%")
       volume = string.format("% 3d", volume)
       status = string.match(status, "%[(o[^%]]*)%]")
       if string.find(status, "on", 1, true) then
               volume = volume .. "%"
       else
               volume = volume .. "M"
       end
       volumecfg.widget.text = volume
end
volumecfg.update = function ()
       volumecfg.mixercommand(" sget " .. volumecfg.channel)
end
volumecfg.up = function ()
       volumecfg.mixercommand(" sset " .. volumecfg.channel .. " 1%+")
end
volumecfg.down = function ()
       volumecfg.mixercommand(" sset " .. volumecfg.channel .. " 1%-")
end
volumecfg.toggle = function ()
       volumecfg.mixercommand(" sset " .. volumecfg.channel .. " toggle")
end
volumecfg.widget:buttons({
       button({ }, 4, function () volumecfg.up() end),
       button({ }, 5, function () volumecfg.down() end),
       button({ }, 1, function () volumecfg.toggle() end)
})
volumecfg.update()

-------------------------------------------------------------------------------------------

-- Weather

weatherimg = widget({ type = "imagebox"})
weatherimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/weather.png")

-- Weather widget
weatherwidget = widget({ type = "textbox" })
weather_t = awful.tooltip({ objects = { weatherwidget },})

vicious.register(weatherwidget, vicious.widgets.weather,
	function (widget, args)
        	weather_t:set_text("City: " .. args["{city}"] .."\nWind: " .. args["{windkmh}"] .. "km/h " .. args["{wind}"] .. "\nSky: " .. args["{sky}"] .. "\nHumidity: " .. args["{humid}"] .. "%")
                	return args["{tempf}"] .. " F"
                end, 1800, "KCCR")
--                end, 1800, "KRDD")
     	--'1800': check every 30 minutes.
        --'KCCR': the Walnut Creek ICAO code.
        --'KRDD': the Redding ICAO code.        

-------------------------------------------------------------------------------------------

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
--            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        spacetxt,
        volumecfg.widget,
        spacetxt,
        volimg,
        spacetxt,
        spaceimg,
        mpdwidget,
        spacetxt,
        mpdimg,
        spacetxt,
        weatherwidget,
        spacetxt,
        weatherimg,
        spacetxt,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

---------------------------------------------------------------------------------------------------------------------------------------

-- {{{ Wibox (Bottom)

mytextbox1 = widget({ type = "textbox" })
  mytextbox1.text = " - "
mytextbox2 = widget({ type = "textbox" })
  mytextbox2.text = " : "
mytextbox3 = widget({ type = "textbox" })
  mytextbox3.text = "  _|_  "
mytextbox4 = widget({ type = "textbox" })
  mytextbox4.text = " "
mytextbox9 = widget({ type = "textbox" })
  mytextbox9.text = " rem : "


space = widget({ type = "imagebox"})
space.image = image("/home/msjche/.config/awesome/Icons/Awesome/spacer.png")


-------------------------------------------------------------------------------------------

-- Memory

memimg = widget({ type = "imagebox"})
memimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/memory.png")

-- Memory status
memwidgettxt = widget({ type = "textbox" })
vicious.register(memwidgettxt, vicious.widgets.mem, "mem $2 MB ($1%)", 5)

-- Memory graph
memwidget = awful.widget.progressbar()
memwidget:set_width(10)
memwidget:set_height(15)
memwidget:set_vertical(true)
memwidget:set_background_color("#494B4F")
--memwidget:set_border_color(nil)
memwidget:set_color("#539FFF")
memwidget:set_gradient_colors({ "#539FFF", "#539FFF", "#539FFF" })
vicious.register(memwidget, vicious.widgets.mem, "$1", 5)

-- Swap status
swapwidgettxt = widget({ type = "textbox" })
vicious.register(swapwidgettxt, vicious.widgets.mem, " swap $6 MB ($5%)", 5)

-- Swap graph
swapwidget = awful.widget.progressbar()
swapwidget:set_width(10)
swapwidget:set_height(15)
swapwidget:set_vertical(true)
swapwidget:set_background_color("#494B4F")
--swapwidget:set_border_color(nil)
swapwidget:set_color("#539FFF")
swapwidget:set_gradient_colors({ "#539FFF", "#539FFF", "#539FFF" })
vicious.register(swapwidget, vicious.widgets.mem, "$5", 5)

-------------------------------------------------------------------------------------------

-- HDD

-- Disk usage widget
diskwidget = widget({ type = 'imagebox' })
diskwidget.image = image("/home/msjche/.config/awesome/Icons/Awesome/harddrive.png")
disk = require("diskusage")
-- the first argument is the widget to trigger the diskusage
-- the second/third is the percentage at which a line gets orange/red
-- true = show only local filesystems
disk.addToWidget(diskwidget, 75, 90, false)

-- Root drive status
roottxt = widget({ type = "textbox" })
vicious.register(roottxt, vicious.widgets.fs, " / (${/ used_p}%)", 15)

-- Root drive graph
rootg = awful.widget.progressbar()
rootg:set_width(10)
rootg:set_height(15)
rootg:set_vertical(true)
rootg:set_background_color("#494B4F")
rootg:set_border_color(nil)
rootg:set_color("#539FFF")
vicious.register(rootg, vicious.widgets.fs, "${/ used_p}", 120, 60)

-- Home drive status
hometxt = widget({ type = "textbox" })
vicious.register(hometxt, vicious.widgets.fs, " /home (${/home used_p}%)", 15)

-- Home drive graph
homeg = awful.widget.progressbar()
homeg:set_width(10)
homeg:set_height(15)
homeg:set_vertical(true)
homeg:set_background_color("#494B4F")
homeg:set_border_color(nil)
homeg:set_color("#539FFF")
vicious.register(homeg, vicious.widgets.fs, "${/home used_p}", 120, 60)

-- Var drive status
vartxt = widget({ type = "textbox" })
vicious.register(vartxt, vicious.widgets.fs, "/var (${/var used_p}%)", 15)

-- Var drive graph
varg = awful.widget.progressbar()
varg:set_width(10)
varg:set_height(15)
varg:set_vertical(true)
varg:set_background_color("#494B4F")
varg:set_border_color(nil)
varg:set_color("#539FFF")
vicious.register(varg, vicious.widgets.fs, "${/var used_p}", 120, 60)

-------------------------------------------------------------------------------------------

-- CPU

cpuimg = widget({ type = "imagebox"})
cpuimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/cpu.png")

ctext1 = widget({ type = "textbox"})
cgraph1 = awful.widget.graph()
cgraph1:set_width(60):set_height(15)
cgraph1:set_stack(true):set_max_value(100)
cgraph1:set_background_color("#494B4F")
--  cgraph1:set_border_color("#494B4F")
cgraph1:set_stack_colors({ "#539FFF", "#539FFF" })
vicious.register(ctext1, vicious.widgets.cpu,
      function (widget, args)
        cgraph1:add_value(args[2], 1) -- Core 1, color 1
--      cgraph1:add_value(args[3], 2) -- Core 2, color 2
      end, 2)

ctext2 = widget({ type = "textbox"})
cgraph2 = awful.widget.graph()
cgraph2:set_width(60):set_height(15)
cgraph2:set_stack(true):set_max_value(100)
cgraph2:set_background_color("#494B4F")
--  cgraph2:set_border_color("#494B4F")
cgraph2:set_stack_colors({ "#539FFF", "#539FFF" })
vicious.register(ctext2, vicious.widgets.cpu,
      function (widget, args)
--      cgraph2:add_value(args[2], 1) -- Core 1, color 1
        cgraph2:add_value(args[3], 2) -- Core 2, color 2
      end, 2)

-------------------------------------------------------------------------------------------

-- Battery

batimg = widget({ type = "imagebox"})
batimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/battery.png")

-- Battery status
batwidgettxt1 = widget({ type = "textbox" })
vicious.register(batwidgettxt1, vicious.widgets.bat, "$2%", 120, "BAT0")

batwidgettxt2 = widget({ type = "textbox" })
vicious.register(batwidgettxt2, vicious.widgets.bat, "$3", 120, "BAT0")

-- Battery graph
batwidget = awful.widget.progressbar()
batwidget:set_width(10)
batwidget:set_height(15)
batwidget:set_vertical(true)
batwidget:set_background_color("#494B4F")
batwidget:set_border_color(nil)
batwidget:set_color("#539FFF")
vicious.register(batwidget, vicious.widgets.bat, "$2", 120, "BAT0")

-------------------------------------------------------------------------------------------

-- Network

upimg = widget({ type = "imagebox"})
upimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/up.png")

downimg = widget({ type = "imagebox"})
downimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/down.png")

wifiimg = widget({ type = "imagebox"})
wifiimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/wifi.png")

netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net, 'u/d (${wlan0 up_kb}/${wlan0 down_kb}) kps', 1)

-- Network widget
netwidgetd = awful.widget.graph()
netwidgetd:set_width(40)
netwidgetd:set_height(15)
netwidgetd:set_background_color("#494B4F")
netwidgetd:set_color("#539FFF")
netwidgetd:set_gradient_colors({ "#539FFF", "#539FFF", "#539FFF" })
netwidgetd_t = awful.tooltip({ objects = { netwidget.widget },})
vicious.register(netwidgetd, vicious.widgets.net,
      function (widget, args)
        netwidgetd_t:set_text("Network download: " .. args["{wlan0 down_kb}"] .. "kb/s")
        return args["{wlan0 down_kb}"]
      end, 1 )

netwidgetu = awful.widget.graph()
netwidgetu:set_width(40)
netwidgetu:set_height(15)
netwidgetu:set_background_color("#494B4F")
netwidgetu:set_color("#539FFF")
netwidgetu:set_gradient_colors({ "#539FFF", "#539FFF", "#539FFF" })
netwidgetu_t = awful.tooltip({ objects = { netwidget.widget },})
vicious.register(netwidgetu, vicious.widgets.net,
      function (widget, args)
        netwidgetu_t:set_text("Network download: " .. args["{wlan0 up_kb}"] .. "kb/s")
        return args["{wlan0 up_kb}"]
      end, 1 )

-- WiFi
wifiwidget = widget({ type = "textbox" })
vicious.register(wifiwidget, vicious.widgets.wifi,  "\"${ssid}\" @ ${link}% - ", 10, "wlan0")

-------------------------------------------------------------------------------------------

-- Uptime

uptimeimg = widget({ type = "imagebox"})
uptimeimg.image = image("/home/msjche/.config/awesome/Icons/Awesome/uptime.png")

uptimewidget = widget({ type = "textbox" })
vicious.register(uptimewidget, vicious.widgets.uptime,
      function (widget, args)
        return string.format("%2dd %02d:%02d ", args[1], args[2], args[3])
      end, 61)

-------------------------------------------------------------------------------------------

-- Create a wibox for each screen and add it
mywibox = {}
  for s = 1, screen.count() do
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "bottom", height = "15", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mytextbox4,
            space,
            mytextbox4,
            cpuimg,
            mytextbox2,
            cgraph1,
            mytextbox4,
            cgraph2,
            mytextbox4,
            space,
            mytextbox4,
            diskwidget,
            mytextbox2,
            rootg,
            mytextbox4,
            roottxt,
            mytextbox4,
            homeg,
            mytextbox4,
            hometxt,
            mytextbox4,
            varg,
            mytextbox4,
            vartxt,
            mytextbox4,
            space,
            mytextbox4,
            memimg,
            mytextbox2,
            memwidget,
            mytextbox4,
            memwidgettxt,
            mytextbox4,
            swapwidget,
            swapwidgettxt,
            mytextbox4,
            space,
            mytextbox4,
            batimg,
            mytextbox2,
            batwidget,
            mytextbox4,
            batwidgettxt1,
            mytextbox4,
            mytextbox9,
            batwidgettxt2,
            mytextbox4,
	    space,
            mytextbox4,
            mytextbox4,
            wifiimg,
            mytextbox2,
            wifiwidget,
            netwidgetd,
            mytextbox4,
            downimg,
            mytextbox1,
            netwidgetu,
            mytextbox4,
            upimg,
            mytextbox4,
            space,
            layout = awful.widget.layout.horizontal.leftright
        },
        mytextbox4,
        uptimewidget,
        mytextbox2,
        uptimeimg,
	layout = awful.widget.layout.horizontal.rightleft
                          }
end
-- }}}

-----------------------------------------------------------------------------------------------------------------

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ }, "XF86AudioRaiseVolume", function () volumecfg.up() end),
        awful.key({ }, "XF86AudioLowerVolume", function () volumecfg.down() end),
        awful.key({ }, "XF86AudioMute", function () volumecfg.toggle() end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
