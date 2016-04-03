/////////////////////
//CONTENTS
//Global Vars and procs
//Topic() - A giant fuck tonne of admin options.
//Admin panels
//Admin procs
//

var/global/noir = 0

////////////////////////////////
/proc/message_admins(var/text, var/asay = 0)
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[text]</span></span>"
	for (var/mob/M in mobs)
		if (M && M.client && M.client.holder)
			if (!asay && rank_to_level(M.client.holder.rank) < LEVEL_MOD) // No confidential info for goat farts (Convair880).
				continue
			if (M.client.player_mode)
				if (asay && M.client.player_mode_asay)
					boutput(M, replacetext(rendered, "%admin_ref%", "\ref[M.client.holder]"))
				else
					continue
			else
				boutput(M, replacetext(rendered, "%admin_ref%", "\ref[M.client.holder]")) //this doesnt fail if the placeholder doesnt exist ok dont worry
		sleep(-1)

/proc/message_coders(var/text) //Shamelessly adapted from message_admins
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">CODER LOG:</span> <span class=\"message\">[text]</span></span>"
	for (var/mob/M in mobs)
		if (M && M.client && M.client.holder && rank_to_level(M.client.holder.rank) >= LEVEL_CODER) //This is for edge cases where a coder needs a goddamn notification when it happens
			boutput(M, replacetext(rendered, "%admin_ref%", "\ref[M.client.holder]"))
		sleep(-1)

/proc/message_attack(var/text) //Sends a message to folks when an attack goes down
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ATTACK LOG:</span> <span class=\"message\">[text]</span></span>"
	for (var/mob/M in mobs)
		if (M && M.client && M.client.holder && rank_to_level(M.client.holder.rank) >= LEVEL_MOD && M.client.holder.attacktoggle && !M.client.player_mode)
			boutput(M, replacetext(rendered, "%admin_ref%", "\ref[M.client.holder]"))
		sleep(-1)

/proc/rank_to_level(var/rank)
	var/level = 0
	switch(rank)
		if("Host")
			level = LEVEL_HOST
		if("Coder")
			level = LEVEL_CODER
		if("Shit Person")
			level = LEVEL_SHITGUY
		if("Primary Administrator")
			level = LEVEL_PA
		if("Administrator")
			level = LEVEL_ADMIN
		if("Secondary Administrator")
			level = LEVEL_SA
		if("Moderator")
			level = LEVEL_MOD
		if("Goat Fart", "Ayn Rand's Armpit")
			level = LEVEL_BABBY
	return level

