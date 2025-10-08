								                                                                 ##
##  COMMANDS:                                                                                        ##
##								                                                                     ##
##  To activate:                                                                                     ##
##  .chanset +miniradio | from BlackTools: .set #chan +miniradio                                     ##
##									                                                                 ##
##  !links - shows the radio listen links.                                                           ##
##									                                                                 ##
##  !radio - shows the radio website url.                                                            ##
##									                                                                 ##
##  !radio -version - shows the actual tcl script version.                                           ##
##									                                                                 ##
##  !!! ATTENTION !!!                                                                                ##
##									                                                                 ##
##  + ONLY ShoutCast v2 servers are supported.                                                       ##
##  + Works only if stream/radio is running/online.                                                  ##
##									                                                                 ##
###
#Set here the radio name
set miniradio(radio_name) "Poison"

###
#Set here the ip:port
set miniradio(ip_port) "45.140.140.212:8142"

###
#Set here the admin pass
set miniradio(pass) "2ZARNM975ZNM4"

###
#Set here the radio website url (will appear next to the now playing song)
set miniradio(website_url) "http://radio.poison.chat:8142/stream"

###
#Here are the links for !links cmd ( url link )
set miniradio(links_links) {
{ Browser https://poison.chat }
{ Winamp https://poison.chat/listen.pls }
{ TuneIn https://poison.chat }
}

###
#Here is the now playing message
set miniradio(now_playing) "Acum la radio: %song%"

###
#Here is the listeners message (if they change)
#set miniradio(listeners) "\002$miniradio(radio_name)\002 Ascultatori Radio Poison:\002 %listeners%\002 (%unique% unique)."

###
#Here is the !links message
set miniradio(links_message) "Asculta \002$miniradio(radio_name)\002 la %name% → \037%link%\037"

###
# FLOOD PROTECTION
# - set the number of minute(s) to ignore flooders (0 to disable)
###
set miniradio(ignore_prot) "1"

###
#Here is the flood message
set miniradio(flood_text) "Flood protection enabled. You need to wait\002 %get_seconds% seconds\002 before using commands again."

###
# FLOOD PROTECTION
# - set the number of !links before trigger flood protection.
# By default, 3:10, which allows for upto 3 queries in 10 seconds. 
# 3 or more quries in 10 seconds would cuase the forth and later 
# queries to be ignored for the amount of time specifide above.
###
set miniradio(flood_prot) "3:10"

###
#script banner
set miniradio(banner_radio) "\[Poison\]"

###
# Cmdchar trigger
# - set here the trigger you want to use.
set miniradio(char) "!"

#######################################################################################################
###                       DO NOT MODIFY HERE UNLESS YOU KNOW WHAT YOU'RE DOING                      ###
#######################################################################################################

package require http
encoding system utf-8

###
# Bindings
# - using commands
bind time - "* * * * *" miniradio:timer
bind pub - $miniradio(char)links miniradio:links
bind pub - $miniradio(char)radio miniradio:cmds
bind pub - $miniradio(char)like  miniradio:like
bind pub - $miniradio(char)dislike miniradio:dislike
bind pub - $miniradio(char)ador  miniradio:ador
bind pub - $miniradio(char)url   miniradio:url
bind pub - $miniradio(char)djon miniradio:set_dj_on
bind pub - $miniradio(char)djoff miniradio:set_dj_off
bind pub - $miniradio(char)dj miniradio:show_dj
bind pub - $miniradio(char)request miniradio:request
bind pub - $miniradio(char)cafea   miniradio:cafea
bind pub - $miniradio(char)vot     miniradio:vot
bind pub - $miniradio(char)ceai    miniradio:ceai
bind pub - $miniradio(char)vin     miniradio:vin
bind pub - $miniradio(char)add_schedule miniradio:add_schedule
bind pub - $miniradio(char)add miniradio:add
bind pub - miniradio(char)grila miniradio:grila
bind pub - miniradio(char)dans miniradio:dans
bind pub - $miniradio(char)ascultatori miniradio:ascultatori
bind pub - $miniradio(char)song miniradio:song
bind pub - $miniradio(char)cearta     miniradio:cearta

proc cearta {nick uhost hand chan text} {
    set args [split $text]
    
    if {[llength $args] != 3} {
        putserv "PRIVMSG $chan :\002Folosire:\002 !cearta nick1 cu nick2"
        return
    }

    set nick1 [lindex $args 0]
    set keyword [lindex $args 1]
    set nick2 [lindex $args 2]

    if {![string equal $keyword "cu"]} {
        putserv "PRIVMSG $chan :\002Format incorect!\002 Foloseste: !cearta nick1 cu nick2"
        return
    }

    # Lista de insulte amuzante
    set insulte {
        "se trag de păr ca doi pisoi furioși!"
        "își aruncă cuvinte grele, parcă sunt într-o telenovelă!"
        "se ceartă de parcă au de împărțit o moștenire!"
        "se înjură de mama focului, parcă sunt la colțul blocului!"
        "se împing unul pe altul până cad pe jos!"
        "se bat cu pernele, dar devine serios!"
        "își rup hainele de pe ei de nervi!"
    }

    set insult [lindex $insulte [expr {int(rand()*[llength $insulte])}]]
    
    # Mesajul generat
    putserv "PRIVMSG $chan :🔥 $nick1 $insult $nick2! 🔥"
}

proc miniradio:song {nick host hand chan arg} {
    global miniradio

    if {[channel get $chan miniradio]} {
        set current_song [miniradio:getinfo "song"]

        if {$current_song == "" || $current_song == "-1"} {
            putserv "PRIVMSG $chan :\002Momentan nu se difuzeaza nicio melodie.\002"
        } else {
            putserv "PRIVMSG $chan :\002Melodia curenta:\002 $current_song"
        }
    }
}

proc miniradio:ascultatori {nick host hand chan arg} {
    global miniradio

    if {[channel get $chan miniradio]} {
        set listeners [miniradio:getinfo "listeners"]
        set unique_listeners [miniradio:getinfo "uniq_listeners"]
        
        if {$listeners == ""} {
            putserv "PRIVMSG $chan :\002$nick\002, nu am putut obține numărul de ascultători."
            return
        }

        putserv "PRIVMSG $chan :\002$miniradio(radio_name)\002 are în acest moment \002$listeners\002 ascultatori (\002$unique_listeners\002 unici)."
    }
}

proc miniradio:vot {nick host hand chan arg} {
    global miniradio

    if {![channel get $chan miniradio]} {
        return
    }

    # Timpul curent în secunde
    set current_time [clock seconds]

    # Identificator unic per nick+hand
    set user_id "$nick:$hand"
    set last_vote_var "vot_last_time:$user_id"

    # Durata de cooldown (24 ore = 86400 secunde)
    set cooldown 86400

    if {[info exists miniradio($last_vote_var)]} {
        set last_vote_time $miniradio($last_vote_var)
        set seconds_since [expr {$current_time - $last_vote_time}]
        if {$seconds_since < $cooldown} {
            set remaining [expr {$cooldown - $seconds_since}]
            set hours [expr {$remaining / 3600}]
            set minutes [expr {($remaining % 3600) / 60}]
            set seconds [expr {$remaining % 60}]
            putserv "PRIVMSG $chan :\002$nick\002, poți vota din nou în \002${hours}h ${minutes}m ${seconds}s\002."
            return
        }
    }

    # Actualizăm timpul ultimului vot
    set miniradio($last_vote_var) $current_time

    # Creștem contorul de voturi
    incr miniradio(vot)

    putserv "PRIVMSG $chan :\002$nick\002 a votat cu succes DJ-ul din emisie. Mulțumim! ✅"
}


proc miniradio:dans {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        incr miniradio(dans)
        if {$arg == ""} {
            putserv "PRIVMSG $chan :\002$nick\002, trebuie să specifici un utilizator! Exemplu: !dans nume"
            return
        }
        set targetNick [lindex [split $arg] 0]  ;# Extragem primul cuvânt (numele țintă)
        putserv "PRIVMSG $chan :\002$nick\002 invita pe \002$targetNick\002 la dans!"
    }
}

proc miniradio:vin {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        incr miniradio(vin)

        if {$arg == ""} {
            putserv "PRIVMSG $chan :\002$nick\002, trebuie să specifici un utilizator! Exemplu: !vin nume"
            return
        }
        set targetNick [lindex [split $arg] 0]  ;# Extragem primul cuvânt (numele țintă)
        putserv "PRIVMSG $chan :🍷 \002$nick\002 servește pe \002$targetNick\002 cu vin!"
    }
}

proc miniradio:cafea {nick host hand chan arg} {
    global miniradio

    if {[channel get $chan miniradio]} {
        incr miniradio(cafea)

        if {$arg == ""} {
            putserv "PRIVMSG $chan :\002$nick\002, trebuie să specifici un utilizator! Exemplu: !ceai Cineva"
            return
        }
        set targetNick [lindex [split $arg] 0]  ;# Extragem primul cuvânt (numele țintă)
        putserv "PRIVMSG $chan :\002$nick\002 servește pe \002$targetNick\002 cu cafea! ☕️"
    }
}

proc miniradio:request {nick host hand chan arg} {
    global miniradio

    # Verificăm dacă există un DJ live
    if {![info exists miniradio(dj_name)] || $miniradio(dj_name) == ""} {
        putserv "PRIVMSG $chan :\002$nick\002, momentan nu este niciun DJ live pentru a primi cererea ta."
        return
    }

    # Verificăm dacă utilizatorul a introdus o melodie
    if {$arg == ""} {
        putserv "PRIVMSG $chan :\002$nick\002, te rog specifică melodia dorită! Exemplu: !request Vanilla Ice - Ice Ice Baby"
        return
    }

    # DJ-ul activ la care trebuie să ajungă cererea
    set dj_name $miniradio(dj_name)

    # Formăm mesajul de request
    set mesaj "Utilizatorul \002$nick\002 a cerut melodia: \002$arg\002"

    # Trimitem mesajul în privat către DJ
    putserv "PRIVMSG $dj_name :$mesaj"

    # Confirmăm în canal că cererea a fost trimisă
    putserv "PRIVMSG $chan :\002$nick\002, cererea ta a fost trimisă DJ-ului \002$dj_name\002!"
}

proc miniradio:ador {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        incr miniradio(ador)
        putserv "PRIVMSG $chan :\002$nick\002 adora melodia!"
    }
}

