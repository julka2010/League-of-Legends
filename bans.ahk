#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

bans_GuiManager(o:="",data:="")
{
	static Region:=1, Queue:=1, Tier:=1, Time:=1
	static Regions:=["All","NA","EUW","EUNE","BR","TR","RU","LAN","LAS","OCE","KR"]
	static Queues:=["All","Normal","Ranked"]
	static Tiers:=["All","Bronze","Silver","Gold","Platinum","Diamond","Challenger"]
	static Times:=["Monthly","Weekly","Daily"]
	if (o="n")
	{
		o:=" x+0 gPress c9999ff"
		
		julka_GuiAdd("text","w60 +0x2","Region:")
		for k, v in Regions
			Gui, Add, Button,% o,%v%
		
		julka_GuiAdd("Text","w60 +0x2","Queue:")
		for k, v in Queues
			Gui, Add, Button,% o,%v%
			
		julka_GuiAdd("Text","w60 +0x2","Rating Tier:")
		for k,v in Tiers
			Gui, Add, Button,% o,%v%
			
		julka_GuiAdd("Text","w60 +0x2","Time:")
		for k,v in Times
			Gui, Add, Button,% o,%v%
		
		
		julka_GuiAdd("Button","xm gGo Default","Go!")
		AddButton("c9999ff","Blah blah")
		
		GuiControl,+cFF0000,% Regions[Region]
		GuiControl,+cFF0000,% Queues[Queue]
		GuiControl,+cFF0000,% Tiers[Tier]
		GuiControl,+cFF0000,% Times[Time]
		
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
		{
			GuiControl, -0x8000, % Regions[Region]
			Region:=k
			GuiControl, +0x8000, % Regions[Region]
		}
		else if (k:=julka_InArr(Queues,data))
		{
			GuiControl, -0x8000, % Queues[Queue]
			Queue:=k
			GuiControl, +0x8000, % Queues[Queue]
		}
		else if (k:=julka_InArr(Tiers,data))
		{
			GuiControl, -0x8000, % Tiers[Tier]
			Tier:=k
			GuiControl, +0x8000, % Tiers[Tier]
		}
		else if (k:=julka_InArr(Times,data))
		{
			GuiControl, -0x8000, % Times[Time]
			time:=k
			GuiControl, +0x8000, % Times[Time]
		}
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

AddButton(o:="",contents:="")
{
	static fo:="^(\w*?\s)*"
	;Progress options
	;Progress does need var or hwnd assosiated with it
	;Progress cannot have g-label
	;It is also disabled to not interfere with text
	Progo:=RegExReplace(o,fo "(v.*?\s)|(hwnd.*?\s)|(g.*?\s)") " disabled hwndhP"
	Texto:=RegExReplace(o,fo "c(0x)?[A-Fa-f\d]{6,8}") " BackGroundTrans"
	Texto.=o~="i)\shwnd" ? "" : " hwndht"
	if (!RegExMatch(o,fo "g"))
		if IsLabel(" gButton" RegExReplace(contents,"\s"))
			Texto.=" gButton" RegExReplace(contents,"\s")
	if (RegExMatch(Progo,"c(0x)?[A-Fa-f\d]{6,8}"))
	{
		Gui,Add,text,%Texto%,% contents
		GuiControlGet,c,Pos,%ht%
		GuiControl,Move,%ht%,% "x" cx+3 "y" cy+3
		Progo:=Progo~=fo "w" ? RegExReplace(Progo,"\sw\S*"," w" cw+6) : Progo " w" cw+6
		Progo:=Progo~=fo "x" ? RegExReplace(Progo,"\sx\S*"," x" cx) : Progo " x" cx
		Progo:=Progo~=fo "h" ? RegExReplace(Progo,"\sh\S*"," h" ch+4) : Progo " h" ch+4
		Progo:=Progo~=fo "y" ? RegExReplace(Progo,"\sy\S*"," y" cy) : Progo " y" cy
		Gui,Add,Progress,% Progo,100
		GuiControl,+hide +disabled,%ht%
		Texto:=Texto~=fo "w" ? RegExReplace(Texto,"\sw\S*","w" cw+6) : Texto " w" cw+6
		Texto:=Texto~=fo "x" ? RegExReplace(Texto,"\sx\S*"," x" cx) : Texto " x" cx
		Texto:=Texto~=fo "h" ? RegExReplace(Texto,"\sh\S*"," h" ch+4) : Texto " h" ch+4
		Texto:=Texto~=fo "y" ? RegExReplace(Texto,"\sy\S*"," y" cy) : Texto " y" cy
		Gui,Add,Text,%Texto% center,% contents
		;GuiControl,Move,%ht%,% "y" cy+100
	}	
	else Gui,Add,Button,%o%,% contents
	return hp "`n" ht
}