/datum/admins/Topic(href, href_list)
	..()

	if (src.level < 0)
		alert("UM, EXCUSE ME??  YOU AREN'T AN ADMIN, GET DOWN FROM THERE!")
		usr << csound("sound/misc/poo2.ogg")
		return

	if (usr.client != src.owner)
		message_admins("<span style=\"color:blue\">[key_name(usr)] has attempted to override the admin panel!</span>")
		logTheThing("admin", usr, null, "tried to use the admin panel without authorization.")
		logTheThing("diary", usr, null, "tried to use the admin panel without authorization.", "admin")
		return

	//Wires bad hack to update the player options menu on click, part 1
	//Also I guess it has sort of expanded now to correctly pick targets
	if (href_list["targetckey"])
		var/targetCkey = href_list["targetckey"]
		for (var/mob/M in mobs) //Find the mob ref for that nerd
			if (M.ckey == targetCkey)
				href_list["target"] = "\ref[M]"
				break

	var/originWindow
	var/adminCkey = usr.client.ckey
	if (href_list["origin"])
		originWindow = href_list["origin"]

	if (!href_list["action"])
		//alert("You must define an action! Yell at Wire if you see this.")
		return
	switch(href_list["action"])

		if ("load_admin_prefs")
			if (src.level >= LEVEL_MOD)
				src.load_admin_prefs()
		if ("save_admin_prefs")
			if (src.level >= LEVEL_MOD)
				src.save_admin_prefs()
		if ("refresh_admin_prefs")
			if (src.level >= LEVEL_MOD)
				src.show_pref_window(usr)

		if ("toggle_extra_verbs")
			if (src.level >= LEVEL_CODER)
				usr.client.toggle_extra_verbs()
				src.show_pref_window(usr)
		if ("toggle_popup_verbs")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_popup_verbs()
				src.show_pref_window(usr)
		if ("toggle_server_toggles_tab")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_server_toggles_tab()
				src.show_pref_window(usr)
		if ("toggle_atom_verbs")
			if (src.level >= LEVEL_PA)
				usr.client.toggle_atom_verbs()
				src.show_pref_window(usr)
		if ("toggle_attack_messages")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_attack_messages()
				src.show_pref_window(usr)
		if ("toggle_hear_prayers")
			if (src.level >= LEVEL_MOD)
				usr.client.holder.hear_prayers = !usr.client.holder.hear_prayers
				src.show_pref_window(usr)
		if ("toggle_auto_stealth")
			if (src.level >= LEVEL_SA)
				src.auto_stealth = !(src.auto_stealth)
				boutput(usr, "<span style=\"color:blue\">Auto Stealth [src.auto_stealth ? "enabled" : "disabled"].</span>")
				if (src.auto_stealth)
					if (src.auto_alt_key)
						src.auto_alt_key = 0
					if (usr.client.alt_key)
						src.set_alt_key()
					if (!usr.client.stealth && !isnull(src.auto_stealth_name))
						src.set_stealth_mode(src.auto_stealth_name)
					else if (isnull(src.auto_stealth_name))
						var/new_key = input("Enter your desired display name.", "Fake Key", usr.client.key) as null|text
						if (!new_key)
							src.auto_stealth_name = null
							boutput(usr, "<span style=\"color:blue\">Auto Stealth name removed.</span>")
							return src.show_pref_window(usr)
						if (alert("Use \"[new_key]\" as your Auto Stealth name?", "Confirmation", "OK", "Cancel") == "OK")
							src.auto_stealth_name = new_key
							src.set_stealth_mode(src.auto_stealth_name)
						else
							src.auto_stealth_name = null
							boutput(usr, "<span style=\"color:blue\">Auto Stealth name removed.</span>")
							return src.show_pref_window(usr)
				src.show_pref_window(usr)
		if ("set_auto_stealth_name")
			if (src.level >= LEVEL_SA)
				var/new_key = input("Enter your desired display name.", "Fake Key", usr.client.key) as null|text
				if (!new_key)
					src.auto_stealth_name = null
					boutput(usr, "<span style=\"color:blue\">Auto Stealth name removed.</span>")
					return
				if (alert("Use \"[new_key]\" as your Auto Stealth name?", "Confirmation", "OK", "Cancel") == "OK")
					src.auto_stealth_name = new_key
					src.show_pref_window(usr)
				else
					src.auto_stealth_name = null
					boutput(usr, "<span style=\"color:blue\">Auto Stealth name removed.</span>")
					return
		if ("toggle_auto_alt_key")
			if (src.level >= LEVEL_SA)
				src.auto_alt_key = !(src.auto_alt_key)
				boutput(usr, "<span style=\"color:blue\">Auto Alt Key [src.auto_alt_key ? "enabled" : "disabled"].</span>")
				if (src.auto_alt_key)
					if (src.auto_stealth)
						src.auto_stealth = 0
					if (usr.client.stealth)
						src.set_stealth_mode()
					if (!usr.client.alt_key && !isnull(src.auto_alt_key_name))
						src.set_alt_key(src.auto_alt_key_name)
					else if (isnull(src.auto_alt_key_name))
						var/new_key = input("Enter your desired display name.", "Alt Key", usr.client.key) as null|text
						if (!new_key)
							src.auto_alt_key_name = null
							boutput(usr, "<span style=\"color:blue\">Auto Alt Key removed.</span>")
							return src.show_pref_window(usr)
						if (alert("Use \"[new_key]\" as your Auto Alt Key?", "Confirmation", "OK", "Cancel") == "OK")
							src.auto_alt_key_name = new_key
							src.set_alt_key(src.auto_alt_key_name)
						else
							src.auto_alt_key_name = null
							boutput(usr, "<span style=\"color:blue\">Auto Alt Key removed.</span>")
							return src.show_pref_window(usr)
				src.show_pref_window(usr)
		if ("set_auto_alt_key_name")
			if (src.level >= LEVEL_SA)
				var/new_key = input("Enter your desired display name.", "Alt Key", usr.client.key) as null|text
				if (!new_key)
					src.auto_alt_key_name = null
					boutput(usr, "<span style=\"color:blue\">Auto Alt Key removed.</span>")
					return
				if (alert("Use \"[new_key]\" as your Auto Alt Key?", "Confirmation", "OK", "Cancel") == "OK")
					src.auto_alt_key_name = new_key
					src.show_pref_window(usr)
				else
					src.auto_alt_key_name = null
					boutput(usr, "<span style=\"color:blue\">Auto Alt Key removed.</span>")
					return

		if ("refreshoptions")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.holder.playeropt(M)

		if("call_shuttle")
			if (src.level >= LEVEL_SA)
				switch(href_list["type"])
					if("1")
						if ((!( ticker ) || emergency_shuttle.location))
							return
						emergency_shuttle.incall()
						boutput(world, "<span style=\"color:blue\"><B>Alert: The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</B></span>")
						logTheThing("admin", usr, null,  "called the Emergency Shuttle")
						logTheThing("diary", usr, null, "called the Emergency Shuttle", "admin")
						message_admins("<span style=\"color:blue\">[key_name(usr)] called the Emergency Shuttle to the station</span>")

					if("2")
						if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0))
							return
						switch(emergency_shuttle.direction)
							if(-1)
								emergency_shuttle.incall()
								boutput(world, "<span style=\"color:blue\"><B>Alert: The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</B></span>")
								logTheThing("admin", usr, null, "called the Emergency Shuttle")
								logTheThing("diary", usr, null, "called the Emergency Shuttle", "admin")
								message_admins("<span style=\"color:blue\">[key_name(usr)] called the Emergency Shuttle to the station</span>")
							if(1)
								emergency_shuttle.recall()
								boutput(world, "<span style=\"color:blue\"><B>Alert: The shuttle is going back!</B></span>")
								logTheThing("admin", usr, null, "sent the Emergency Shuttle back")
								logTheThing("diary", usr, null, "sent the Emergency Shuttle back", "admin")
								message_admins("<span style=\"color:blue\">[key_name(usr)] recalled the Emergency Shuttle</span>")
			else
				alert("You need to be at least a Secondary Administrator to do a shuttle call.")

		if("edit_shuttle_time")
			if (src.level >= LEVEL_SHITGUY)
				emergency_shuttle.settimeleft( input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", emergency_shuttle.timeleft() ) as num )
				logTheThing("admin", usr, null, "edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]")
				logTheThing("diary", usr, null, "edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]", "admin")
				message_admins("<span style=\"color:blue\">[key_name(usr)] edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft(, 1)]</span>")
			else
				alert("You need to be at least a Shit Person to edit the shuttle timer.")

		if("notes")
			var/player = null
			var/mob/M = locate(href_list["target"])
			if(M)
				player = M.ckey
			else
				player = href_list["target"]
			if(!player)
				return
			src.player_notes(player)

		if("notes2")
			var/player = href_list["target"]
			if(!player)
				return
			//if(rank_to_level(admins[player]) > src.level) <- Pointless.
			//	alert("You can't modify this player's notes, they are of a higher admin rank!")
			//	return
			switch(href_list["type"])
				if("del")
					if(src.level < LEVEL_SA)
						alert("You need to be at least a Primary Administrator to delete notes.")
						return
					if(href_list["id"])
						if(alert("Delete This Note?",,"Yes","No") == "No")
							return
						else
							world.Export("[config.player_notes_baseurl]playernotes.php?action=delnote&id=[href_list["id"]]")
							src.player_notes(player)
							logTheThing("admin", usr, null, "deleted note [href_list["id"]] belonging to [player].")
							logTheThing("diary", usr, null, "deleted note [href_list["id"]] belonging to [player].", "admin")
							message_admins("<span style=\"color:blue\">[key_name(usr)] deleted note [href_list["id"]] belonging to <A href='?src=%admin_ref%;action=notes&target=[player]'>[player]</A>.</span>")

				if("add")
					if(src.level < LEVEL_SA)
						alert("You need to be at least a Secondary Adminstrator to add notes.")
						return
					var/list/new_note = list()
					new_note["admin"] = usr.ckey
					new_note["ckey"] = player
					new_note["note"] = url_encode(input("Write your note here!", "Note for [player]") as text)
					if (new_note["note"])
						add_player_note(new_note["ckey"], new_note["admin"], new_note["note"])
						spawn(20) src.player_notes(player)
						logTheThing("admin", usr, null, "added a note for [player]: [new_note["note"]]")
						logTheThing("diary", usr, null, "added a note for [player]: [new_note["note"]]", "admin")
						message_admins("<span style=\"color:blue\">[key_name(usr)] added a note for <A href='?src=%admin_ref%;action=notes&target=[player]'>[player]</A>.</span>")

		if("viewcompids")

			var/player = href_list["targetckey"]
			view_client_compid_list(usr, player)

			return

		/////////////////////////////////////ban stuff
		if ("addban") //Add ban
			var/mob/M = (href_list["target"] ? locate(href_list["target"]) : null)
			usr.client.addBanDialog(M)

		if("unbane") //Edit ban
			if (src.level >= LEVEL_SA)
				var/id = html_decode(href_list["id"])
				var/ckey = html_decode(href_list["target"])
				var/compID = html_decode(href_list["compID"])
				var/ip = html_decode(href_list["ip"])
				var/reason = html_decode(href_list["reason"])
				var/timestamp = html_decode(href_list["timestamp"])

				usr.client.editBanDialog(id, ckey, compID, ip, reason, timestamp)
			else
				alert("You need to be at least a Secondary Administrator to edit bans.")

		if("unbanf") //Delete ban
			if (src.level >= LEVEL_SA)
				var/id = html_decode(href_list["id"])
				var/ckey = html_decode(href_list["target"])
				var/compID = html_decode(href_list["compID"])
				var/ip = html_decode(href_list["ip"])
				var/akey = usr.client.ckey

				usr.client.deleteBanDialog(id, ckey, compID, ip, akey)
			else
				alert("You need to be at least a Secondary Administrator to remove bans.")
		/////////////////////////////////////end ban stuff

		if("jobbanpanel")
			var/mob/M = locate(href_list["target"])
			var/dat = ""
			var/header = "<b>Pick Job to ban this guy from.<br>"
			var/body
	//		var/list/alljobs = get_all_jobs()
			var/jobs = ""

			if (!M) return

			for(var/job in uniquelist(occupations))
				if(job in list("Tourist","Mining Supervisor","Atmospheric Technician","Vice Officer"))
					continue
				if(jobban_isbanned(M, job))
					jobs += "<a href='?src=\ref[src];action=jobban;type=[job];target=\ref[M]'><font color=red>[replacetext(job, " ", "&nbsp")]</font></a> "
				else
					jobs += "<a href='?src=\ref[src];action=jobban;type=[job];target=\ref[M]'>[replacetext(job, " ", "&nbsp")]</a> " //why doesn't this work the stupid cunt

			if(jobban_isbanned(M, "Captain"))
				jobs += "<a href='?src=\ref[src];action=jobban;type=Captain;target=\ref[M]'><font color=red>Captain</font></a> "
			else
				jobs += "<a href='?src=\ref[src];action=jobban;type=Captain;target=\ref[M]'>Captain</a> " //why doesn't this work the stupid cunt

			if(jobban_isbanned(M, "Head of Security"))
				jobs += "<a href='?src=\ref[src];action=jobban;type=Head of Security;target=\ref[M]'><font color=red>Head of Security</font></a> "
			else
				jobs += "<a href='?src=\ref[src];action=jobban;type=Head of Security;target=\ref[M]'>Head of Security</a> "

			if(jobban_isbanned(M, "Syndicate"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Syndicate;target=\ref[M]'><font color=red>[replacetext("Syndicate", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Syndicate;target=\ref[M]'>[replacetext("Syndicate", " ", "&nbsp")]</a> " //why doesn't this work the stupid cunt

			if(jobban_isbanned(M, "Special Respawn"))
				jobs += " <a href='?src=\ref[src];action=jobban;type=Special Respawn;target=\ref[M]'><font color=red>[replacetext("Special Respawn", " ", "&nbsp")]</font></a> "
			else
				jobs += " <a href='?src=\ref[src];action=jobban;type=Special Respawn;target=\ref[M]'>[replacetext("Special Respawn", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Engineering Department"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Engineering Department;target=\ref[M]'><font color=red>[replacetext("Engineering Department", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Engineering Department;target=\ref[M]'>[replacetext("Engineering Department", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Security Department"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Security Department;target=\ref[M]'><font color=red>[replacetext("Security Department", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Security Department;target=\ref[M]'>[replacetext("Security Department", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Heads of Staff"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Heads of Staff;target=\ref[M]'><font color=red>[replacetext("Heads of Staff", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Heads of Staff;target=\ref[M]'>[replacetext("Heads of Staff", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Everything Except Assistant"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Everything Except Assistant;target=\ref[M]'><font color=red>[replacetext("Everything Except Assistant", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Everything Except Assistant;target=\ref[M]'>[replacetext("Everything Except Assistant", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Custom Names"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Custom Names;target=\ref[M]'><font color=red>[replacetext("Having a Custom Name", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Custom Names;target=\ref[M]'>[replacetext("Having a Custom Name", " ", "&nbsp")]</a> "


			body = "<br>[jobs]<br><br>"
			dat = "<tt>[header][body]</tt>"
			usr << browse(dat, "window=jobban2;size=600x150")

		if("jobban")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/job = href_list["type"]
				if (!M) return
				if ((M.client && M.client.holder && (M.client.holder.level > src.level)))
					alert("You cannot perform this action. You must be of a higher administrative rank!")
					return
				if (jobban_isbanned(M, job))
					if(jobban_keylist.Find(text("[M.ckey] - Everything Except Assistant")) && job != "Everything Except Assistant")
						alert("This person is banned from Everything Except Assistant. You must lift that ban first.")
						return
					if(job in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
						if(jobban_keylist.Find(text("[M.ckey] - Engineering Department")))
							alert("This person is banned from Engineering Department. You must lift that ban first.")
							return
					if(job in list("Security Officer","Vice Officer","Detective"))
						if(jobban_keylist.Find(text("[M.ckey] - Security Department")))
							alert("This person is banned from Security Department. You must lift that ban first.")
							return
					if(job in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
						if(jobban_keylist.Find(text("[M.ckey] - Heads of Staff")))
							alert("This person is banned from Heads of Staff. You must lift that ban first.")
							return
					logTheThing("admin", usr, M, "unbanned %target% from [job]")
					logTheThing("diary", usr, M, "unbanned %target% from [job]", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] unbanned [key_name(M)] from [job]</span>")
					add_player_note(M, usr, "[usr] unbanned [M] from [job]")
					jobban_unban(M, job)
					if (announce_jobbans) boutput(M, "<span style=\"color:red\"><b>[key_name(usr)] has lifted your [job] job-ban.</b></span>")
				else
					logTheThing("admin", usr, M, "banned %target% from [job]")
					logTheThing("diary", usr, M, "banned %target% from [job]", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] banned [key_name(M)] from [job]</span>")
					add_player_note(M, usr, "[usr] banned [M] from [job]")
					if(job == "Everything Except Assistant")
						if(jobban_keylist.Find(text("[M.ckey] - Engineering Department")))
							jobban_unban(M,"Engineering Department")
						if(jobban_keylist.Find(text("[M.ckey] - Security Department")))
							jobban_unban(M,"Security Department")
						if(jobban_keylist.Find(text("[M.ckey] - Heads of Staff")))
							jobban_unban(M,"Heads of Staff")
						for(var/Trank1 in uniquelist(occupations))
							if(jobban_keylist.Find(text("[M.ckey] - [Trank1]")))
								jobban_unban(M,Trank1)
					else if(job == "Engineering Department")
						for(var/Trank2 in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
							if(jobban_keylist.Find(text("[M.ckey] - [Trank2]")))
								jobban_unban(M,Trank2)
					else if(job == "Security Department")
						for(var/Trank3 in list("Security Officer","Vice Officer","Detective"))
							if(jobban_keylist.Find(text("[M.ckey] - [Trank3]")))
								jobban_unban(M,Trank3)
					else if(job == "Heads of Staff")
						for(var/Trank4 in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
							if(jobban_keylist.Find(text("[M.ckey] - [Trank4]")))
								jobban_unban(M,Trank4)
					jobban_fullban(M, job)
					if (announce_jobbans) boutput(M, "<span style=\"color:red\"><b>[key_name(usr)] has job-banned you from [job].</b></span>")
			else
				alert("You need to be at least a Secondary Administrator to work with job bans.")

		if ("boot")
			var/mob/M = locate(href_list["target"])
			usr.client.cmd_boot(M)

		if ("removejobban")
			if (src.level >= LEVEL_CODER)
				var/t = href_list["target"]
				if(t)
					logTheThing("admin", usr, null, "removed [t]")
					logTheThing("diary", usr, null, "removed [t]", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] removed [t]</span>")
					jobban_remove(t)
			else
				alert("You need to be at least a Coder to remove job bans.")

		if ("mute")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (ismob(M) && M.client)
					var/muted = 0
					if (M.client.ismuted())
						M.client.unmute()
					else
						M.client.mute(-1)
						muted = 1
					logTheThing("admin", usr, M, "has [(muted ? "permanently muted" : "unmuted")] %target%")
					logTheThing("diary", usr, M, "has [(muted ? "permanently muted" : "unmuted")] %target%.", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] has [(muted ? "permanently muted" : "unmuted")] [key_name(M)].</span>")
					boutput(M, "You have been [(muted ? "permanently muted" : "unmuted")].")
			else
				alert("You need to be at least a Moderator to mute people.")

		if ("tempmute")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					var/muted = 0
					if (M.client.ismuted())
						M.client.unmute()
					else
						M.client.mute(60)
						muted = 1
					logTheThing("admin", usr, M, "has [(muted ? "temporarily muted" : "unmuted")] %target%")
					logTheThing("diary", usr, M, "has [(muted ? "temporarily muted" : "unmuted")] %target%.", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] has [(muted ? "temporarily muted" : "unmuted")] [key_name(M)].</span>")
					boutput(M, "You have been [(muted ? "temporarily muted" : "unmuted")].")
			else
				alert("You need to be at least a Moderator to mute people.")
		if ("banooc")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (ismob(M) && M.client)
					var/oocbanned = 0
					if (!oocban_isbanned(M))
						oocban_fullban(M)
						oocbanned = 1
					else
						oocban_unban(M)
					logTheThing("admin", usr, M, "has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] %target%")
					logTheThing("diary", usr, M, "has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] %target%.", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] [key_name(M)].</span>")

		if ("toggle_hide_mode")
			if (src.level >= LEVEL_SA)
				ticker.hide_mode = !ticker.hide_mode
				Topic(null, list("src" = "\ref[src]", "action" = "c_mode_panel"))
			else
				alert("You need to be at least a Secondary Administrator to hide the game mode.")

		if ("c_mode_panel") // I removed some broken/discontinued game modes here (Convair880).
			if (src.level >= LEVEL_SA)
				var/cmd = "c_mode_current"
				var/addltext = ""
				if (ticker && ticker.current_state != GAME_STATE_PREGAME)
					cmd = "c_mode_next"
					addltext = " next round"
				var/dat = {"
							<html><body><title>Select Round Mode</title>
							<B>What mode do you wish to play[addltext]?</B><br>
							Current mode is: <i>[master_mode]</i><br>
							Mode is <A href='?src=\ref[src];action=toggle_hide_mode'>[ticker.hide_mode ? "hidden" : "not hidden"]</a><br/>
							<HR>
							<b>Regular Modes:</b><br>
							<A href='?src=\ref[src];action=[cmd];type=secret'>Secret</A><br>
							<A href='?src=\ref[src];action=[cmd];type=mixed'>Mixed</A><br>
							<A href='?src=\ref[src];action=[cmd];type=traitor'>Traitor</A><br>
							<A href='?src=\ref[src];action=[cmd];type=nuclear'>Nuclear Emergency</A><br>
							<A href='?src=\ref[src];action=[cmd];type=wizard'>Wizard</A><br>
							<A href='?src=\ref[src];action=[cmd];type=changeling'>Changeling</A><br>
							<A href='?src=\ref[src];action=[cmd];type=blob'>Blob</A><br>
							<b>Other Modes</b><br>
							<A href='?src=\ref[src];action=[cmd];type=extended'>Extended</A><br>
							<A href='?src=\ref[src];action=[cmd];type=disaster'>Disaster (Beta)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=spy'>Conspiracy</A><br>
							<A href='?src=\ref[src];action=[cmd];type=revolution'>Revolution</A><br>
							<A href='?src=\ref[src];action=[cmd];type=revolution_extended'>Revolution (no time limit)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=gang'>Gang War (Beta)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=construction'>Construction (For testing only. Don't select this!)</A>
							</body></html>
						"}
				usr << browse(dat, "window=c_mode")
			else
				alert("You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("c_mode_current")
			if (src.level >= LEVEL_SA)
				if (ticker && ticker.current_state != GAME_STATE_PREGAME)
					return alert(usr, "The game has already started.", null, null, null, null)

				var/list/valid_modes = list("secret","random","traitor","meteor","extended","monkey",
				"nuclear","blob","restructuring","wizard","revolution", "revolution_extended","malfunction",
				"spy","gang","disaster","changeling","vampire","mixed","construction")

				var/requestedMode = href_list["type"]
				if (requestedMode in valid_modes)
					logTheThing("admin", usr, null, "set the mode as [requestedMode].")
					logTheThing("diary", usr, null, "set the mode as [requestedMode].", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] set the mode as [requestedMode].</span>")
					world.save_mode(requestedMode)
					master_mode = requestedMode
					if (alert("Declare mode change to all players?","Mode Change","Yes","No") == "Yes")
						boutput(world, "<span style=\"color:blue\"><b>The mode is now: [requestedMode]</b></span>")
				else
					boutput(usr, "<span style=\"color:red\"><b>That is not a valid game mode!</b></span>")
			else
				alert("You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("c_mode_next")
			if (src.level >= LEVEL_SA)
				var/newmode = href_list["type"]
				logTheThing("admin", usr, null, "set the next round's mode as [newmode].")
				logTheThing("diary", usr, null, "set the next round's mode as [newmode].", "admin")
				message_admins("<span style=\"color:blue\">[key_name(usr)] set the next round's mode as [newmode].</span>")
				world.save_mode(newmode)
				if (alert("Declare mode change to all players?","Mode Change","Yes","No") == "Yes")
					boutput(world, "<span style=\"color:blue\"><b>The next round's mode will be: [newmode]</b></span>")
			else
				alert("You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("monkeyone")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if(!ismob(M))
					return
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/N = M
					logTheThing("admin", usr, M, "attempting to monkeyize %target%")
					logTheThing("diary", usr, M, "attempting to monkeyize %target%", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] attempting to monkeyize [key_name(M)]</span>")
					N.monkeyize()
				else
					boutput(usr, "<span style=\"color:red\">You can't transform that mob type into a monkey.</span>")
					return
			else
				alert("You need to be at least a Secondary Adminstrator to monkeyize players.")

		if ("toggle_dj")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					usr.client.give_dj(M)
			else
				alert("You need to be at least a Primary Administrator to give a non-admin the ability to play music.")

		if ("forcespeech")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					var/speech = input("What will [key_name(M)] say?.", "Force speech", "")
					if(!speech)
						return
					M.say(speech)
					speech = copytext(sanitize(speech), 1, MAX_MESSAGE_LEN)
					logTheThing("admin", usr, M, "forced %target% to say: [speech]")
					logTheThing("diary", usr, M, "forced %target% to say: [speech]", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] forced [key_name(M)] to say: [speech]</span>")
			else
				alert("You need to be at least a Primary Administrator to force players to say things.")

		if ("prison")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (!M || !ismob(M)) return
				usr.client.cmd_admin_prison_unprison(M)
			else
				alert("You need to be at least a Moderator to send players to prison.")

		if ("shamecube")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_shame_cube(M)
			else
				alert("You need to be at least a Moderator to shame cube a player.")

		if ("tdome")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return

				var/team
				var/type = href_list["type"]
				if (type == "1")
					M.set_loc(pick(tdome1))
					team = "Team 1"
				else if (type == "2")
					M.set_loc(pick(tdome2))
					team = "Team 2"

				logTheThing("admin", usr, M, "sent %target% to the thunderdome. ([team])")
				logTheThing("diary", usr, M, "sent %target% to the thunderdome. ([team])", "admin")
				message_admins("[key_name(usr)] has sent [key_name(M)] to the thunderdome. ([team])")
				boutput(M, "<span style=\"color:blue\"><b>You have been sent to the Thunderdome. You are on [team].</b></span>")
				boutput(M, "<span style=\"color:blue\"><b>Prepare for combat. If you are not let out of the preparation area within a few minutes, please adminhelp. (F1 key)</b></span>")

			else
				alert("You need to be at least a Secondary Adminstrator to send players to Thunderdome.")

		if ("revive")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					if(istype(M, /mob/dead))
						alert("You can't revive a ghost! How does that even work?!")
						return
					if(config.allow_admin_rev)
						M.revive()
						message_admins("<span style=\"color:red\">Admin [key_name(usr)] healed / revived [key_name(M)]!</span>")
						logTheThing("admin", usr, M, "healed / revived %target%")
						logTheThing("diary", usr, M, "healed / revived %target%", "admin")
					else
						alert("Reviving is currently disabled.")
			else
				alert("You need to be at least a Primary Adminstrator to revive players.")

		if ("makeai")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/mob/newM = usr.client.cmd_admin_makeai(M)
				href_list["target"] = "\ref[newM]"
			else
				alert("You need to be at least a Secondary Adminstrator to turn players into AI units.")

		if ("modifylimbs")
			if (src.level >= LEVEL_SA)
				var/mob/MC = locate(href_list["target"])
				if (MC && usr.client)
					usr.client.modify_parts(MC, usr)
				/*if (!ishuman(MC))
					alert("Cannot limb modify [MC]: not human.")
					return
				var/mob/living/carbon/human/M = MC
				if (!M.limbs)
					alert("Mob limb holder is broken.")
					return
				var/which = input("Which limb?", "Which limb?", "cancel") in list("left arm", "right arm", "both arms", "left leg", "right leg", "both legs", "cancel")
				if (which == "cancel")
					return
				else if (which == "left arm" || which == "right arm" || which == "both arms")
					var/kind = input("What kind of arm?", "What kind of arm?", "normal arm") in list("normal arm", "synth arm", "blooming synth arm", "cyborg arm", "light cyborg arm", "wendigo arm", "bear arm", "abomination arm", "werewolf arm", "predator arm", "item arm", "sever")

					if (kind == "normal arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left(M)
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm magically regrows!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a normal arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a new left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right(M)
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm magically regrows!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a normal arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a new right arm.")

					if (kind == "synth arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left/synth(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm magically becomes a synth arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a synth arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a synth left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right/synth(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm magically becomes a synth arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a synth arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a synth right arm.")

					if (kind == "blooming synth arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left/synth/bloom(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm magically becomes a blooming synth arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a blooming synth arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a blooming synth left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right/synth/bloom(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm magically becomes a blooming synth arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a blooming synth arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a blooming synth right arm.")

					if (kind == "cyborg arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/robot_parts/arm/left(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm magically becomes a cyborg arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a cyborg arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a cyborg left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/robot_parts/arm/right(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm magically becomes a cyborg arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a cyborg arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a cyborg right arm.")

					if (kind == "light cyborg arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/robot_parts/arm/left/light(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm magically becomes a light cyborg arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a light cyborg arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a light cyborg left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/robot_parts/arm/right/light(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm magically becomes a light cyborg arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a light cyborg arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a light cyborg right arm.")

					if (kind == "wendigo arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left/wendigo(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm eeriely becomes a wendigo arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a wendigo arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a wendigo left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right/wendigo(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm eeriely becomes a wendigo arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a wendigo arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a wendigo right arm.")

					if (kind == "bear arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left/bear(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm eeriely becomes a bear arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a bear arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a bear left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right/bear(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm eeriely becomes a bear arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a bear arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a bear right arm.")

					if (kind == "abomination arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left/abomination(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm becomes a chitinous tendril!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with an abomination arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] an abomination left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right/abomination(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm becomes a chitinous tendril!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with an abomination arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] an abomination right arm.")

					if (kind == "werewolf arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left/werewolf(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm becomes a werewolf arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a werewolf arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a werewolf left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right/werewolf(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm becomes a werewolf arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a werewolf arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a werewolf right arm.")

					if (kind == "predator arm")
						if (which == "left arm" || which == "both arms")
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left/predator(M)
							limb.quality = 0.5
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left arm becomes a predator arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with a predator arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a predator left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right/predator(M)
							limb.quality = 0.5
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right arm becomes a predator arm!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with a predator arm.")
							message_admins("[key_name(usr)] gave [key_name(M)] a predator right arm.")

					else if (kind == "item arm")
						var/type_str = input("Enter a type path for the new arm.", "Replacing [which]", "/obj/item/saw/elimbinator") as text
						if (type_str == "")
							return
						var/type = text2path(type_str)
						if (type == null)
							alert("No such type ([type_str]).")
							return
						if (!ispath(type,/obj/item))
							alert("Item must be a descendant of /obj/item.")
							return
						if (which == "left arm" || which == "both arms")
							var/item = new type()
							if (M.limbs.l_arm)
								qdel(M.limbs.l_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left/item(M)
							M.limbs.l_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							limb:set_item(item)
							M.show_message("<span style=\"color:blue\"><b>Your left arm [pick("magically ", "weirdly ", "suddenly ", "unwillingly ", "grodily ", "")]becomes [item]!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left arm with [item].")
							message_admins("[key_name(usr)] gave [key_name(M)] a new left arm: [item]")
						if (which == "right arm" || which == "both arms")
							var/item = new type()
							if (M.limbs.r_arm)
								qdel(M.limbs.r_arm)
							var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right/item(M)
							M.limbs.r_arm = limb
							limb.holder = M
							limb.remove_stage = 0
							limb:set_item(item)
							M.show_message("<span style=\"color:blue\"><b>Your right arm [pick("magically ", "weirdly ", "suddenly ", "unwillingly ", "grodily ", "")]becomes [item]!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right arm with [item].")
							message_admins("[key_name(usr)] gave [key_name(M)] a new right arm: [item]")

					else if (kind == "sever")
						if (which == "left arm" || which == "both arms")
							if (M.limbs)
								if (M.limbs.l_arm)
									M.limbs.l_arm.sever()
									logTheThing("admin", usr, null, "severed [key_name(M)]'s left arm.")
									message_admins("[key_name(usr)] severed [key_name(M)]'s left arm.")
						if (which == "right arm" || which == "both arms")
							if (M.limbs)
								if (M.limbs.r_arm)
									M.limbs.r_arm.sever()
									logTheThing("admin", usr, null, "severed [key_name(M)]'s right arm.")
									message_admins("[key_name(usr)] severed [key_name(M)]'s right arm.")

				else if (which == "left leg" || which == "right leg" || which == "both legs")
					var/type = input("What kind?", "What kind?", "normal leg") in list("normal leg", "synth leg", "blooming synth leg", "cyborg leg", "light cyborg leg", "treads", "sever")
					if (type == "sever")
						if (which == "left leg" || which == "both legs")
							if (M.limbs)
								if (M.limbs.l_leg)
									M.limbs.l_leg.sever()
									logTheThing("admin", usr, null, "severed [key_name(M)]'s left leg.")
									message_admins("[key_name(usr)] severed [key_name(M)]'s left leg.")
						if (which == "right leg" || which == "both legs")
							if (M.limbs)
								if (M.limbs.r_leg)
									M.limbs.r_leg.sever()
									logTheThing("admin", usr, null, "severed [key_name(M)]'s right leg.")
									message_admins("[key_name(usr)] severed [key_name(M)]'s right leg.")
					else
						var/tpath = ""
						if (which == "left leg" || which == "both legs")
							if (type == "normal leg")
								tpath = /obj/item/parts/human_parts/leg/left
							else if (type == "synth leg")
								tpath = /obj/item/parts/human_parts/leg/left/synth
							else if (type == "blooming synth leg")
								tpath = /obj/item/parts/human_parts/leg/left/synth/bloom
							else if (type == "cyborg leg")
								tpath = /obj/item/parts/robot_parts/leg/left
							else if (type == "light cyborg leg")
								tpath = /obj/item/parts/robot_parts/leg/left/light
							else if (type == "treads")
								tpath = /obj/item/parts/robot_parts/leg/left/treads
							var/obj/item/parts/limb = new tpath(M)
							if (M.limbs.l_leg)
								qdel(M.limbs.l_leg)
							M.limbs.l_leg = limb
							limb:holder = M
							limb:remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your left leg becomes a brand new [limb]!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s left leg with [limb].")
							message_admins("[key_name(usr)] gave [key_name(M)] a new left leg: [limb]")

						if (which == "right leg" || which == "both legs")
							if (type == "normal leg")
								tpath = /obj/item/parts/human_parts/leg/right
							else if (type == "synth leg")
								tpath = /obj/item/parts/human_parts/leg/right/synth
							else if (type == "blooming synth leg")
								tpath = /obj/item/parts/human_parts/leg/right/synth/bloom
							else if (type == "cyborg leg")
								tpath = /obj/item/parts/robot_parts/leg/right
							else if (type == "light cyborg leg")
								tpath = /obj/item/parts/robot_parts/leg/right/light
							else if (type == "treads")
								tpath = /obj/item/parts/robot_parts/leg/right/treads
							var/obj/item/parts/limb = new tpath(M)
							if (M.limbs.r_leg)
								qdel(M.limbs.r_leg)
							M.limbs.r_leg = limb
							limb:holder = M
							limb:remove_stage = 0
							M.show_message("<span style=\"color:blue\"><b>Your right leg becomes a brand new [limb]!</b></span>")
							logTheThing("admin", usr, null, "replaced [key_name(M)]'s right leg with [limb].")
							message_admins("[key_name(usr)] gave [key_name(M)] a new right leg: [limb]")
					if (M.client)
						M.client.move_delay = 0

				M.set_body_icon_dirty()*/
			else
				alert("You need to be at least a Secondary Administrator to modify limbs.")


		if ("jumpto")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!istype(M, /mob/dead/target_observer))
					usr.client.jumptomob(M)
				else
					var/jumptarget = M.eye
					if (jumptarget)
						usr.client.jumptoturf(get_turf(jumptarget))
			else
				alert("You need to be at least a Secondary Adminstrator to jump to mobs.")

		if ("jumptocoords")
			if(src.level >= LEVEL_SA)
				var/list/coords = splittext(href_list["target"], ",")
				if (coords.len < 3) return
				usr.client.jumptocoord(text2num(coords[1]), text2num(coords[2]), text2num(coords[3]))
			else
				alert("You need to be at least a Secondary Adminstrator to jump to coords.")

		if ("getmob")
			if(( src.level >= LEVEL_SHITGUY ) || ((src.level >= LEVEL_PA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.Getmob(M)
			else
				alert("If you are below the rank of Shit Person, you need to be observing and at least a Primary Administrator to get a player.")

		if ("sendmob")
			if(( src.level >= LEVEL_SHITGUY ) || ((src.level >= LEVEL_PA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/list/areas = list( )
				for (var/area/A in world)
					areas += A
				var/area = input(usr, "Select an area") in areas
				usr.client.sendmob(M, area)
			else
				alert("If you are below the rank of Shit Person, you need to be observing and at least a Primary Administrator to get a player.")

		if ("gib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_gib(M)
			else
				alert("You need to be at least a Shit Person to gib a dude.")

		if ("partygib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_partygib(M)
			else
				alert("You need to be at least a Shit Person to party gib a dude.")

		if ("owlgib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_owlgib(M)
			else
				alert("A loud hooting noise is heard. It sounds angry. I guess you aren't allowed to do this.")

		if ("firegib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_firegib(M)
			else
				alert("You need to be at least a Shit Person to fire gib a dude.")

		if ("elecgib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_elecgib(M)
			else
				alert("You need to be at least a Shit Person to elec gib a dude.")

		if ("sharkgib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.sharkgib(M)
			else
				alert("You need to be at least a Shit Person to shark gib a dude.")

		if ("icegib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_icegib(M)
			else
				alert("You need to be at least a Shit Person to ice gib a dude.")

		if ("goldgib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_goldgib(M)
			else
				alert("You need to be at least a Shit Person to gold gib a dude.")

		if("spidergib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_spidergib(M)
			else
				alert("You need to be at least a Shit Person to spider gib a dude.")
		if("cluwnegib")
			if( src.level >= LEVEL_SHITGUY )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_cluwnegib(M)
			else
				alert("You need to be at least a Shit Person to cluwne gib a dude.")
		if("transform")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				if (!ishuman(M))
					alert("This secret can only be used on human mobs.")
					return
				var/mob/living/carbon/human/H = M
				var/which = input("Transform them into what?","Transform") as null|anything in list("Monkey","Cyborg","Lizardman","Squidman","Martian","Skeleton","Flashman","Ghostdrone")
				if (!which)
					return
				. = 0
				switch(which)
					if("Monkey")
						H.monkeyize()
					if("Cyborg")
						H.Robotize_MK2()
					if("Lizardman")
						H.set_mutantrace(/datum/mutantrace/lizard)
						. = 1
					if("Squidman")
						H.set_mutantrace(/datum/mutantrace/ithillid)
						. = 1
					if("Martian")
						H.set_mutantrace(/datum/mutantrace/martian)
						. = 1
					if("Skeleton")
						H.set_mutantrace(/datum/mutantrace/skeleton)
						. = 1
					if("Flashman")
						H.set_mutantrace(/datum/mutantrace/flashy)
						. = 1
					if("Ghostdrone")
						droneize(H, 0)
				if(.)
					message_admins("<span style=\"color:blue\">[key_name(usr)] transformed [H.real_name] into a [which].</span>")
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to transform a player.")

		if ("addbioeffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				var/mob/living/carbon/human/X = M
				var/pick = input("Which effect(s)?","Give Bioeffects") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (picklist && picklist.len >= 1)
					var/string_version
					for(pick in picklist)
						X.bioHolder.AddEffect(pick)

						if (string_version)
							string_version = "[string_version], \"[pick]\""
						else
							string_version = "\"[pick]\""

					message_admins("[key_name(usr)] added the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] to [key_name(X)].")
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to bioeffect a player.")

		if ("removebioeffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				var/mob/living/carbon/human/X = M
				var/pick = input("Which effect(s)?","Remove Bioeffects") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (picklist && picklist.len >= 1)
					var/string_version
					for(pick in picklist)
						X.bioHolder.RemoveEffect(pick)

						if (string_version)
							string_version = "[string_version], \"[pick]\""
						else
							string_version = "\"[pick]\""

					message_admins("[key_name(usr)] removed the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] from [X.real_name].")
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to bioeffect a player.")

		if ("addreagent")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				var/mob/living/carbon/human/X = M
				var/pick = input("Which reagent(s)?","Add Reagents") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (picklist && picklist.len >= 1)
					var/string_version

					for(pick in picklist)
						var/amt = input("How much of [pick]?","Add Reagent") as null|num
						if(!amt || amt < 0)
							return

						if (X.reagents)
							X.reagents.add_reagent(pick,amt)

						if (string_version)
							string_version = "[string_version], [amt] \"[pick]\""
						else
							string_version = "[amt] \"[pick]\""

					message_admins("[key_name(usr)] added [string_version] to [key_name(X)].")
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to affect player reagents.")

		if ("removereagent")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				var/mob/living/carbon/human/X = M
				var/pick = input("Which reagent(s)?","Remove Reagents") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (picklist && picklist.len >= 1)
					var/string_version

					for(pick in picklist)
						var/amt = input("How much of [pick]?","Remove Reagent") as null|num
						if(!amt || amt < 0)
							return

						if (X.reagents)
							X.reagents.remove_reagent(pick,amt)

						if (string_version)
							string_version = "[string_version], [amt] \"[pick]\""
						else
							string_version = "[amt] \"[pick]\""

					message_admins("[key_name(usr)] removed [string_version] from [X.real_name].")
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to affect player reagents.")

		if ("possessmob")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (M == usr)
					releasemob(M)
				else
					possessmob(M)
			else
				alert("You need to be at least a Primary Administrator to possess or release mobs.")

		if ("checkcontents")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_check_contents(M)
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to check player contents.")

		if ("dropcontents")
			if(( src.level >= LEVEL_SHITGUY ) || ((src.level >= LEVEL_PA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (alert(usr, "Make [M] drop everything?", "Confirmation", "Yes", "No") == "Yes")
					usr.client.cmd_admin_drop_everything(M)
			else
				alert("If you are below the rank of Shit Guy, you need to be observing and at least a Primary Admin to drop player contents.")

		if ("addabil")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!M.abilityHolder)
					alert("No ability holder detected. Create a holder first!")
					return
				var/ab_to_add = input("Which ability?", "Ability", null) as anything in (typesof(/datum/targetable) - /datum/targetable)
				M.abilityHolder.addAbility(ab_to_add)
				message_admins("[key_name(usr)] added ability [ab_to_add] to [key_name(M)].")
				logTheThing("admin", usr, M, "added ability [ab_to_add] to %target%.")
			else
				alert("You must be at least a Primary Administrator to do this!")

		if ("removeabil")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!M.abilityHolder)
					alert("No ability holder detected.")
					return
				var/ab_to_rem = input("Which ability?", "Ability", null) as anything in M.abilityHolder.abilities
				message_admins("[key_name(usr)] removed ability [ab_to_rem] from [key_name(M)].")
				logTheThing("admin", usr, M, "removed ability [ab_to_rem] from %target%.")
				M.abilityHolder.removeAbilityInstance(ab_to_rem)
			else
				alert("You must be at least a Primary Administrator to do this!")

		if ("abilholder")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/ab_to_add = input("Which holder?", "Ability", null) as anything in (typesof(/datum/abilityHolder) - /datum/abilityHolder)
				M.add_ability_holder(ab_to_add)
				message_admins("[key_name(usr)] created abilityHolder [ab_to_add] for [key_name(M)].")
				logTheThing("admin", usr, M, "created abilityHolder [ab_to_add] for %target%.")
			else
				alert("You must be at least a Primary Administrator to do this!")

		if("subtlemsg")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.cmd_admin_subtle_message(M)

		if("adminalert")
			var/mob/M = locate(href_list["target"])
			if(!M) return
			usr.client.cmd_admin_alert(M)

		if ("makewraith")
			if( src.level < LEVEL_PA)
				alert("You must be at least a Primary Administrator to make someone a wraith.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a wraith?", "Make Wraith", "Yes", "No") == "Yes")
				var/datum/mind/mind = M.mind
				if (!mind)
					mind = new /datum/mind(  )
					mind.key = M.key
					mind.current = M
					ticker.minds += mind
					M.mind = mind
				if (mind.objectives)
					mind.objectives.len = 0
				else
					mind.objectives = list()
				switch (alert("Objectives?", "Objectives", "Custom", "Random", "None"))
					if ("Custom")
						var/WO = null
						do
							WO = input("What objective?", "Objective", null) as null|anything in (typesof(/datum/objective/specialist/wraith) - /datum/objective/specialist/wraith)
							if (WO)
								var/datum/objective/specialist/wraith/WObj = new WO()
								WObj.owner = mind
								WObj.set_up()
								mind.objectives += WObj
						while (WO != null)
					if ("Random")
						generate_wraith_objectives(mind)
				var/mob/wraith/Wr = M.wraithize()
				if (!Wr)
					if (!istype(mind.current, /mob/wraith))
						boutput(usr, "<span style=\"color:red\">Wraithization failed! Call 1-800-MARQUESAS for help.</span>")
						return
					else
						Wr = mind.current
				if (mind.objectives.len)
					boutput(Wr, "<b>Your objectives:</b>")
					var/obj_count = 1
					for (var/datum/objective/objective in mind.objectives)
						boutput(Wr, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
						obj_count++
				mind.special_role = "wraith"
				ticker.mode.Agimmicks += mind
				Wr.antagonist_overlay_refresh(1, 0)

		if ("makeblob")
			if( src.level < LEVEL_PA )
				alert("You must be at least a Primary Administrator to make someone a blob.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a blob?", "Make Blob", "Yes", "No") == "Yes")
				var/mob/B = M.blobize()
				if (B)
					if (B.mind)
						B.mind.special_role = "blob"
						var/datum/objective/specialist/blob/Bl = new()
						Bl.owner = B.mind
						B.mind.objectives = list(Bl)

						var/i = 1
						for (var/datum/objective/Obj in B.mind.objectives)
							boutput(B, "<b>Objective #[i]</b>: [Obj.explanation_text]")
							i++
						ticker.mode.Agimmicks += B.mind
						B.antagonist_overlay_refresh(1, 0)

						spawn(0)
							var/newname = input(B, "You are a Blob. Please choose a name for yourself, it will show in the form: <name> the Blob", "Name change") as text

							if (newname)
								if (length(newname) >= 26) newname = copytext(newname, 1, 26)
								newname = replacetext(newname, ">", "'") + " the Blob"
								B.real_name = newname
								B.name = newname

		if ("makemacho")
			if( src.level < LEVEL_PA )
				alert("You must be at least a Primary Administrator to make someone a Macho Man.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a macho man?", "Make Macho", "Yes", "No") == "Yes")
				M.machoize()

		if ("makecritter")
			if( src.level < LEVEL_PA )
				alert("You must be at least a Primary Administrator to make someone a Critter.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a critter?", "Make Critter", "Yes", "No") == "Yes")
				var/CT = input("What kind of critter?", "Make Critter", null) as null|anything in (typesof(/mob/living/critter) - /mob/living/critter)
				if (CT != null)
					M.critterize(CT)

		if ("remove_traitor")
			if ( src.level < LEVEL_SA )
				alert("You must be at least a Secondary Administrator to remove someone's status as an antagonist.")
				return
			if (!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Remove [M]'s antag status?", "Remove Antag", "Yes", "No") == "Yes")
				if (!M) return
				if (!isturf(M.loc))
					// They could be in a pod or whatever, which would have unfortunate results when respawned (Convair880).
					alert(usr, "You currently cannot remove the antagonist status of somebody hiding in a pod, closet or other container.", "An error occurred")
					return
				remove_antag(M, usr, 0, 1)

		if ("traitor")
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return

			//independant of mode and can be traitors as well
			if(M.mind && (M.mind in miscreants))
				var/t = ""
				for(var/datum/objective/O in M.mind.objectives)
					if (istype(O, /datum/objective/miscreant))
						t += "[O.explanation_text]\n"
				alert("Miscreant! Objective: [t]")

			var/datum/game_mode/current_mode = ticker.mode
			if (istype(current_mode, /datum/game_mode/revolution))
				if(M.mind in current_mode:head_revolutionaries)
					alert("Head Revolutionary!")
					return
				else if(M.mind in current_mode:revolutionaries)
					alert("Revolutionary!")
					return
			else if (istype(current_mode, /datum/game_mode/nuclear))
				if(M.mind in current_mode:syndicates)
					alert("Syndicate Operative!", "[M.key]")
					return
			else if (istype(current_mode, /datum/game_mode/spy))
				if(M.mind in current_mode:leaders)
					var/datum/mind/antagonist = M.mind
					var/t = ""
					for(var/datum/objective/OB in antagonist.objectives)
						if (istype(OB, /datum/objective/crew) || istype(OB, /datum/objective/miscreant))
							continue
						t += "[OB.explanation_text]\n"
					if(antagonist.objectives.len == 0)
						t = "None defined."
					alert("Infiltrator. Objective(s):\n[t]", "[M.key]")
					return
			else if (istype(current_mode, /datum/game_mode/gang))
				if(M.mind in current_mode:leaders)
					alert("Leader of [M.mind.gang.gang_name].", "[M.key]")
					return
				for(var/datum/gang/G in current_mode:gangs)
					if(M in G.members)
						alert("Member of [G.gang_name].", "[M.key]")
						return

			// traitor, or other modes where traitors/counteroperatives would be.
			if(M.mind in current_mode.traitors)
				var/datum/mind/antagonist = M.mind
				var/t = ""
				for(var/datum/objective/OB in antagonist.objectives)
					if (istype(OB, /datum/objective/crew) || istype(OB, /datum/objective/miscreant))
						continue
					t += "[OB.explanation_text]\n"
				if(antagonist.objectives.len == 0)
					t = "None defined."
				alert("Assigned [M.mind.special_role]. Objective(s):\n[t]", "[M.key]")
				return
			if(M.mind in ticker.mode.Agimmicks)
				var/datum/mind/antagonist = M.mind
				var/t = ""
				for(var/datum/objective/OB in antagonist.objectives)
					if (istype(OB, /datum/objective/crew) || istype(OB, /datum/objective/miscreant))
						continue
					t += "[OB.explanation_text]\n"
				if(antagonist.objectives.len == 0)
					t = "None defined."
				alert("Assigned [M.mind.special_role]. Objective(s):\n[t]", "[M.key]")
				return

			//they're nothing so turn them into a traitor!
			if(ishuman(M) || isAI(M) || isrobot(M) || iscritter(M))
				var/traitorize = "Cancel"
				traitorize = alert("Is not a traitor, make Traitor?", "Traitor", "Yes", "Cancel")
				if(traitorize == "Cancel")
					return
				if(traitorize == "Yes")
					if (issilicon(M))
						evilize(M, "traitor")
					else if (iscritter(M))
						// The only role that works for all critters at this point is hard-mode traitor, really. The majority of existing
						// roles don't work for them, most can't wear clothes and some don't even have arms and/or can pick things up.
						// That said, certain roles are mostly compatible and thus selectable.
						var/list/traitor_types = list("Hard-mode traitor", "Wrestler", "Grinch")
						var/selection = input(usr, "Select traitor type.", "Traitorize", "Traitor") in traitor_types
						switch (selection)
							if ("Hard-mode traitor")
								evilize(M, "traitor", "hardmode")
							else
								evilize(M, selection)
							else
								spawn (0) alert("An error occurred, please try again.")
					else
						var/list/traitor_types = list("Traitor", "Wizard", "Changeling", "Vampire", "Werewolf", "Predator", "Wrestler", "Grinch", "Omnitraitor")
						if(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/gang))
							traitor_types += "Gang Leader"
						var/selection = input(usr, "Select traitor type.", "Traitorize", "Traitor") in traitor_types
						switch(selection)
							if("Traitor")
								if (alert("Hard Mode?","Treachery","Yes","No") == "Yes")
									evilize(M, "traitor", "hardmode")
								else
									evilize(M, "traitor")
							else
								evilize(M, selection)
							else
								spawn (0) alert("An error occurred, please try again.")
			//they're a ghost/hivebotthing/etc
			else
				alert("Cannot make this mob a traitor")

		if ("create_object")
			if (src.level >= LEVEL_PA)
				create_object(usr)
			else
				alert("You need to be at least a Primary Adminstrator to create objects.")

		if ("create_turf")
			if (src.level >= LEVEL_PA)
				create_turf(usr)
			else
				alert("You need to be at least a Primary Adminstrator to create turfs.")

		if ("create_mob")
			if (src.level >= LEVEL_PA) // Moved from SG to PA. They can do this through build mode anyway (Convair880).
				create_mob(usr)
			else
				alert("You need to be at least a Primary Administrator to create mobs.")

		if ("votekill")
			votekill()

		if ("voteres")
			voteres()

		if ("prom_demot")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/client/C = M.client
				if(C.holder && (C.holder.level >= src.level))
					alert("This cannot be done as [C] is ranked higher than you!")
					return
				var/dat = "[C] is a [C.holder ? "[C.holder.rank]" : "non-admin"]<br><br>Change [C]'s rank?<br>"
				if (src.level >= LEVEL_CODER)
					dat += {"
							<A href='?src=\ref[src];action=chgadlvl;type=Coder;target=\ref[C]'>Coder</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Shit Person;target=\ref[C]'>Shit Person</A><BR>
							"}
				if (src.level >= LEVEL_SHITGUY)
					dat += "<A href='?src=\ref[src];action=chgadlvl;type=Primary Administrator;target=\ref[C]'>PA</A><BR>"
				if (src.level >= LEVEL_PA)
					dat += {"
							<A href='?src=\ref[src];action=chgadlvl;type=Administrator;target=\ref[C]'>A</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Secondary Administrator;target=\ref[C]'>SA</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Moderator;target=\ref[C]'>M</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Ayn Rand's Armpit;target=\ref[C]'>Ayn Rand's Armpit</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Goat Fart;target=\ref[C]'>Goat Fart</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Remove;target=\ref[C]'>Remove Admin</A><BR>
							"}
				usr << browse(dat, "window=prom_demot;size=480x300")
			else
				alert("You need to be at least a Primary Adminstrator to promote or demote.")

		if ("chgadlvl")
			if (src.level >= LEVEL_PA)
				var/rank = href_list["type"]
				var/client/C = locate(href_list["target"])
				if (!rank || !C) return
				if (C == usr.client)
					alert("You can't change your own rank!")
					return
				if (rank == "Remove")
					C.clear_admin_verbs()
					C.update_admins(null)
					logTheThing("admin", usr, C, "has removed %target%'s adminship")
					logTheThing("diary", usr, null, "has removed [C]'s adminship", "admin")
					message_admins("[key_name(usr)] has removed [C]'s adminship")

					var/ircmsg[] = new()
					ircmsg["key"] = usr.client.key
					ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
					ircmsg["msg"] = "has removed [C]'s adminship"
					ircbot.export("admin", ircmsg)

					admins.Remove(C.ckey)
					onlineAdmins.Remove(C)
				else
					C.clear_admin_verbs()
					C.update_admins(rank)
					logTheThing("admin", usr, C, "has made %target% a [rank]")
					logTheThing("diary", usr, null, "has made [C] a [rank]", "admin")
					message_admins("[key_name(usr)] has made [C] a [rank]")

					var/ircmsg[] = new()
					ircmsg["key"] = usr.client.key
					ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
					ircmsg["msg"] = "has made [C] a [rank]"
					ircbot.export("admin", ircmsg)

					admins[C.ckey] = rank
					onlineAdmins.Add(C)
			else
				alert("You need to be at least a Primary Adminstrator to promote or demote.")

		if ("object_list")
			if (src.level >= LEVEL_PA)
				if (config.allow_admin_spawning && (src.state == 2 || src.level >= LEVEL_PA))
					var/atom/loc = usr.loc

					var/type = href_list["type"]
					var/dirty_paths
					if (istext(type))
						dirty_paths = list(type)
					else if (islist(type))
						dirty_paths = type

					var/paths = list()
					var/removed_paths = list()
					for (var/dirty_path in dirty_paths)
						var/path = text2path(dirty_path)
						if (!path)
							removed_paths += dirty_path
						else if (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
							removed_paths += dirty_path
						else if (dirty_path in do_not_spawn && src.level < LEVEL_PA)
							removed_paths += dirty_path
						else if (ispath(path, /mob) && src.level < LEVEL_PA)
							removed_paths += dirty_path
						else
							paths += path
						sleep(-1)

					if (!paths)
						return
					else if (length(paths) > 5)
						alert("Select five or less object types only, you colossal ass!")
						return
					else if (length(removed_paths))
						alert("Spawning of these objects is blocked:\n" + jointext(removed_paths, "\n"))
						return

					var/list/offset = splittext(href_list["offset"],",")
					var/number = dd_range(1, 100, text2num(href_list["object_count"]))
					var/X = offset.len > 0 ? text2num(offset[1]) : 0
					var/Y = offset.len > 1 ? text2num(offset[2]) : 0
					var/Z = offset.len > 2 ? text2num(offset[3]) : 0
					var/direction = text2num(href_list["one_direction"]) // forgive me

					for (var/i = 1 to number)
						switch (href_list["offset_type"])
							if ("absolute")
								for (var/path in paths)
									var/atom/thing = new path(locate(0 + X,0 + Y,0 + Z))
									thing.dir = direction ? direction : SOUTH
									sleep(-1)

							if ("relative")
								if (loc)
									for (var/path in paths)
										var/atom/thing = new path(locate(loc.x + X,loc.y + Y,loc.z + Z))
										thing.dir = direction ? direction : SOUTH
										sleep(-1)
								else
									return

						sleep(-1)

					if (number == 1)
						logTheThing("admin", usr, null, "created a [english_list(paths)]")
						logTheThing("diary", usr, null, "created a [english_list(paths)]", "admin")
						for(var/path in paths)
							if(ispath(path, /mob))
								message_admins("[key_name(usr)] created a [english_list(paths, 1)]")
								break
							sleep(-1)
					else
						logTheThing("admin", usr, null, "created [number]ea [english_list(paths)]")
						logTheThing("diary", usr, null, "created [number]ea [english_list(paths)]", "admin")
						for(var/path in paths)
							if(ispath(path, /mob))
								message_admins("[key_name(usr)] created [number]ea [english_list(paths, 1)]")
								break
							sleep(-1)
					return
				else
					alert("Object spawning is currently disabled for anyone below the rank of Administrator.")
					return
			else
				alert("You need to be at least an Adminstrator to spawn objects.")

		if ("polymorph")
			if (src.level >= LEVEL_SHITGUY)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_polymorph(M)
			else
				alert("You need to be at least a Shit Person to polymorph a dude.")

		if ("modcolor")
			if (src.level >= LEVEL_SHITGUY)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				mod_color(M)
			else
				alert("You need to be at least a Shit Person to modify an icon.")

		if("giveantagtoken") //Gives player a token they can redeem to guarantee an antagonist role
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/removedall
				if (!M)
					return
				if (M.ckey && M.ckey == usr.ckey)
					alert(usr, "You cannot modify your own antag tokens.")
					return
				M.client.load_antag_tokens()
				var/tokens = input(usr, "Current Tokens: [M.client.antag_tokens]","Add/Remove Antag Tokens?") as null|num
				if (!tokens)
					return
				var/newtokens = M.client.antag_tokens + tokens
				if (newtokens <= 0)
					newtokens = 0
					logTheThing("admin", usr, M, "Removed all antag tokens from %target%")
					logTheThing("diary", usr, M, "Removed all antag tokens from %target%", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] removed all antag tokens from [key_name(M)]</span>")
					removedall = 1

				M.client.antag_tokens = newtokens
				M.client.set_antag_tokens()
				if (!removedall)
					logTheThing("admin", usr, M, "[(tokens >= 1) ? "added" : "removed"] [abs(tokens)] Antag tokens [(tokens >= 1) ? "to" : "from"] %target%.")
					logTheThing("diary", usr, M, "[(tokens >= 1) ? "added" : "removed"] [abs(tokens)]  Antag tokens [(tokens >= 1) ? "to" : "from"] %target%.", "admin")
					message_admins("<span style=\"color:blue\">[key_name(usr)] [(tokens >= 1) ? "added" : "removed"] [abs(tokens)]  Antag tokens [(tokens >= 1) ? "to" : "from"] [key_name(M)].</span>")

		if ("viewsave")
			if (src.level >= LEVEL_SHITGUY)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.view_save_data(M)
			else
				alert("You need to be at least a Shit Person to view save data.")

		if ("editvars")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_modify_object_variables(M)
			else
				alert("You need to be at least a Primary Administrator to edit variables.")

		if ("viewvars")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.debug_variables(M)
			else
				alert("You need to be at least a Primary Administrator to view variables.")

		if ("adminfollow")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.admin_follow_mobject(M)

		if ("adminplayeropts")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.holder.playeropt(M)

		if ("secretsfun")
			if (src.level >= LEVEL_SA)
				switch(href_list["type"])
					if("sec_clothes")
						for(var/obj/item/clothing/under/O in world)
							qdel(O)
							sleep(-1)
					if("sec_all_clothes")
						for(var/obj/item/clothing/O in world)
							qdel(O)
							sleep(-1)
					if("sec_classic1")
						for(var/obj/item/clothing/suit/fire/O in world)
							qdel(O)
							sleep(-1)
						for(var/obj/grille/O in world)
							qdel(O)
							sleep(-1)
						for(var/obj/machinery/vehicle/pod/O in machines)
							for(var/atom/movable/A in O)
								A.set_loc(O.loc)
							qdel(O)

					if("transform_one")
						var/who = input("Transform who?","Transform") as null|mob in world
						if (!who)
							return
						if (!istype(who,/mob/living/carbon/human/))
							alert("This secret can only be used on human mobs.")
							return
						var/mob/living/carbon/human/H = who
						var/which = input("Transform them into what?","Transform") as null|anything in list("Monkey","Cyborg","Lizardman","Squidman","Martian","Skeleton","Flashman")
						if (!which)
							return
						switch(which)
							if("Monkey") H.monkeyize()
							if("Cyborg") H.Robotize_MK2()
							if("Lizardman")
								H.set_mutantrace(/datum/mutantrace/lizard)
							if("Squidman")
								H.set_mutantrace(/datum/mutantrace/ithillid)
							if("Martian")
								H.set_mutantrace(/datum/mutantrace/martian)
							if("Skeleton")
								H.set_mutantrace(/datum/mutantrace/skeleton)
							if("Flashman")
								H.set_mutantrace(/datum/mutantrace/flashy)
						message_admins("<span style=\"color:blue\">[key_name(usr)] transformed [H.real_name] into a [which].</span>")
						logTheThing("admin", usr, null, "transformed [H.real_name] into a [which].")
						logTheThing("diary", usr, null, "transformed [H.real_name] into a [which].", "admin")

					if("transform_all")
						var/which = input("Transform everyone into what?","Transform") as null|anything in list("Monkey","Cyborg","Lizardman","Squidman","Martian","Skeleton","Flashman")
						for(var/mob/living/carbon/human/H in mobs)
							switch(which)
								if("Monkey") H.monkeyize()
								if("Cyborg") H.Robotize_MK2()
								if("Lizardman")
									H.set_mutantrace(/datum/mutantrace/lizard)
								if("Squidman")
									H.set_mutantrace(/datum/mutantrace/ithillid)
								if("Martian")
									H.set_mutantrace(/datum/mutantrace/martian)
								if("Skeleton")
									H.set_mutantrace(/datum/mutantrace/skeleton)
								if("Flashman")
									H.set_mutantrace(/datum/mutantrace/flashy)
							sleep(-1)
						message_admins("<span style=\"color:blue\">[key_name(usr)] transformed everyone into a [which].</span>")
						logTheThing("admin", usr, null, "transformed everyone into a [which].")
						logTheThing("diary", usr, null, "transformed everyone into a [which].", "admin")
					if("prisonwarp")
						if(!ticker)
							alert("The game hasn't started yet!", null, null, null, null, null)
							return
						message_admins("<span style=\"color:blue\">[key_name(usr)] teleported all players to the prison zone.</span>")
						logTheThing("admin", usr, null, "teleported all players to the prison zone.")
						logTheThing("diary", usr, null, "teleported all players to the prison zone.", "admin")
						for(var/mob/living/carbon/human/H in mobs)
							var/turf/loc = find_loc(H)
							var/security = 0
							if(loc.z > 1 || prisonwarped.Find(H))
								//don't warp them if they aren't ready or are already there
								continue
							H.paralysis += 5
							if(H.wear_id)
								for(var/A in H.wear_id:access)
									if(A == access_security)
										security++
							if(!security)
								//teleport person to cell
								H.set_loc(pick(prisonwarp))
							else
								//teleport security person
								H.set_loc(pick(prisonsecuritywarp))
							prisonwarped += H
							sleep(-1)
					if("traitor_all")
						if (src.level >= LEVEL_SA)
							if(!ticker)
								alert("The game hasn't started yet!")
								return

							var/which_traitor = input("What kind of traitor?","Everyone's a Traitor") as null|anything in list("Traitor","Wizard","Changeling","Werewolf","Vampire","Predator","Wrestler","Grinch","Omnitraitor")
							if(!which_traitor)
								return
							var/hardmode = null
							if (which_traitor == "Traitor")
								if (alert("Hard Mode?","Everyone's a Traitor","Yes","No") == "Yes")
									hardmode = "hardmode"
							var/custom_objective = input("What should the objective be?","Everyone's a Traitor") as null|text
							if (!custom_objective)
								return
							var/escape_objective = input("Which escaping objective?") as null|anything in typesof(/datum/objective/escape/) + "None"
							if (!escape_objective)
								return

							if (escape_objective == "None")
								escape_objective = null

							for(var/mob/living/carbon/human/H in mobs)
								if(H.stat == 2 || !(H.client)) continue
								if(checktraitor(H)) continue
								evilize(H, which_traitor, hardmode, custom_objective, escape_objective)

							message_admins("<span style=\"color:blue\">[key_name(usr)] made everyone a[hardmode ? " hard-mode" : ""] [which_traitor]. Objective is [custom_objective]</span>")
							logTheThing("admin", usr, null, "made everyone a[hardmode ? " hard-mode" : ""] [which_traitor]. Objective is [custom_objective]")
							logTheThing("diary", usr, null, "made everyone a[hardmode ? " hard-mode" : ""] [which_traitor]. Objective is [custom_objective]", "admin")
						else
							alert("You're not of a high enough rank to do this")
					if("flicklights")
						while(!usr.stat)
							//knock yourself out to stop the ghosts
							for(var/mob/M in mobs)
								if(M.client && M.stat != 2 && prob(25))
									var/area/AffectedArea = get_area(M)
									if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
										AffectedArea.power_light = 0
										AffectedArea.power_change()
										spawn(rand(55,185))
											AffectedArea.power_light = 1
											AffectedArea.power_change()
										var/Message = rand(1,4)
										switch(Message)
											if(1)
												M.show_message(text("<span style=\"color:blue\">You shudder as if cold...</span>"), 1)
											if(2)
												M.show_message(text("<span style=\"color:blue\">You feel something gliding across your back...</span>"), 1)
											if(3)
												M.show_message(text("<span style=\"color:blue\">Your eyes twitch, you feel like something you can't see is here...</span>"), 1)
											if(4)
												M.show_message(text("<span style=\"color:blue\">You notice something moving out of the corner of your eye, but nothing is there...</span>"), 1)
										for(var/obj/W in orange(5,M))
											if(prob(25) && !W.anchored)
												step_rand(W)
							sleep(rand(100,1000))
						for(var/mob/M in mobs)
							if(M.client && M.stat != 2)
								M.show_message(text("<span style=\"color:blue\">The chilling wind suddenly stops...</span>"), 1)
							sleep(-1)
					if("retardify")
						if (src.level >= LEVEL_SHITGUY)
							if (alert("Do you wish to give everyone brain damage?", "Confirmation", "Yes", "No") != "Yes")
								return
							for (var/mob/living/carbon/human/H in mobs)
								if (H.get_brain_damage() < 60)
									if (H.client)
										H.show_text("<B>You suddenly feel stupid.</B>","red")
									H.take_brain_damage(min(60 - H.get_brain_damage(), 60)) // 100+ brain damage is lethal.
									sleep(-1)
								else
									continue
							message_admins("[key_name(usr)] gave everybody severe brain damage.")
							logTheThing("admin", usr, null, "gave everybody severe brain damage.")
							logTheThing("diary", usr, null, "gave everybody severe brain damage.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return
					// FUN SECRETS CODE
					if ("bioeffect_help")
						var/be_string = "To add or remove multiple bioeffects enter multiple IDs separated by semicolons.<br><br><b>All Bio Effect IDs</b><hr>"
						for(var/S in bioEffectList)
							be_string += "[S]<br>"
						usr << browse(be_string,"window=bioeffect_help;size=300x600")

					if ("reagent_help")
						var/r_string = "To add or remove multiple reagents enter multiple IDs separated by semicolons.<br><br><b>All Reagent IDs</b><hr>"
						for(var/R in reagents_cache)
							r_string += "[R]<br>"
						usr << browse(r_string,"window=reagent_help;size=300x600")

					if ("add_bioeffect_one","remove_bioeffect_one")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_bioeffect_one"
							var/who = input("Which player?","[adding ? "Give" : "Remove"] Bioeffects") as null|mob in world

							if (!who)
								return

							if (!istype(who,/mob/living/carbon/human/))
								alert("You may only use this secret on human mobs.")
								return

							var/mob/living/carbon/human/X = who
							var/pick = input("Which effect(s)?","[adding ? "Give" : "Remove"] Bioeffects") as null|text

							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (picklist && picklist.len >= 1)
								var/string_version

								for(pick in picklist)
									if (adding)
										X.bioHolder.AddEffect(pick)
									else
										X.bioHolder.RemoveEffect(pick)

									if (string_version)
										string_version = "[string_version], \"[pick]\""
									else
										string_version = "\"[pick]\""

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(X)].")
								logTheThing("admin", usr, null, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(X)].")
								logTheThing("diary", usr, null, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(X)].", "admin")
						else
							alert("You must be at least a Primary Administrator to bioeffect players.")
							return

					if ("add_reagent_one","remove_reagent_one")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_reagent_one"
							var/who = input("Which player?","[adding ? "Add" : "Remove"] Reagents") as null|mob in world

							if (!who)
								return

							if (!istype(who,/mob/living/carbon/human/))
								alert("You may only use this secret on human mobs.")
								return

							var/mob/living/carbon/human/X = who
							var/pick = input("Which reagent(s)?","[adding ? "Add" : "Remove"] Reagents") as null|text

							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (picklist && picklist.len >= 1)
								var/string_version

								for(pick in picklist)
									var/amt = input("How much of [pick]?","[adding ? "Add" : "Remove"] Reagent") as null|num
									if(!amt || amt < 0)
										return

									if (adding)
										if (X.reagents)
											X.reagents.add_reagent(pick,amt)
									else
										if (X.reagents)
											X.reagents.remove_reagent(pick,amt)

									if (string_version)
										string_version = "[string_version], [amt] \"[pick]\""
									else
										string_version = "[amt] \"[pick]\""

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(X)].")
								logTheThing("admin", usr, null, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(X)].")
								logTheThing("diary", usr, null, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(X)].", "admin")
						else
							alert("You must be at least a Primary Administrator to affect player reagents.")
							return

					if ("add_bioeffect_all","remove_bioeffect_all")
						if (src.level >= LEVEL_PA)
							var/adding = href_list["type"] == "add_bioeffect_all"
							var/pick = input("Which effect(s)?","[adding ? "Give" : "Remove"] Bioeffects [adding ? "to" : "from"] Everyone") as null|text
							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (picklist && picklist.len >= 1)
								var/string_version
								for(pick in picklist)
									if (string_version)
										string_version = "[string_version], \"[pick]\""
									else
										string_version = "\"[pick]\""

								spawn(0)
									for(var/mob/living/carbon/X in mobs)
										for(pick in picklist)
											if (adding)
												X.bioHolder.AddEffect(pick)
											else
												X.bioHolder.RemoveEffect(pick)
										sleep(1)

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.")
								logTheThing("admin", usr, null, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.")
								logTheThing("diary", usr, null, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.", "admin")
						else
							alert("You must be at least a Primary Administrator to bioeffect players.")
							return

					if ("add_reagent_all","remove_reagent_all")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_reagent_all"
							var/pick = input("Which reagent(s)?","[adding ? "Add" : "Remove"] Reagents [adding ? "to" : "from"] Everyone") as null|text
							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (picklist && picklist.len >= 1)
								var/string_version

								for(pick in picklist)
									var/amt = input("How much of [pick]?","[adding ? "Add" : "Remove"] Reagent") as null|num
									picklist[pick] = amt

									if (string_version)
										string_version = "[string_version], [amt] \"[pick]\""
									else
										string_version = "[amt] \"[pick]\""

								spawn(0)
									for(var/mob/living/carbon/X in mobs)
										for(pick in picklist)
											var/amt = picklist[pick]
											if(!amt)
												continue
											if (adding)
												if (X.reagents)
													X.reagents.add_reagent(pick,amt)
											else
												if (X.reagents)
													X.reagents.remove_reagent(pick,amt)
										sleep(1)

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] everyone.")
								logTheThing("admin", usr, null, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] everyone.")
								logTheThing("diary", usr, null, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] everyone.", "admin")

						else
							alert("You must be at least a Primary Administrator to affect player reagents.")
							return

					if ("woodstation")
						if (src.level >= LEVEL_PA)
							message_admins("[key_name(usr)] began replacing all Z1 floors and walls with wooden ones.")
							for (var/turf/simulated/wall/W in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 floors and walls with wooden ones was terminated due to the atom emerygency stop!")
									return
								if (W.z != 1)
									break
								if (W.icon_state != "wooden")
									W.icon_state = "wooden"
								sleep(-1)
							for (var/turf/simulated/floor/F in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 floors and walls with wooden ones was terminated due to the atom emerygency stop!")
									return
								if (F.z != 1)
									break
								if (istype(F, /turf/simulated/floor/carpet))
									continue
								if (F.icon_state != "wooden")
									F.icon_state = "wooden"
								sleep(-1)
							message_admins("[key_name(usr)] replaced all Z1 floors and walls with wooden ones.")
							logTheThing("admin", usr, null, "replaced z1 floors and walls with wooden doors.")
							logTheThing("diary", usr, null, "replaced z1 floors and walls with wooden doors.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if ("yeolde")
						if (src.level >= LEVEL_PA)
							message_admins("[key_name(usr)] began replacing all Z1 airlocks with wooden doors.")
							for (var/obj/machinery/door/D in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 airlocks with wooden doors was terminated due to the atom emerygency stop!")
									return
								if (D.z != 1)
									break
								if (istype(D, /obj/machinery/door/poddoor/) || istype(D, /obj/machinery/door/firedoor/) || istype(D, /obj/machinery/door/window/))
									continue
								new /obj/machinery/door/unpowered/wood(get_turf(D))
								qdel(D)
								sleep(-1)
							message_admins("[key_name(usr)] replaced all Z1 airlocks with wooden doors.")
							logTheThing("admin", usr, null, "replaced z1 airlocks with wooden doors.")
							logTheThing("diary", usr, null, "replaced z1 airlocks with wooden doors.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("fakeguns")
						if (src.level >= LEVEL_SHITGUY)
							for(var/obj/item/W in world)
								if(istype(W, /obj/item/clothing) || istype(W, /obj/item/card/id) || istype(W, /obj/item/disk) || istype(W, /obj/item/tank))
									continue
								W.icon = 'icons/obj/gun.dmi'
								W.icon_state = "revolver"
								W.item_state = "gun"
								sleep(-1)
							message_admins("[key_name(usr)] made every item look like a gun")
							logTheThing("admin", usr, null, "used Fake Gun secret.")
							logTheThing("diary", usr, null, "used Fake Gun secret.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("flipstation")
						var/direction = input("Which way?", "Which direction?", "Normal") in list("Normal", "Rotated CW", "Rotated CCW", "Upside down")
						var/setdir = NORTH
						switch (direction)
							if ("Rotated CW")
								setdir = WEST
							if ("Rotated CCW")
								setdir = EAST
							if ("Upside down")
								setdir = SOUTH
						if (src.level >= LEVEL_SHITGUY)
							for(var/mob/M in mobs)
								if(M.client)
									M.client.dir = setdir
								sleep(-1)
							message_admins("[key_name(usr)] set station direction to [direction].")
							logTheThing("admin", src, null, "set station direction to [direction].")
							logTheThing("diary", src, null, "set station direction to [direction]", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("raiseundead")
						if (src.level >= LEVEL_SHITGUY)
							for(var/mob/living/carbon/human/H in mobs) //Only humans can be zombies!
								if(H.stat != 2) //Not dead!
									continue
								if(istype(H.mutantrace, /datum/mutantrace/zombie))
									continue //Already a zombie!

								qdel(H.mutantrace)
								H.set_mutantrace(/datum/mutantrace/zombie)
								H.stat = 0 //Set stat back to zero so we can call death()
								H.death()//Calling death() again means that the zombies will rise after ~20 seconds.
								sleep(-1)

							message_admins("[key_name(usr)] has brought back all dead humans as zombies.")
							logTheThing("admin", usr, null, "brought back all dead humans as zombies.")
							logTheThing("diary", usr, null, "brought back all dead humans as zombies", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("forcerandomnames")
						if (src.level >= LEVEL_PA)
							if(ticker.current_state != GAME_STATE_PREGAME)
								alert("You can only only trigger this before the game starts, sorry pal!")
								return

							force_random_names = 1

							for(var/client/C)
								if (!C.preferences)
									continue
								C.preferences.be_random_name = 1

							message_admins("[key_name(usr)] has set all players to use random names this round.")
							logTheThing("admin", usr, null, "set all players to use random names.")
							logTheThing("diary", usr, null, "set all players to use random names.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("forcerandomlooks")
						if (src.level >= LEVEL_PA)
							if(ticker.current_state != GAME_STATE_PREGAME)
								alert("You can only only trigger this before the game starts, sorry pal!")
								return

							force_random_looks = 1

							for(var/client/C)
								if (!C.preferences)
									continue
								C.preferences.be_random_look = 1

							message_admins("[key_name(usr)] has set all players to use random appearances this round.")
							logTheThing("admin", usr, null, "set all players to use random appearances.")
							logTheThing("diary", usr, null, "set all players to use random appearances.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("sawarms")
						if (src.level >= LEVEL_SHITGUY)
							for (var/mob/living/carbon/human/M in world)
								if (!ismonkey(M))
									for (var/obj/item/parts/human_parts/arm/P in M)
										P.sever()
										var/obj/item/parts/human_parts/arm/sawarm = null

										if (P.slot == "l_arm")
											sawarm = new /obj/item/parts/human_parts/arm/left/item(M)
											M.limbs.l_arm = sawarm
										else
											sawarm = new /obj/item/parts/human_parts/arm/right/item(M)
											M.limbs.r_arm = sawarm
										if (!sawarm) return

										sawarm.holder = M
										sawarm.remove_stage = 0
										sawarm:set_item(new /obj/item/saw/elimbinator())


									playsound(M, "sound/machines/chainsaw_red.ogg", 60, 1)
									M.update_body()
							message_admins("[key_name(usr)] has given everyone new arms.")
							logTheThing("admin", usr, null, "used the Saw Arms secret.")
							logTheThing("diary", usr, null, "used the Saw Arms secret.", "admin")

						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("emag_all_things")
						if (src.level >= LEVEL_SHITGUY)
							if (alert("Do you really want to emag everything?","Bad Idea", "Yes", "No") == "Yes")
								message_admins("[key_name(usr)] has started emagging everything!")
								logTheThing("admin", usr, null, "used the Emag Everything secret.")
								logTheThing("diary", usr, null, "used the Emag Everything secret.", "admin")
								//DO IT!
								for(var/atom/A as mob|obj in world)
									if(A)
										A.emag_act(null,null)
								message_admins("[key_name(usr)] has emagged everything!")
							else
								return

						else
							alert("You need to be at least a shit person to emag everything")
							return

					if ("noir")
						if(src.level >= LEVEL_SHITGUY)
							if (noir)
								alert("Noir is already engaged.")
								return
							if (alert("Are you sure you should noir?", "PARENTAL CONTROL", "Sure thing!", "Not really.") == "Sure thing!")
								noir = 1
								for (var/mob/M in world)
									if (M.client)
										animate_fade_grayscale(M.client, 50)
								message_admins("[key_name(usr)] placed the station in noir mode.")
								logTheThing("admin", usr, null, "used the Noir secret")
								logTheThing("diary", usr, null, "used the Noir secret", "admin")

					if("the_great_switcharoo")
						if(src.level >= LEVEL_SHITGUY) //Will be SG when tested
							if (alert("Do you really wanna do the great switcharoo?", "Awoo, awoo", "Sure thing!", "Not really.") == "Sure thing!")

								var/list/mob/living/people_to_swap = list()

								for(var/mob/living/L in world) //Build the swaplist
									if(L && L.key && L.mind && L.stat != 2 && (ishuman(L) || issilicon(L)))
										people_to_swap += L

								if(people_to_swap.len > 1) //Jenny Antonsson switches bodies with herself! #wow #whoa
									message_admins("[key_name(usr)] did The Great Switcharoo")
									logTheThing("admin", usr, null, "used The Great Switcharoo secret")
									logTheThing("diary", usr, null, "used The Great Switcharoo secret", "admin")

									var/mob/A = pick(people_to_swap)
									do //More random
										people_to_swap -= A
										var/mob/B = pick(people_to_swap)
										if(A && A.mind && B)
											A.mind.swap_with(B)
										A = B
									while(people_to_swap.len > 0)

							else
								return
						else
							alert("You are not a shit enough guy to switcharoo, bub.")

					else
				if (usr) logTheThing("admin", usr, null, "used secret [href_list["secretsfun"]]")
				logTheThing("diary", usr, null, "used secret [href_list["secretsfun"]]", "admin")
			else
				alert("You need to be at least an Adminstrator to use the secrets panel.")
				return

		if ("secretsdebug")
			if (src.level >= LEVEL_CODER)
				switch(href_list["type"])
					if("budget")
						src.owner:debug_variables(wagesystem)
					if("market")
						src.owner:debug_variables(shippingmarket)
					if("genetics")
						src.owner:debug_variables(genResearch)
					if("jobs")
						src.owner:debug_variables(job_controls)
					if("hydro")
						src.owner:debug_variables(hydro_controls)
					if("manuf")
						src.owner:debug_variables(manuf_controls)
					if("radio")
						src.owner:debug_variables(radio_controller)
					if("randevent")
						src.owner:debug_variables(random_events)
					if("disease")
						src.owner:debug_variables(disease_controls)
					if("mechanic")
						src.owner:debug_variables(mechanic_controls)
					if("artifact")
						src.owner:debug_variables(artifact_controls)
					if("gauntlet")
						src.owner:debug_variables(gauntlet_controller)
					if("colosseum")
						src.owner:debug_variables(colosseum_controller)
					if("stock")
						src.owner:debug_variables(stockExchange)
					if("emshuttle")
						src.owner:debug_variables(emergency_shuttle)
					if("overlays")
						overlaytest()
					if("overlaysrem")
						removerlays()
			else
				alert("You need to be at least a Coder to use debugging secrets.")

		if ("secretsadmin")
			if (src.level >= LEVEL_MOD)
				var/ok = 0

				switch(href_list["type"])
	/*
					if("clear_bombs")
						for(var/obj/item/assembly/radio_bomb/O in world)
							qdel(O)
						for(var/obj/item/assembly/proximity_bomb/O in world)
							qdel(O)
						for(var/obj/item/assembly/time_bomb/O in world)
							qdel(O)
						ok = 1
	*/

					if("check_antagonist")
						if (ticker && ticker.mode && ticker.current_state >= GAME_STATE_PLAYING)
							var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
							dat += "Current Game Mode: <B>[ticker.mode.name]</B><BR>"
							dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"

							if (istype(ticker.mode, /datum/game_mode/nuclear))
								var/datum/game_mode/nuclear/NN = ticker.mode
								dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
								for(var/datum/mind/N in NN.syndicates)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"

								// This basic bit of info was missing, even though you could look up the
								// location of the old auth disk here in the past (Convair880).
								dat += "</table><br><table><tr><td><b>Nuclear bomb:</b></td></tr>"
								if (NN.the_bomb && istype(NN.the_bomb, /obj/machinery/nuclearbomb/))
									var/turf/T = get_turf(NN.the_bomb)
									dat += "<tr><td>Location:"
									if (T && istype(T, /turf))
										dat += " <a href='?src=\ref[src];action=jumptocoords;target=[T.x],[T.y],[T.z]'>[T.x],[T.y],[T.z]</a> ([get_area(NN.the_bomb)])</tr></td>"
									else
										dat += " Found (unknown location)</tr></td>"
								else
									dat += "<tr><td>N/A (destroyed or not associated with objective)</tr></td>"

								dat += "<tr><td>Target area:"
								if (!isnull(NN.target_location_type))
									dat += " [NN.target_location_name]</tr></td>"
								else
									dat += " Unknown or not assigned</tr></td>"

								dat += "</table>"

							else if (istype(ticker.mode, /datum/game_mode/revolution))
								dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
								for(var/datum/mind/N in ticker.mode:head_revolutionaries)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"
								for(var/datum/mind/N in ticker.mode:revolutionaries)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"
								dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
								for(var/datum/mind/N in ticker.mode:get_living_heads())
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									var/turf/mob_loc = get_turf_loc(M)
									dat += "<td>[mob_loc.loc]</td></tr>"
								dat += "</table>"

							else if (istype(ticker.mode, /datum/game_mode/spy))
								if(ticker.mode:leaders.len > 0)
									dat += "<br><table cellspacing=5><tr><td><B>Infiltrators:</B></td><td></td><tr>"
									for(var/datum/mind/leader in ticker.mode:leaders)
										var/mob/M = leader.current
										if(!M) continue
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(M)]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
										dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
										dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"

									dat += "</table>"
								else
									dat += "There are no infiltrators."

								if(ticker.mode:spies.len > 0)
									dat += "<br><table cellspacing=5><tr><td><B>Brainwashed Followers:</B></td><td></td><tr>"
									for(var/datum/mind/spy in ticker.mode:spies)
										var/mob/M = spy.current
										if(!M) continue
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
										dat += "<td>Obeys: "
										var/datum/mind/obeycheck = ticker.mode:spies[spy]
										if (istype(obeycheck) && obeycheck.current)
											dat += "[obeycheck.current.ckey]"
										else
											dat += "Nobody!"
										dat += "</td><td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"

									dat += "</table>"
								else
									dat += "There are no brainwashed followers."

							else if (istype(ticker.mode, /datum/game_mode/gang))
								if (ticker.mode:leaders.len > 0)
									for(var/datum/mind/leader in ticker.mode:leaders)
										var/mob/M = leader.current
										var/datum/gang/gang = leader.gang
										dat += "<br><table cellspacing=5><tr><td>([format_frequency(gang.gang_frequency)]) <B>[gang.gang_name]:</B></td><td></td><tr>"
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(M)]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
										dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
										dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
										for(var/mob/member in gang.members)
											dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(member)]</a>[member.client ? "" : " <i>(logged out)</i>"][member.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
											dat += "<td><a href='?action=priv_msg&target=[member.ckey]'>PM</A></td>"
											dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[member]'>Show Objective</A></td></tr>"
									dat += "</table>"
								else
									dat += "There are no gangs."

							if (ticker.mode.traitors.len > 0)
								dat += "<br><table cellspacing=5><tr><td><B>Traitors</B></td><td></td><td></td></tr>"
								for (var/datum/mind/traitor in ticker.mode.traitors)
									var/mob/M = traitor.current
									if (!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
								dat += "</table>"

							if(ticker.mode.Agimmicks.len > 0)
								dat += "<br><table cellspacing=5><tr><td><B>Misc Foes</B></td><td></td><td></td></tr>"
								for(var/datum/mind/gimmick in ticker.mode.Agimmicks)
									var/mob/M = gimmick.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
								dat += "</table>"

							if(miscreants.len > 0)
								dat += "<br><table cellspacing=5><tr><td><B>Miscreants</B></td><td></td><td></td></tr>"
								for(var/datum/mind/miscreant in miscreants)
									var/mob/M = miscreant.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
								dat += "</table>"

							dat += "</body></html>"
							usr << browse(dat, "window=roundstatus;size=400x500")
						else
							alert("The game hasn't started yet!")
					if("shuttle_panel")
						if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
							var/dat = "<html><head><title>Shuttle Controls</title></head><body><h1><B>Shuttle Controls</B></h1>"
							dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"
							dat += "<B>Emergency shuttle:</B><BR>"
							if (!emergency_shuttle.online)
								dat += "<a href='?src=\ref[src];action=call_shuttle&type=1'>Call Shuttle</a><br>"
							else
								var/timeleft = emergency_shuttle.timeleft()
								switch(emergency_shuttle.location)
									if(0)
										dat += "ETA: <a href='?src=\ref[src];action=edit_shuttle_time'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
										dat += "<a href='?src=\ref[src];action=call_shuttle&type=2'>Send Back</a><br>"
									if(1)
										dat += "ETA: <a href='?src=\ref[src];action=edit_shuttle_time'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
							dat += "</body></html>"
							usr << browse(dat, "window=roundstatus;size=400x500")
					if("manifest")
						var/dat = "<B>Showing Crew Manifest.</B><HR>"
						dat += "<table cellspacing=5><tr><th>Name</th><th>Original Position</th><th>Position</th></tr>"
						for(var/mob/living/carbon/human/H in mobs)
							if(H.ckey)
								dat += "<tr><td>[H.name]</td><td>[(H.mind ? H.mind.assigned_role : "Unknown Position")]</td><td>[(istype(H.wear_id, /obj/item/card/id) || istype(H.wear_id, /obj/item/device/pda2)) ? "[H.wear_id:assignment]" : "Unknown Position"]</td></tr>"
							sleep(-1)
						dat += "</table>"
						usr << browse(dat, "window=manifest;size=440x410")
					if("jobcaps")
						job_controls.job_config()
					if("randomevents")
						random_events.event_config()
					if("pathology")
						pathogen_controller.cdc_main(src)
					if("motives")
						simsController.showControls(usr)
					if("artifacts")
						artifact_controls.config()
					if("unelectrify_all")
						for(var/obj/machinery/door/airlock/D)
							D.secondsElectrified = 0
							sleep(-1)
						message_admins("Admin [key_name(usr)] de-electrified all airlocks.")
						logTheThing("admin", usr, null, "de-electrified all airlocks.")
						logTheThing("diary", usr, null, "de-electrified all airlocks.", "admin")
					if("DNA")
						var/dat = "<B>Showing DNA from blood.</B><HR>"
						dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
						for(var/mob/living/carbon/human/H in mobs)
							if(H.ckey)
								dat += "<tr><td>[H]</td><td>[H.bioHolder.Uid]</td><td>[H.bioHolder.bloodType]</td></tr>"
							sleep(-1)
						dat += "</table>"
						usr << browse(dat, "window=DNA;size=440x410")
					if("fingerprints")
						var/dat = "<B>Showing Fingerprints.</B><HR>"
						dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
						for(var/mob/living/carbon/human/H in mobs)
							if(H.ckey)
								if(H.bioHolder.Uid)
									dat += "<tr><td>[H]</td><td>[md5(H.bioHolder.Uid)]</td></tr>"
								else if(!H.bioHolder.Uid)
									dat += "<tr><td>[H]</td><td>H.bioHolder.Uid = null</td></tr>"
							sleep(-1)
						dat += "</table>"
						usr << browse(dat, "window=fingerprints;size=440x410")
					else
				if (usr)
					logTheThing("admin", usr, null, "used secret [href_list["secretsadmin"]]")
					logTheThing("diary", usr, null, "used secret [href_list["secretsadmin"]]", "admin")
					if (ok)
						boutput(world, text("<B>A secret has been activated by []!</B>", usr.key))
				return
			else
				alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)

		if ("view_logs")
			if (src.level >= LEVEL_MOD)
				var/gettxt
				var/logType = href_list["type"]
				var/preSearch
				if (href_list["presearch"])
					preSearch = href_list["presearch"]
				var/dat = "<table>"
				if (findtext(logType, "string") && !preSearch)
					gettxt = input("What are you searching for?","Log by String") as null|text
					if (!gettxt) return
				else if (preSearch)
					gettxt = preSearch

				logType = replacetext(logType, "_string", "")
				logType = replacetext(logType, "_log", "")
				var/prettyLogName = replacetext(logType, "_", " ")
				if (prettyLogName == "alls") prettyLogName = "all"
				var/foundCount = 0
				if (logType == "alls")
					for (var/log in logs)
						var/list/logList = logs[log]
						prettyLogName = replacetext(log, "_", " ")
						var/searchData
						var/found
						for (var/l in logList)
							if (findtext(l, gettxt, 1, null))
								searchData += "<tr class='log'>[l]</tr>"
								found = 1
								foundCount++
						if (found) dat += "<tr><td colspan='3' class='header [log]'>[prettyLogName] logs</td></tr>"
						dat += searchData
				else
					var/list/logList = logs[logType]
					dat += "<tr><td colspan='3' class='header [logType]'>[prettyLogName] logs</td></tr>"
					if (!logList.len)
						dat += "<tr><td colspan='3' class='log'>No results in [prettyLogName] logs.</td></tr>"
					else
						if (gettxt)
							for (var/l in logList)
								if (findtext(l, gettxt, 1, null))
									dat += "<tr class='log'>[l]</tr>"
									foundCount++
						else
							for (var/l in logList)
								dat += "<tr class='log'>[l]</tr>"
								foundCount++
					dat += "</table>"

				dat = "<tr><td colspan='3' class='header text-normal [logType]'><b>Logs</b>[gettxt ? " (Searched for '[gettxt]')" : ""]. Found <b>[foundCount]</b> results.</td></tr>" + dat
				dat = replacetext(dat, "%admin_ref%", "\ref[src]")
				var/adminLogHtml = grabResource("html/admin/admin_log.html")
				adminLogHtml = replacetext(adminLogHtml, "<!-- TABLE GOES HERE -->", "[dat]")
				usr << browse(adminLogHtml, "window=[logType]_log;size=750x500")
			else
				alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)

		if ("view_logs_pathology_strain")
			if (src.level >= LEVEL_MOD)
				var/gettxt
				if (href_list["presearch"])
					gettxt = href_list["presearch"]
				else
					gettxt = input("Which pathogen tree?", "Pathogen tree") in pathogen_controller.pathogen_trees
				var/logType = "pathology"
				var/prettyLogName = logType
				var/dat = "<table>"
				var/foundCount = 0
				var/list/logList = logs[logType]
				dat += "<tr><td colspan='3' class='header [logType]'>[prettyLogName] logs</td></tr>"
				if (!logList.len)
					dat += "<tr><td colspan='3' class='log'>No results in [prettyLogName] logs.</td></tr>"
				else
					for (var/l in logList)
						if (findtext(l, gettxt, 1, null))
							dat += "<tr class='log'>[l]</tr>"
							foundCount++
				dat += "</table>"

				dat = "<tr><td colspan='3' class='header text-normal [logType]'><b>Logs</b>[gettxt ? " (Searched for '[gettxt]')" : ""]. Found <b>[foundCount]</b> results.</td></tr>" + dat
				dat = replacetext(dat, "%admin_ref%", "\ref[src]")
				var/adminLogHtml = grabResource("html/admin/admin_log.html")
				adminLogHtml = replacetext(adminLogHtml, "<!-- TABLE GOES HERE -->", "[dat]")
				usr << browse(adminLogHtml, "window=[logType]_log;size=750x500")

		if ("s_rez")
			if (src.level >= LEVEL_SHITGUY)
				switch(href_list["type"])
					if("spawn_syndies")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Syndicates",3) as num
						if(!amount) return
						SR.spawn_syndies(amount)
						logTheThing("admin", src, null, "has spawned [amount] syndicate operatives.")
						logTheThing("diary", src, null, "has spawned [amount] syndicate operatives.", "admin")

					if("spawn_normal")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Normal Players",3) as num
						if(!amount) return
						SR.spawn_normal(amount)
						logTheThing("admin", src, null, "has spawned [amount] normal players.")
						logTheThing("diary", src, null, "has spawned [amount] normal players.", "admin")

	/*				if("spawn_commandos")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						SR.spawn_commandos(3)

					if("spawn_turds")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn TURDS",3) as num
						if(!amount) return
						SR.spawn_TURDS(amount)
						logTheThing("admin", src, null, "has spawned [amount] TURDS.")
						logTheThing("diary", src, null, "has spawned [amount] TURDS.", "admin")

					if("spawn_smilingman")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						SR.spawn_smilingman(1)
						logTheThing("admin", src, null, "has spawned a Smiling Man.")
						logTheThing("diary", src, null, "has spawned a Smiling Man.", "admin")
	*/

					if("spawn_custom")
						var/datum/special_respawn/SR = new /datum/special_respawn
						var/blType = input(usr, "Select a mob type", "Spawn Custom") as null|anything in typesof(/mob/living)
						if(!blType) return
						var/amount = input(usr, "Amount to respawn:", "Spawn Custom",3) as num
						if(!amount) return
						SR.spawn_custom(blType, amount)
						logTheThing("admin", src, null, "has spawned [amount] mobs of type [blType].")
						logTheThing("diary", src, null, "has spawned [amount] mobs of type [blType].", "admin")

					if("spawn_wizards")

					if("spawn_aliens")

					else
			else
				alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		if ("respawntarget")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/mob/newM = usr.client.respawn_target(M)
				href_list["target"] = "\ref[newM]"
			else
				alert ("You must be at least a Secondary Admin to respawn a target.")
		if ("showrules")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.show_rules_to_player(M)
			else
				alert ("You must be at least a Secondary Admin to show rules to a player.")
		if ("warn")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.warn(M)
			else
				alert ("You must be at least a Secondary Admin to warn a player.")
		if ("clownify")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_clownify(M)
			else
				alert ("You must be at least a Primary Admin to clownify a player.")
		if ("plainmsg")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_plain_message(M)
			else
				alert ("You must be at least a Moderator to plain message a player.")
		if ("humanize")
			if (src.level >= LEVEL_PA) // Moved from SG to PA (Convair880).
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/mob/newM = usr.client.cmd_admin_humanize(M)
				href_list["target"] = "\ref[newM]"
			else
				alert ("You must be at least a Primary Admin to humanize a player.")

	//Wires bad hack part 2
	sleep(5)
	switch (originWindow)
		if ("adminplayeropts")
			if (href_list["targetckey"])
				var/targetCkey = href_list["targetckey"]
				for (var/mob/M in mobs) //The ref may have changed with our actions, find it again
					if (M.ckey == targetCkey)
						href_list["target"] = "\ref[M]"
						continue
				var/mob/target = locate(href_list["target"])
				for (var/mob/M in mobs) //We can't even trust that the admin ref hasnt changed
					if (adminCkey == M.ckey)
						usr = M
						continue
				usr.client.holder.playeropt(target)

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/player()
	var/dat = "<html><head><title>Player Menu</title></head>"
	dat += "<body><table border=1 cellspacing=5><B><tr><th>Name</th><th>Real Name</th><th>Key</th><th>Options</th><th>PM</th><th>Traitor?</th><th>Computer ID</th><th>IP:</th><th>Joined:</th></tr></B>"

	var/list/mobs = sortmobs()

	for(var/mob/M in mobs)
		if(M.ckey)
			dat += "<tr><td>[M.name]</td>"
			if(isAI(M))
				dat += "<td>AI</td>"
			else if(isrobot(M))
				dat += "<td>Cyborg</td>"
			else if(ishivebot(M))
				dat += "<td>Robot</td>"
			else if(ismainframe(M))
				dat += "<td>Mainframe</td>"
			else if(ismonkey(M))
				dat += "<td>Monkey</td>"
			else if(ishuman(M))
				dat += "<td>[M.real_name]</td>"
			else if(istype(M, /mob/new_player))
				dat += "<td>New Player</td>"
			else if(isobserver(M))
				dat += "<td>Ghost</td>"
//			else if(istype(M, /mob/living/carbon/alien))
//				dat += "<td>Alien</td>"
			else if(istype(M, /mob/living/carbon/wall))
				dat += "<td>[M.real_name]</td>"
			else
				dat += "<td>ERROR</td>"
			dat += {"<td>[(M.client ? "[M.client]" : "(NO CLIENT) [M.ckey]")]</td>
				<td align=center><A HREF='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>X</A></td>
				<td align=center><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>
				<td align=center><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>[checktraitor(M) ? "<font color=red>" : "<font>"]Traitor?</font></A></td>
			"}
			dat += "<td align=center>[M.computer_id ? M.computer_id : "None"]</td>"
			dat += "<td>[M.lastKnownIP]</td>"
			dat += "<td>[M.client ? M.client.joined_date : "---"]</td></tr>"
			sleep(-1)

	dat += "</table></body></html>"

	usr << browse(dat, "window=players;size=1035x480")


/datum/admins/proc/s_respawn()
	var/dat = "<html><head><title>Respawn Panel</title></head>"
	dat += {"
			<BR>
			<A href='?src=\ref[src];action=s_rez;type=spawn_normal'>Spawn normal players</A><BR>
			<A href='?src=\ref[src];action=s_rez;type=spawn_syndies'>Spawn a Syndicate attack force</A><BR>
			<A href='?src=\ref[src];action=s_rez;type=spawn_custom'>Spawn a custom mob type</A><BR>
			"}
	usr << browse(dat, "window=SRespawn")

	// Someone else removed these but left the (non-functional) buttons. Move back inside the dat section and uncomment to re-add. - IM
	// <A href='?src=\ref[src];action=s_rez;type=spawn_commandos'>Spawn a force of commandos</A><BR>
	// <A href='?src=\ref[src];action=s_rez;type=spawn_turds'>Spawn a T.U.R.D.S. attack force</A><BR>
	// <A href='?src=\ref[src];action=s_rez;type=spawn_smilingman'>Spawn a Smiling Man</A><BR>

/datum/admins/proc/buildjobbanspanel()
	set background = 1
	if (building_jobbans != 0)
		boutput(usr, "Rebuild in progress, please try again later.")
		return

	if (alert("Fix a corrupted local panel or force a complete rebuild of the server's panel?","Select Rebuild Type","Local Fix","Server Rebuild") == "Local Fix")
		var/jobban_dialog_text = replacetext(grabResource("html/admin/jobbans_list.html"), "null /* raw_bans */", "\"[global_jobban_cache]\"");
		usr << browse(replacetext(jobban_dialog_text, "null /* ref_src */", "\"\ref[src]\""),"file=jobbans.html;display=0")
		current_jobbans_rev = global_jobban_cache_rev
		jobbans_last_cached = world.timeofday
		boutput(usr, "Refresh complete, your panel now matches the server's. If you need to edit a ban that was created after the build time shown please do a server rebuild.")
	else
		boutput(usr, "Rebuilding server cache...")

		building_jobbans = 1

		var/buf = ""
		jobban_count = 0
		for(var/t in jobban_keylist) if (t)
			jobban_count++
			buf += text("[t];")

		global_jobban_cache = buf
		global_jobban_cache_rev++
		global_jobban_cache_built = world.timeofday

		building_jobbans = 0
		boutput(usr, "Rebuild complete, everyone's job ban panel is now up to date with the latest job bans.")


/datum/admins/var/current_jobbans_rev = 0
/datum/admins/var/jobbans_last_cached = 0
/datum/admins/proc/Jobbans()
	set background = 1
	if (src.level >= LEVEL_CODER)
		if (current_jobbans_rev == 0 || current_jobbans_rev < global_jobban_cache_rev) // the cache is newer than our panel
			var/jobban_dialog_text = replacetext(grabResource("html/admin/jobbans_list.html"), "null /* raw_bans */", "\"[global_jobban_cache]\"");
			usr << browse(replacetext(jobban_dialog_text, "null /* ref_src */", "\"\ref[src]\""),"file=jobbans.html;display=0")
			current_jobbans_rev = global_jobban_cache_rev
			jobbans_last_cached = world.timeofday

		usr << browse("<html><head><title>Ban Management</title><style type=\"text/css\">body{font-size: 8pt; font-family: Verdana, sans-serif;}</style></head><body><iframe src=\"jobbans.html\"width=\"100%\" height=\"90%\"></iframe>[jobban_count] job bans. banlist built at [time2text(global_jobban_cache_built)] and downloaded at [time2text(jobbans_last_cached)]</body>", "window=jobbanp;size=400x800")

/datum/admins/proc/Game()
	var/dat

	dat += "<center><B>Game Panel</B></center><hr><br>"

	if (src.level >= LEVEL_MOD)
		dat += "<A href='?src=\ref[src];action=c_mode_panel'>Change Game Mode</A><br>"

	dat += "<BR>"

	if (src.level >= LEVEL_PA)
		dat += "<A href='?src=\ref[src];action=create_object'>Create Object</A><br>"
		dat += "<A href='?src=\ref[src];action=create_turf'>Create Turf</A><br>"
		dat += "<A href='?src=\ref[src];action=create_mob'>Create Mob</A><br>" // Moved from SG to PA. They can do this through build mode anyway (Convair880).
	usr << browse(dat, "window=admin2;size=210x180")
	return

/datum/admins/proc/Secrets()
	// ADMIN PANEL HTML IS HERE
	var/dat = "<html><body><title>Admin Secrets Panel</title>"

	var/shuttletext = " "
	if(!emergency_shuttle) return // runtime error fix
	if (emergency_shuttle.online)
		switch(emergency_shuttle.location)
			if(0)// centcom
				if (emergency_shuttle.direction == 1)
					shuttletext = "Coming to Station (ETA: [round(emergency_shuttle.timeleft()/60)])"
				if (emergency_shuttle.direction == -1)
					shuttletext = "Returning to Centcom (ETA: [round(emergency_shuttle.timeleft()/60)])"
			if(1)// ss13
				shuttletext = "Arrived at Station (ETD: [round(emergency_shuttle.timeleft()/60)])"
			if(2)// evacuated
				shuttletext = "Evacuated to Centcom"
			else
				shuttletext = "Unknown"
	else
		shuttletext = "Idle"

	if (ticker)
		if (ticker.current_state >= GAME_STATE_PLAYING)
			dat += "<b>Game Info:</b> [ticker.mode.name] Mode, Timer at [round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]<br>"
			if (emergency_shuttle.online)
				dat += "<a href='?src=\ref[src];action=call_shuttle&type=2'><b>Shuttle Status:</b></a> <a href='?src=\ref[src];action=edit_shuttle_time'>[shuttletext]</a>"
			else
				dat += "<a href='?src=\ref[src];action=call_shuttle&type=1'><b>Shuttle Status:</b></a> <a href='?src=\ref[src];action=edit_shuttle_time'>[shuttletext]</a>"
		else if (ticker.current_state == GAME_STATE_PREGAME)
			dat += "<b>Game Info:</b> Game has not started yet.<br>"
			dat += "<b>Force players to use random names:</b> <A href='?src=\ref[src];action=secretsfun;type=forcerandomnames'>[force_random_names ? "Yes" : "No"]</a><br>"
			dat += "<b>Force players to use random appearances:</b> <A href='?src=\ref[src];action=secretsfun;type=forcerandomlooks'>[force_random_looks ? "Yes" : "No"]</a><br>"
			//dat += "<A href='?src=\ref[src];action=secretsfun;type=forcerandomnames'>Politely suggest all players use random names</a>" // lol

	dat += {"<br><br>
				<u><B>Admin Tools:</B></u><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=check_antagonist'>Antagonists</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=jobcaps'>Job Controls</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=randomevents'>Random Event Controls</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=artifacts'>Artifact Controls</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=pathology'>CDC</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=motives'>Motive Control</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=unelectrify_all'>De-electrify all Airlocks</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=manifest'>Crew Manifest</A> *
				<A href='?src=\ref[src];action=secretsadmin;type=DNA'>Blood DNA</A> *
				<A href='?src=\ref[src];action=secretsadmin;type=fingerprints'>Fingerprints</A>
			"}

	if (src.level >= LEVEL_SHITGUY)
		dat += {"<br><br>
					<u><B>Coder Tools:</B></u><BR>
					<B>Debug System:</b><br>
					<A href='?src=\ref[src];action=secretsdebug;type=budget'>Wages/Money</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=market'>Shipping Market</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=genetics'>Genetics Research</A><br>
					<A href='?src=\ref[src];action=secretsdebug;type=jobs'>Jobs</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=hydro'>Hydroponics</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=manuf'>Manufacturing</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=radio'>Communications</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=randevent'>Random Events</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=disease'>Diseases</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=mechanic'>Mechanics</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=artifact'>Artifacts</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=gauntlet'>Gauntlet</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=colosseum'>Colosseum</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=stock'>Stock Market</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=emshuttle'>Emergency Shuttle</A> *
					<A href='?src=\ref[src];action=secretsdebug;type=overlays'>Overlays</A> <A href='?src=\ref[src];action=secretsdebug;type=overlaysrem'>(Remove)</A>
				"}

	dat += {"<br><br>
				<u><B>Logs:</B></u><BR>
				<A href='?src=\ref[src];action=view_logs;type=all_logs_string'>Search all Logs</A><BR>
				<A href='?src=\ref[src];action=view_logs;type=speech_log'>Speech Log </A>
				<A href='?src=\ref[src];action=view_logs;type=speech_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=combat_log'>Combat Log </A>
				<A href='?src=\ref[src];action=view_logs;type=combat_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=ooc_log'>OOC Log </A>
				<A href='?src=\ref[src];action=view_logs;type=ooc_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=station_log'>Station Log </A>
				<A href='?src=\ref[src];action=view_logs;type=station_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=pdamsg_log'>PDA Message Log </A>
				<A href='?src=\ref[src];action=view_logs;type=pdamsg_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=telepathy_log'>Telepathy Log </A>
				<A href='?src=\ref[src];action=view_logs;type=telepathy_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=admin_log'>Admin Log</A>
				<A href='?src=\ref[src];action=view_logs;type=admin_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=debug_log'>Debug Log</A>
				<A href='?src=\ref[src];action=view_logs;type=debug_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=wire_debug_log'>Wire Debug Log</A><br>
				<A href='?src=\ref[src];action=view_logs;type=admin_help_log'>Adminhelp Log</A>
				<A href='?src=\ref[src];action=view_logs;type=admin_help_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=mentor_help_log'>Mentorhelp Log</A>
				<A href='?src=\ref[src];action=view_logs;type=mentor_help_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=bombing_log'>Bombing Log</A>
				<A href='?src=\ref[src];action=view_logs;type=bombing_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=signalers_log'>Signaler Log</A>
				<A href='?src=\ref[src];action=view_logs;type=signalers_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=atmos_log'>Atmos Log</A>
				<A href='?src=\ref[src];action=view_logs;type=atmos_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=pathology_log'>Pathology Log</A>
				<A href='?src=\ref[src];action=view_logs;type=pathology_log_string'><small>(Search)</small></A>
				<A href='?src=\ref[src];action=view_logs_pathology_strain'><small>(Find pathogen)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=vehicle_log'>Vehicle Log</A>
				<A href='?src=\ref[src];action=view_logs;type=vehicle_log_string'><small>(Search)</small></A>
				<br><br>
			"}
	// FUN SECRETS PANEL
	if (src.level >= LEVEL_PA || (src.level == LEVEL_SA && usr.client.holder.state == 2))
		dat += {"<u><B>Fun Secrets:</B></u><BR>
					<b>Transformation:</b>
						<A href='?src=\ref[src];action=secretsfun;type=transform_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=transform_all'>All</A><BR>
					<b>Add Bio-Effect<A href='?src=\ref[src];action=secretsfun;type=bioeffect_help'>*</a>:</b>
						<A href='?src=\ref[src];action=secretsfun;type=add_bioeffect_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=add_bioeffect_all'>All</A><BR>
					<b>Remove Bio-Effect:</b>
						<A href='?src=\ref[src];action=secretsfun;type=remove_bioeffect_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=remove_bioeffect_all'>All</A><BR>
					<b>Add Reagent<A href='?src=\ref[src];action=secretsfun;type=reagent_help'>*</a>:</b>
						<A href='?src=\ref[src];action=secretsfun;type=add_reagent_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=add_reagent_all'>All</A><BR>
					<b>Remove Reagent:</b>
						<A href='?src=\ref[src];action=secretsfun;type=remove_reagent_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=remove_reagent_all'>All</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=traitor_all'>Make everyone an Antagonist</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=retardify'>Give everyone severe brain damage</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=flipstation'>Set station direction</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=yeolde'>Replace all airlocks with doors</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=woodstation'>Replace all floors and walls with wood</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=raiseundead'>Raise all human corpses as undead</A><BR>
				"}
	if (src.level >= LEVEL_SHITGUY)
		dat += {"<A href='?src=\ref[src];action=secretsfun;type=sawarms'>Give everyone saws for arms</A><BR>
				<A href='?src=\ref[src];action=secretsfun;type=emag_all_things'>Emag everything</A><BR>
				<A href='?src=\ref[src];action=secretsfun;type=noir'>Noir</A><BR>
				<A href='?src=\ref[src];action=secretsfun;type=the_great_switcharoo'>The Great Switcharoo</A><BR>
		"}

	usr << browse(dat, "window=secrets")
	return

/datum/admins/proc/Voting()
	var/dat = "<center><B>Voting</B></center><hr><br>"

	if (src.level >= LEVEL_MOD)
		dat += {"
					<A href='?src=\ref[src];action=votekill'>Abort Vote</A><br>
					<A href='?src=\ref[src];action=vmode'>Start Vote</A><br>
					<A href='?src=\ref[src];action=voteres'>Toggle Voting</A><br>
				"}

	usr << browse(dat, "window=admin2;size=210x160")
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs

//DICKSDONGS

/datum/admins/proc/vmode()
	set category = "Special Verbs"
	set name = "Start Vote"
	set desc="Starts vote"
	var/confirm = alert("What vote would you like to start?", "Vote", "Restart", "Change Game Mode", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Restart")
		vote.mode = 0
	// hack to yield 0=restart, 1=changemode
	if(confirm == "Change Game Mode")
		vote.mode = 1
		if(!ticker)
			if(going)
				boutput(world, "<B>The game start has been delayed.</B>")
				going = 0
	vote.voting = 1
						// now voting
	vote.votetime = world.timeofday + config.vote_period*10
	// when the vote will end
	spawn(config.vote_period*10)
		vote.endvote()
	boutput(world, "<span style=\"color:red\"><B>*** A vote to [vote.mode?"change game mode":"restart"] has been initiated by Admin [usr.key].</B></span>")
	boutput(world, "<span style=\"color:red\">You have [vote.timetext(config.vote_period)] to vote.</span>")

	logTheThing("admin", usr, null, "forced a vote to [vote.mode?"change mode":"restart round"]")
	logTheThing("diary", usr, null, "forced a vote to [vote.mode?"change mode":"restart round"]", "admin")

	for(var/mob/CM in mobs)
		if(CM.client)
			if(config.vote_no_default || (config.vote_no_dead && CM.stat == 2))
				CM.client.vote = "none"
			else
				CM.client.vote = "default"

/datum/admins/proc/votekill()
	set category = "Special Verbs"
	set name = "Abort Vote"
	set desc="Aborts a vote"
	//vote_manager.cancel_vote()

	if(vote.voting == 0)
		alert("No votes in progress")
		return
	boutput(world, "<span style=\"color:red\"><b>*** Voting aborted by [admin_key(usr.client, 1)].</b></span>")

	logTheThing("admin", usr, null, "aborted vote")
	logTheThing("diary", usr, null, "aborted vote", "admin")

	vote.voting = 0
	vote.nextvotetime = world.timeofday + 10*config.vote_delay

	for(var/mob/M in mobs)
		// clear vote window from all clients
		if(M.client)
			M << browse(null, "window=vote")
			M.client.showvote = 0

/datum/admins/proc/restart()
	set category = "Special Verbs"
	set name = "Restart"
	set desc= "Restarts the world"
	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		boutput(world, "<span style=\"color:red\"><b>Restarting world!</b></span> <span style=\"color:blue\">Initiated by [admin_key(usr.client, 1)]!</span>")
		logTheThing("admin", usr, null, "initiated a reboot.")
		logTheThing("diary", usr, null, "initiated a reboot.", "admin")

		var/ircmsg[] = new()
		ircmsg["key"] = usr.client.key
		ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
		ircmsg["msg"] = "manually restarted the server."
		ircbot.export("admin", ircmsg)

		round_end_data(2) //Wire: Export round end packet (manual restart)

		sleep(30)
		Reboot_server()

/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if (message)
		if(usr.client.holder.rank != "Coder" && usr.client.holder.rank != "Host")
			message = adminscrub(message,500)
		boutput(world, "<span style=\"color:blue\"><b>[admin_key(usr.client, 1)] Announces:</b><br>&emsp; [message]</span>")
		logTheThing("admin", usr, null, ": [message]")
		logTheThing("diary", usr, null, ": [message]", "admin")

/datum/admins/proc/startnow()
	set category = "Special Verbs"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(!ticker)
		alert("Unable to start the game as it is not set up.")
		return
	if(ticker.current_state == GAME_STATE_PREGAME)
		ticker.current_state = GAME_STATE_SETTING_UP
		logTheThing("admin", usr, null, "has started the game.")
		logTheThing("diary", usr, null, "has started the game.", "admin")
		message_admins("<font color='blue'>[usr.key] has started the game.</font>")
		return 1
	else
		alert("Game has already started you fucking jerk, stop spamming up the chat :ARGH:")
		return 0

/datum/admins/proc/delay_start()
	set category = "Special Verbs"
	set desc="Delay the game start"
	set name="Delay Round Start"

	if (ticker.current_state != GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!", null, null, null, null, null)
	game_start_delayed = !(game_start_delayed)

	if (game_start_delayed)
		boutput(world, "<b>The game start has been delayed.</b>")
		logTheThing("admin", usr, null, "delayed the game start.")
		logTheThing("diary", usr, null, "delayed the game start.", "admin")
		message_admins("<font color='blue'>[usr.key] has delayed the game start.</font>")
	else
		boutput(world, "<b>The game will start soon.</b>")
		logTheThing("admin", usr, null, "removed the game start delay.")
		logTheThing("diary", usr, null, "removed the game start delay.", "admin")
		message_admins("<font color='blue'>[usr.key] has removed the game start delay.</font>")

/datum/admins/proc/delay_end()
	set category = "Special Verbs"
	set desc="Delay the server restart"
	set name="Delay Round End"

	if (game_end_delayed == 2)
		logTheThing("admin", usr, null, "removed the restart delay and triggered an immediate restart.")
		logTheThing("diary", usr, null, "removed the restart delay and triggered an immediate restart.", "admin")
		message_admins("<font color='blue'>[usr.key] removed the restart delay and triggered an immediate restart.</font>")
		Reboot_server()

	else if (game_end_delayed == 0)
		game_end_delayed = 1
		game_end_delayer = usr.key
		logTheThing("admin", usr, null, "delayed the server restart.")
		logTheThing("diary", usr, null, "delayed the server restart.", "admin")
		message_admins("<font color='blue'>[usr.key] delayed the server restart.</font>")

		var/ircmsg[] = new()
		ircmsg["key"] = (usr && usr.client) ? usr.client.key : "NULL"
		ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
		ircmsg["msg"] = "has delayed the server restart."
		ircbot.export("admin", ircmsg)

	else if (game_end_delayed == 1)
		game_end_delayed = 0
		game_end_delayer = null
		logTheThing("admin", usr, null, "removed the restart delay.")
		logTheThing("diary", usr, null, "removed the restart delay.", "admin")
		message_admins("<font color='blue'>[usr.key] removed the restart delay.</font>")

		var/ircmsg[] = new()
		ircmsg["key"] = (usr && usr.client) ? usr.client.key : "NULL"
		ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
		ircmsg["msg"] = "has removed the server restart delay."
		ircbot.export("admin", ircmsg)

/mob/proc/revive()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.full_heal()
		H.remove_ailments() // don't spawn with heart failure
	return

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/checktraitor(mob/M as mob)
	set popup_menu = 0
	if(!M || !M.mind || !ticker || !ticker.mode)
		return 0

	if (M.mind && M.mind.special_role == "traitor")
		return 1

	if (istype(ticker.mode, /datum/game_mode/revolution))
		if(M.mind in (ticker.mode:head_revolutionaries + ticker.mode:revolutionaries))
			return 1
	else if (istype(ticker.mode, /datum/game_mode/nuclear))
		if(M.mind in ticker.mode:syndicates)
			return 1
	else if (istype(ticker.mode, /datum/game_mode/spy))
		if(M.mind in (ticker.mode:leaders + ticker.mode:spies))
			return 1
	else if (istype(ticker.mode, /datum/game_mode/gang))
		if(M.mind in (ticker.mode:leaders))
			return 1
		for(var/datum/gang/G in ticker.mode:gangs)
			if(M in G.members)
				return 1

	if(M.mind in ticker.mode:traitors)
		return 1
	if(M.mind in ticker.mode:Agimmicks)
		return 1

	return 0

/datum/admins/proc/evilize(mob/M as mob, var/traitor_type, var/special = null, var/mass_traitor_obj = null, var/mass_traitor_esc = null)
	if (!M || !traitor_type)
		boutput(usr, "<span style=\"color:red\">No mob or traitor type specified.</span>")
		return
	if (!src.level >= LEVEL_SA)
		boutput(usr, "<span style=\"color:red\">You need to be a Secondary Administrator or above to use this command.</span>")
		return
	if(M.stat == 2 || istype(M,/mob/dead/))
		boutput(usr, "<span style=\"color:red\">You cannot make someone who is dead an antagonist.</span>")
		return
	if (istype(M,/mob/new_player/))
		boutput(usr, "<span style=\"color:red\">You cannot make someone who has not entered the game an antagonist.</span>")
		return
	if (!M.client)
		boutput(usr, "<span style=\"color:red\">You cannot make someone who is logged out an antagonist.</span>")
		return
	if(checktraitor(M))
		boutput(usr, "<span style=\"color:red\">That person is already an antagonist.</span>")
		return
	if(!(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/gang)) && traitor_type == "gang leader")
		boutput(usr, "<span style=\"color:red\">Gang Leaders are currently restricted to gang mode only.</span>")
		return

	traitor_type = lowertext(traitor_type)
	special = lowertext(special)

	if(mass_traitor_obj)
		var/datum/objective/custom_objective = new /datum/objective(mass_traitor_obj)
		custom_objective.owner = M.mind
		M.mind.objectives += custom_objective

		if(mass_traitor_esc)
			var/datum/objective/escape/escape_objective = new mass_traitor_esc
			escape_objective.owner = M.mind
			M.mind.objectives += escape_objective
	else
		var/list/eligible_objectives = list()
		if (ishuman(M) || iscritter(M))
			eligible_objectives = typesof(/datum/objective/regular/) + typesof(/datum/objective/escape/)
		else if (issilicon(M))
			eligible_objectives = list(/datum/objective/regular,/datum/objective/regular/assassinate,
			/datum/objective/regular/force_evac_time,/datum/objective/regular/gimmick,/datum/objective/escape,/datum/objective/escape/hijack,
			/datum/objective/escape/survive,/datum/objective/escape/kamikaze)
			if (istype(M,/mob/living/silicon/robot/))
				eligible_objectives += /datum/objective/regular/borgdeath
			traitor_type = "traitor"
		switch(traitor_type)
			if ("changeling")
				eligible_objectives += /datum/objective/specialist/absorb
			if ("werewolf")
				eligible_objectives += /datum/objective/specialist/werewolf/feed
			if ("vampire")
				eligible_objectives += /datum/objective/specialist/drinkblood
			if ("predator")
				eligible_objectives += /datum/objective/specialist/predator/trophy
			if ("grinch")
				eligible_objectives += /datum/objective/specialist/ruin_xmas
			if ("gang leader")
				var/datum/objective/gangObjective = new /datum/objective/specialist/gang(  )
				gangObjective.owner = M.mind
				M.mind.objectives += gangObjective
		var/done = 0
		var/select_objective = null
		var/datum/objective/new_objective = null
		var/custom_text = "Go hog wild!"
		while (done != 1)
			select_objective = input(usr, "Add a new objective. Hit cancel when finished adding.", "Traitor Objectives") as null|anything in eligible_objectives
			if (!select_objective)
				done = 1
				break
			if (select_objective == /datum/objective/regular)
				custom_text = input(usr,"Enter custom objective text.","Traitor Objectives","Go hog wild!") as null|text
				if (custom_text)
					new_objective = new select_objective(custom_text)
					new_objective.owner = M.mind
					new_objective.set_up()
					M.mind.objectives += new_objective
				else
					boutput(usr, "<span style=\"color:red\">No text was entered. Objective not given.</span>")
			else
				new_objective = new select_objective
				new_objective.owner = M.mind
				new_objective.set_up()
				M.mind.objectives += new_objective

		if (M.mind.objectives.len < 1)
			boutput(usr, "<span style=\"color:red\">Not enough objectives specified.</span>")
			return

	if (isAI(M))
		var/mob/living/silicon/ai/A = M
		A.syndicate = 1
		A.syndicate_possible = 1
		A.handle_robot_antagonist_status("admin", 0, usr)
	else if (isrobot(M))
		var/mob/living/silicon/robot/R = M
		if (R.dependent)
			boutput(usr, "<span style=\"color:red\">You can't evilize AI-controlled shells.</span>")
			return
		R.syndicate = 1
		R.syndicate_possible = 1
		R.handle_robot_antagonist_status("admin", 0, usr)
	else if (ishuman(M) || iscritter(M))
		switch(traitor_type)
			if("traitor")
				M.show_text("<h2><font color=red><B>You have defected and become a traitor!</B></font></h2>", "red")
				if(special != "hardmode")
					M.mind.special_role = "traitor"
					M.verbs += /client/proc/gearspawn_traitor
					M << browse(grabResource("html/traitorTips/traitorradiouplinkTips.html"),"window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0")
				else
					M.mind.special_role = "hard-mode traitor"
					M << browse(grabResource("html/traitorTips/traitorhardTips.html"),"window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0")
			if("changeling")
				M.mind.special_role = "changeling"
				M.show_text("<h2><font color=red><B>You have mutated into a changeling!</B></font></h2>", "red")
				M.make_changeling()
			if("wizard")
				M.mind.special_role = "wizard"
				M.show_text("<h2><font color=red><B>You have been seduced by magic and become a wizard!</B></font></h2>", "red")
				M << browse(grabResource("html/traitorTips/wizardcustomTips.html"),"window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0")
				M.verbs += /client/proc/gearspawn_wizard
			if("vampire")
				M.mind.special_role = "vampire"
				M.show_text("<h2><font color=red><B>You have joined the ranks of the undead and are now a vampire!</B></font></h2>", "red")
				M.make_vampire()
			if("predator")
				M.mind.special_role = "predator"
				M.mind.assigned_role = "Predator"
				M.show_text("<h2><font color=red><B>You have become a predator!</B></font></h2>", "red")
				M.make_predator()
			if("wrestler")
				M.mind.special_role = "wrestler"
				M.show_text("<h2><font color=red><B>You feel an urgent need to wrestle!</B></font></h2>", "red")
				M.make_wrestler(1)
			if("werewolf")
				M.mind.special_role = "werewolf"
				M.show_text("<h2><font color=red><B>You have become a werewolf!</B></font></h2>", "red")
				M.make_werewolf()
			if("grinch")
				M.mind.special_role = "grinch"
				M.make_grinch()
				M.show_text("<h2><font color=red><B>You have become a grinch!</B></font></h2>", "red")
			if("gang leader")
				boutput(M, "<h1><font color=red>You are the leader of the [M.mind.gang.gang_name] gang!</font></h1>")
				boutput(M, "<span style=\"color:red\">You must recruit people to your cause and fight other gangs!</span>")
				boutput(M, "<span style=\"color:red\">Don't kill civilians unless you have to. Convince them to join you instead!</span>")
				boutput(M, "<span style=\"color:red\">You can use the Set Gang Base command once which will make your current area into your gang's base and spawn a locker full of equipment.</span>")
				boutput(M, "<span style=\"color:red\">People can join your gang by right clicking your locker and selecting Join Gang.</span>")
				boutput(M, "<span style=\"color:red\">Your objective is simple: <b>Kill the opposing gang leaders</b>.</span>")
				M.verbs += /client/proc/gearspawn_gang
				alert(M, "Use the Set Gang Base verb to claim a home turf and start recruiting people!", "You are a gang leader!")
			if("omnitraitor")
				M.mind.special_role = "omnitraitor"
				M.verbs += /client/proc/gearspawn_traitor
				M.verbs += /client/proc/gearspawn_wizard
				M.make_changeling()
				M.make_vampire()
				M.make_werewolf()
				M.make_wrestler(1)
				M.make_grinch()
				M.show_text("<h2><font color=red><B>You have become an omnitraitor!</B></font></h2>", "red")
				M << browse(grabResource("html/traitorTips/omniTips.html"),"window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0")

	else
		M.show_text("<h2><font color=red><B>You have become evil and are now an antagonist!</B></font></h2>", "red")

	if (!(M.mind in ticker.mode.Agimmicks))
		ticker.mode.Agimmicks += M.mind

	if (M.mind.current)
		M.mind.current.antagonist_overlay_refresh(1, 0)

	var/obj_count = 1
	for(var/datum/objective/OBJ in M.mind.objectives)
		boutput(M, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
		obj_count++

	//to stop spamming during traitor all secret
	if(!mass_traitor_obj)
		logTheThing("admin", usr, M, "made %target% a[special ? " [special]" : ""] [traitor_type].")
		logTheThing("diary", usr, M, "made %target% a[special ? " [special]" : ""] [traitor_type].", "admin")
		message_admins("<span style=\"color:blue\">[key_name(usr)] has made [key_name(M)] a[special ? " [special]" : ""] [traitor_type].</span>")
	return

/datum/admins/proc/get_item_desc(var/target)
	switch (target)
		if (1)
			return "a fully loaded laser gun"
		if (2)
			return "a hand teleporter"
		if (3)
			return "a fully armed and heated plasma bomb"
		if (4)
			return "a jet pack"
		if (5)
			return "an ID card with universal access"
		if (6)
			return "a captain's dark green jumpsuit"
		else
			return "Error: Invalid theft target: [target]"

/proc/get_matches_string(var/text, var/list/possibles)
	var/list/matches = new()
	for (var/possible in possibles)
		if (findtext(possible, text))
			matches += possible

	return matches

/proc/get_one_match_string(var/text, var/list/possibles)
	var/list/matches = get_matches_string(text, possibles)
	if (matches.len == 0)
		return null
	var/chosen
	if (matches.len == 1)
		chosen = matches[1]
	else
		chosen = input("Select a match", "matches for pattern", null) as null|anything in matches
		if (!chosen)
			return null

	return chosen

/proc/get_matches(var/object, var/base = /atom)
	var/list/types = typesof(base)

	var/list/matches = new()

	for(var/path in types)
		if(findtext("[path]", object))
			matches += path

	return matches

/proc/get_one_match(var/object, var/base = /atom)
	var/list/matches = get_matches(object, base)

	if(matches.len==0)
		return null

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		var/safe_matches = matches - list(/database, /client, /icon, /sound, /savefile)
		chosen = input("Select an atom type", "Matches for pattern", null) as null|anything in safe_matches
		if(!chosen)
			return null

	return chosen

/datum/admins/proc/spawn_atom(var/object as text)
	set category = "Special Verbs"
	set desc="(atom path) Spawn an atom"
	set name="Spawn"

	if (usr.client.holder.level >= LEVEL_CODER)
		var/chosen = get_one_match(object)

		if (chosen)
			new chosen(usr.loc)

			logTheThing("admin", usr, null, "spawned [chosen] at ([showCoords(usr.x, usr.y, usr.z)])")
			logTheThing("diary", usr, null, "spawned [chosen] at ([showCoords(usr.x, usr.y, usr.z, 1)])", "admin")

	else
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return

/client/proc/respawn_target(mob/M as mob in world)
	set name = "Respawn Target"
	set category = null
	set desc = "Respawn a mob"
	set popup_menu = 0
	if (!M) return

	if (alert(src, "Respawn [M]?", "Confirmation", "Yes", "No") != "Yes")
		return

	logTheThing("admin", src, M, "respawned %target%")
	logTheThing("diary", src, M, "respawned %target%.", "admin")
	message_admins("[key_name(src)] respawned [key_name(M)].")

	var/mob/new_player/newM = new()
	newM.adminspawned = 1

	newM.key = M.key
	if (M.mind)
		M.mind.transfer_to(newM)
	newM.Login()
	newM.sight = SEE_TURFS //otherwise the HUD remains in the login screen
	qdel(M)

	boutput(newM, "<b>You have been respawned.</b>")
	return newM

/client/proc/respawn_self()
	set name = "Respawn Self"
	set category = "Special Verbs"
	set desc = "Respawn yourself"

	if(!isobserver(usr))
		boutput(usr, "You can't respawn unless you're dead!")
		return

	logTheThing("admin", src, null, "respawned themselves.")
	logTheThing("diary", src, null, "respawned themselves.", "admin")
	message_admins("[key_name(src)] respawned themselves.")

	var/mob/new_player/M = new()

	M.key = usr.client.key
	M.Login()

/client/proc/smnoclip()
	set name = "Planar Shift"
	set category = "Smiling Man Powers"
	set desc = "Shift planes to toggle moving through walls and objects."

	if(!istype(usr, /mob/living))
		return

	usr.client.flying = !usr.client.flying
	boutput(usr, "You are [usr.client.flying ? "now" : "no longer"] flying through matter.")

/client/Move(NewLoc, direct)
	if(usr.client.flying)
		if(!isturf(usr.loc))
			usr.set_loc(get_turf(usr))

		if(NewLoc)
			usr.set_loc(NewLoc)
			src.mob.dir = direct
			return

		if((direct & NORTH) && usr.y < world.maxy)
			usr.y++
		if((direct & SOUTH) && usr.y > 1)
			usr.y--
		if((direct & EAST) && usr.x < world.maxx)
			usr.x++
		if((direct & WEST) && usr.x > 1)
			usr.x--

		src.mob.dir = direct
	else
		..()

/*
/mob/living/carbon/proc/cloak()
	//Buggy as heck because of the way updating clothing works (it clears all invisibility variables and sets them based on if you have a cloaking device on or not)
	//It also clears overlays so the overlay will dissapear and bluh, I don't want to add another variable sooo this is what you get I guess.
	//If the overlay dissapears you lose the cloaking too, so just retype cloak-self and it should work again
	//If you don't lay down or force yourself to update clothing via fire or whatever it should be good enough to use for the purpose of spying on shitlords I guess.
	set name = "Cloak self"
	set category = "Special Verbs"
	set desc = "Make yourself invisible!"

	if (!iscarbon(usr))
		boutput(usr, "Sorry, you have to be alive!")
		return

	if(!(usr.invisibility == 100))
		boutput(usr, "You are now cloaked")
		usr.set_clothing_icon_dirty()

		usr.overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "shield")

		usr.invisibility = 100
	else
		boutput(usr, "You are no longer cloaked")

		usr.set_clothing_icon_dirty()
		usr.invisibility = 0
*/
//
//
//ALL DONE
//*********************************************************************************************************
//
//