proc miniradio:like {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        incr miniradio(likes)
        putserv "PRIVMSG $chan :\002$nick\002 apreciaza melodia!"
    }
}

proc miniradio:dislike {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        incr miniradio(dislikes)
        putserv "PRIVMSG $chan :\002$nick\002 nu a apreciat melodia!"
    }
}

proc miniradio:url {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        incr miniradio(url)
        putserv "PRIVMSG $chan :https://radio.chatapropo.ro/asculta"
    }
}

# Funcția pentru a seta DJ-ul live
proc miniradio:set_dj_on {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        # Verifică dacă există un argument
        if {[llength [split $arg]] == 0} {
            putserv "PRIVMSG $chan :\002$nick\002, te rog furnizează un nume de DJ pentru a-l seta! Folosește: !djon <nume_dj>"
            return
        }

        # Extrage numele DJ-ului din argument
        set dj_name [lindex [split $arg] 0]

        # Setează numele DJ-ului live
        set miniradio(dj_name) $dj_name

        putserv "PRIVMSG $chan :\002$nick\002 a intrat LIVE DJ-ul: $miniradio(dj_name)"
    }
}

# Funcția pentru a dezactiva DJ-ul live
proc miniradio:set_dj_off {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        set miniradio(dj_name) ""
        putserv "PRIVMSG $chan :DJ-ul live a fost dezactivat."
    }
}

