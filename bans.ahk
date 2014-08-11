bans_GuiManager(o:="",data:="")
{
	static Region:=1, Queue:=1, Tier:=1, Time:=1
	static Regions:=["All","NA","EUW","EUNE","BR","TR","RU","LAN","LAS","OCE","KR"]
	static Queues:=["All","Normal","Ranked"]
	static Tiers:=["All","Bronze","Silver","Gold","Platinum","Diamond","Challenger"]
	static Times:=["Monthly","Weekly","Daily"]
	if (o="n")
	{
		o:=" xs y+0 gPress 0x1000 w60 center h20"
		
		Gui,Add,text,% "w60 section +0x1",% "Region:"
		for k, v in Regions
			Gui, Add, Radio,% o,%v%
		
		Gui,Add,Text,% "w60 x+20 ys section +0x1",% "Queue:"
		for k, v in Queues
			Gui, Add, Radio,% o,%v%
			
		Gui,Add,Text,% "w60 x+20 ys section +0x1",% "Rating Tier:"
		for k,v in Tiers
			Gui, Add, Radio,% o,%v%
			
		Gui,Add,Text,% "w60 x+20 ys section +0x1",% "Time:"
		for k,v in Times
			Gui, Add, Radio,% o,%v%
		
		GuiControlGet,c,Pos,% Regions[julka_LastKey(Regions)]
		Gui,Add,Button,% "gGo Default w60 xs" " y" cy,% "Go!"
		
		GuiControl,,% Regions[Region],1
		GuiControl,,% Queues[Queue],1
		GuiControl,,% Tiers[Tier],1
		GuiControl,,% Times[Time],1
		
		Gui, Show
		return
	}
	if (o="l")
	{
		t_tier:= ((Queue<3)||(Tier<2)) ? 0 : (Tier=2)||(Tier=3)||(Tier=7) ? Tier : (Tier=4) ? 6 : Tier-1
		t_time:=Time=1 ? 30 : Time=2 ? 7 : 1
		return "http://loldb.gameguyz.com/statistics/" Region-1 "/0/2/" Queue-1 "/" t_tier "/" t_time
	}
	if (o="p")
	{
		if (k:=julka_InArr(Regions,data))
			Region:=k
		else if (k:=julka_InArr(Queues,data))
			Queue:=k
		else if (k:=julka_InArr(Tiers,data))
			Tier:=k
		else if (k:=julka_InArr(Times,data))
			time:=k
		return	
	}
	if (o="set")
	{
		loop,Parse,data,`n,`r
		{
			t:=StrSplit(A_LoopField,"=")
			if (InStr(t[1],"Region"))&&((k:=julka_InArr(Regions,t[2]))!="")
				Region:=k
			else if (InStr(t[1],"Queue"))&&((k:=julka_InArr(Queues,t[2]))!="")
				Queue:=k
			else if (InStr(t[1],"Tier"))&&((k:=julka_InArr(Tiers,t[2]))!="")
				Tier:=k
			else if (InStr(t[1],"Time"))&&((k:=julka_InArr(Times,t[2]))!="")
				Time:=k
		}
	}
	
	Press:
		bans_GuiManager("p",A_GuiControl)
	return

	Go:
		Globals.WorkingRegion:=Regions[Region]
		IniWrite,% Regions[Region],% Globals.Ini,Program State,Region
		IniWrite,% Queues[Queue],% Globals.Ini,Program State,Queues
		IniWrite,% Times[Time],% Globals.Ini,Program State,Time
		IniWrite,% Tiers[Tier],% Globals.Ini,Program State,Tier
		BanList(bans_GuiManager("l"))
	return
}

BanList(link,o:="")
{
	;Patterns for champion name/games played/pick rate/win rate detection
	Static PCN:="alt=""(?P<Name>[^""]*?)""\sdname"
	Static PCG:="ar3.*?arValue=""(?P<Games>\d*?)"">"
	Static PCP:="ar4.*?arValue=""(?P<Popularity>[.\d]*?)"">"
	Static PCW:="ar5.*?arValue=""(?P<Wins>\d*?)"">"
	SetFormat, Float, 0.6

	stats:=UrlDownloadToVar(link)

	Pos:=1

	Champions:={}
	List:=""

	loop
	{	
		Pos:=RegExMatch(stats,"Ss)" PCN ".*?" PCG ".*?" PCP ".*?" PCW,O,Pos)+StrLen(O)
		if not Pos
			break	
		temp:=new Champion(OName,OGames,OPopularity/100,OWins)
		for k,v in Champions
			if (v.BanWorthy<temp.BanWorthy)
			{
				Champions.Insert(k,temp.Clone())
				continue 2
			}
		Champions.Insert(a_index,temp.Clone())
	}
	t:=0
	for k, v in Champions
	{
		if (v.BanWorthy<0)
			break
		List.=v.Name " " v.BanWorthy "`n"
	}

	msgbox % List
}