# Funcția pentru a arăta DJ-ul live
proc miniradio:show_dj {nick host hand chan arg} {
    global miniradio
    if {[channel get $chan miniradio]} {
        if {$miniradio(dj_name) != ""} {
            putserv "PRIVMSG $chan :\002DJ-ul live acum este: $miniradio(dj_name)\002"
        } else {
            putserv "PRIVMSG $chan :\002Momentan nu este niciun DJ LIVE.\002"
        }
    }
}

###
# Channel flags
setudef flag miniradio

###
proc miniradio:links {nick host hand chan arg} {
	global miniradio
if {[channel get $chan miniradio]} {
if {$miniradio(ignore_prot) != "0"} {
	set flood_protect [miniradio:flood:prot $chan $host]
if {$flood_protect == "1"} {
	set get_seconds [miniradio:get:flood_time $host $chan]
	set replace(%get_seconds%) $get_seconds
	puthelp "NOTICE $nick :$miniradio(banner_radio) \002$nick\002: [string map [array get replace] $miniradio(flood_text)]"
	return
	}
}
foreach ap $miniradio(links_links) {
	set name [lindex $ap 0]
	set link [maketiny [lindex $ap 1]]
	set replace(%name%) $name
	set replace(%link%) $link
	puthelp "PRIVMSG $chan :\002$miniradio(banner_radio)\002 [string map [array get replace] $miniradio(links_message)]"
		}
	}
}

###
proc miniradio:timer {min hour day mon year} {
	global miniradio
	set channels ""
	set new_song 0
	set new_listeners 0
foreach chan [channels] {
if {[channel get $chan miniradio]} {
	lappend channels $chan
		}
	}
if {$channels != ""} {
	set current_song [miniradio:getinfo "song"]
if {$current_song == ""} { return }
	set listeners [miniradio:getinfo "listeners"]
	set uniq_listeners [miniradio:getinfo "uniq_listeners"]
if {![info exists miniradio(current_song)]} {
	set new_song 1
	set miniradio(current_song) $current_song
} elseif {$miniradio(current_song) != $current_song} {
	set new_song 1
	set miniradio(current_song) $current_song
}
if {![info exists miniradio(current_listeners)]} {
	set new_listeners 1
	set miniradio(current_listeners) $listeners
} elseif {$miniradio(current_listeners) != $listeners} {
	set new_listeners 1
	set miniradio(current_listeners) $listeners
}
	miniradio:timer:act $channels 0 $current_song $listeners $new_song $new_listeners $uniq_listeners
	}
}

###
proc miniradio:reset {} {
	global miniradio
if {[info exists miniradio(current_song)]} {
	unset miniradio(current_song)
	}
if {[info exists miniradio(current_listeners)]} {
	unset miniradio(current_listeners)
	}
}

###
proc miniradio:timer:act {channels num current_song listeners new_song new_listeners uniq_listeners} {
	global miniradio botnick
	set chan [lindex $channels $num]
	set replace(%song%) $current_song
	set replace(%listeners%) $listeners
	set replace(%unique%) $uniq_listeners
if {$current_song == "-1"} { 
	miniradio:reset
	return 
}
if {$new_song == "1"} {
	putserv "PRIVMSG $chan :\002$miniradio(banner_radio)\002 [string map [array get replace] $miniradio(now_playing)]"
}
if {$new_listeners == "1"} {
	putserv "PRIVMSG $chan :$miniradio(banner_radio) [string map [array get replace] $miniradio(listeners)]"
}
	set counter [expr $num + 1]
if {[lindex $channels $counter] != ""} {
	utimer 2 [list miniradio:timer:act $channels $counter $current_song $listeners $new_song $new_listeners $uniq_listeners]
	}
}

###
proc miniradio:getinfo {type} {
	global miniradio
	set info ""
	set data [miniradio:getdata]
if {$data == "-1"} { return -1 }
	set output [split $data "\n"]
	set firstline [lindex $output 0]
if {[string equal -nocase $type "song"]} {
	regexp {<SONGTITLE>(.*)</SONGTITLE>} $firstline info
	set info [encoding convertfrom utf-8 [miniradio:filter $info]]
	return $info
} elseif {[string equal -nocase $type "listeners"]} {
	regexp {<CURRENTLISTENERS>(.*)</CURRENTLISTENERS>} $firstline info
	set info [miniradio:filter $info]
	return $info
} elseif {[string equal -nocase $type "uniq_listeners"]} {
	regexp {<UNIQUELISTENERS>(.*)</UNIQUELISTENERS>} $firstline info
	set info [miniradio:filter $info]
	return $info
	}
}

###
proc miniradio:getdata {} {
	global miniradio
	set link "http://$miniradio(ip_port)/admin.cgi?pass=$miniradio(pass)&sid=1&mode=viewxml"
	set ipq [http::config -useragent "lynx"]
	set error [catch {set ipq [http::geturl $link -timeout 50000]} eror]
	set getipq [http::data $ipq]
	::http::cleanup $ipq
if {$error == "0" || $ipq != ""} {
	return $getipq
	} else { return -1 }
}

###
proc miniradio:filter {data} {
	global miniradio
	set text [string map { "<SONGTITLE>" ""
							"</SONGTITLE>" ""
							"<CURRENTLISTENERS>" ""
							"</CURRENTLISTENERS>" ""
							"<UNIQUELISTENERS>" ""
							"</UNIQUELISTENERS>" ""
							"&amp;" "&"
							"&apos;" "'"
							"&gt;" ">"
							"&lt;" "<"
							} $data]
	return $text
}

###
proc miniradio:flood:prot {chan host} {
	global miniradio
	set number [scan $miniradio(flood_prot) %\[^:\]]
	set timer [scan $miniradio(flood_prot) %*\[^:\]:%s]
if {[info exists miniradio(flood:$host:$chan:act)]} {
	return 1
}
foreach tmr [utimers] {
if {[string match "*miniradio:remove:flood $host $chan*" [join [lindex $tmr 1]]]} {
	killutimer [lindex $tmr 2]
	}
}
if {![info exists miniradio(flood:$host:$chan)]} { 
	set miniradio(flood:$host:$chan) 0 
}
	incr miniradio(flood:$host:$chan)
	utimer $timer [list miniradio:remove:flood $host $chan]	
if {$miniradio(flood:$host:$chan) > $number} {
	set miniradio(flood:$host:$chan:act) 1
	utimer [expr $miniradio(ignore_prot) * 60] [list miniradio:expire:flood $host $chan]
	return 1
	} else {
	return 0
	}
}

###
proc miniradio:remove:flood {host chan} {
	global miniradio
if {[info exists miniradio(flood:$host:$chan)]} {
	unset miniradio(flood:$host:$chan)
	}
}

###
proc miniradio:expire:flood {host chan} {
	global miniradio
if {[info exists miniradio(flood:$host:$chan:act)]} {
	unset miniradio(flood:$host:$chan:act)
	}
}

###
proc miniradio:get:flood_time {host chan} {
	global miniradio
		foreach tmr [utimers] {
if {[string match "*miniradio:expire:flood $host $chan*" [join [lindex $tmr 1]]]} {
	return [lindex $tmr 0]
		}
	}
}

###
proc miniradio:cmds {nick host hand chan arg} {
	global miniradio
	if {![channel get $chan miniradio]} {
		return
	}
if {$miniradio(ignore_prot) != "0"} {
	set flood_protect [miniradio:flood:prot $chan $host]
	if {$flood_protect == "1"} {
		set get_seconds [miniradio:get:flood_time $host $chan]
		set replace(%get_seconds%) $get_seconds
		putserv "NOTICE $nick :$miniradio(banner_radio) \002$nick\002: [string map [array get replace] $miniradio(flood_text)]"
		return
	}
}
	set set [lindex [split $arg] 0]
	switch $set {
		-version {
		putserv "PRIVMSG $chan :\002$miniradio(projectName) $miniradio(version)\002 coded by\002 $miniradio(author)\002 ($miniradio(email)) --\002 $miniradio(website)\002. PRIVATE TCL available only on donations."
		}
		
		rules {
		putserv "PRIVMSG $chan :\002$miniradio(banner_radio)\002 $chan rules:  https://poison.chat/rules)"
		}
		help {
		putserv "NOTICE $nick :\002$miniradio(banner_radio)\002 Commands: \002$miniradio(char)radio\002 \[?|help\] ; \002$miniradio(char)links\002 ; \002$miniradio(char)radio\002 ; \002$miniradio(char)radio\002 rules ; \002$miniradio(char)radio\002 -version"
		}
		\? {
		putserv "NOTICE $nick :\002$miniradio(banner_radio)\002 Commands: \002$miniradio(char)radio\002 \[?|help\] ; \002$miniradio(char)links\002 ; \002$miniradio(char)radio\002 ; \002$miniradio(char)radio\002 rules ; \002$miniradio(char)radio\002 -version"
		}
		default {
		putserv "PRIVMSG $chan :$miniradio(banner_radio) website → \037$miniradio(website_url)\037"
		}
	}
}

###
# Thanks to speechless
# http://forum.egghelp.org/viewtopic.php?t=11277&start=179
proc maketiny {url} {
	set ua "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5"
	set http [::http::config -useragent $ua -useragent "utf-8"]
	set token [http::geturl "http://tinyurl.com/api-create.php?[http::formatQuery url $url]" -timeout 3000]
	upvar #0 $token state
if {[string length $state(body)]} { return $state(body) }
	return $url
}

###
# Credits
set miniradio(projectName) "miniRadio"
set miniradio(author) "BLaCkShaDoW"
set miniradio(website) "wWw.TCLScriptS.NeT"
set miniradio(email) "blackshadow\[at\]tclscripts.net"
set miniradio(version) "v1.0"

putlog "\002$miniradio(projectName) $miniradio(version)\002 by\002 $miniradio(author)\002 ($miniradio(website)): Loaded & initialised.."

##################
#######################################################################################################
###                  *** END OF MINI RADIO TCL ***                                                  ###
#######################################################################################################
