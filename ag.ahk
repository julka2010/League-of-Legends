ag_GuiManager(o:="",data:="")
{
	static Summoner
	static hs
	static Region
	if (o="n")
	{
		Gui,Add, Edit, vSummoner hwndhs w150, % data
		Gui,Add,Button, x+20 w150 gActiveGame,Search for active game
		Gui,Show
		return
	}
	else if (o="u")
	{
		columns:="Summoner Name|Runes|Masteries"
		data:=ag_Info()
		GuiControlGet,c,Pos,Summoner
		julka_AddListView(columns,data,"Count11 R11 gagLV AltSubmit w372 x" cx " y+" ch//4)
		;OnMessage(0x200,"ag_MessageMonitor")
		return
	}
	else if (o="Normal")
	{
		if !(LV_GetText(summoner, data))
			return
		tooltip % ag_DetailedInfo(summoner)
		return
	}
	else if (t_pos:=InStr(o,"set"))
	{
		o:=SubStr(o,t_pos+3)
		if (o="Summoner")
		{
			GuiControl,,% hs,% data
			Summoner:=data
		}	
		return
	}
	return
	
	ActiveGame:
	{	
		Gui,Submit,Nohide
		Globals.DownloadActiveGame("euw",Summoner)
		Globals.DownloadSummoners("p")
		ag_GuiManager("u")
		return
	}
}

ag_Info()
{
	row:=column:=0
	data:=[]
	for k,v in Globals.Summoners
	{
		row++
		column:=0
		data[row]:=[]
		data[row][++column]:=v["name"]
		for key,value in v["runes"]
			if (value["current"]="true")
			{
				data[row][++column]:=value["name"]
				break
			}
		for key,value in v["Masteries"]
			if (value["current"]="true")
			{
				data[row][++column]:=value["name"]
				break
			}	
	}
	return data
}

ag_DetailedInfo(summoner)
{
	summoner:=st_setcase(RegExReplace(summoner,"\s"),"l")	
	for k,v in Globals.Summoners[summoner].runes
	{
		if (v.current="false")
			continue
		counter:={}	
		for key, value in v.slots
			counter[value.RuneId]:= counter[value.runeId] ? counter[value.RuneId]+1 : 1
		break	
	}
	info:=""
	for k,v in counter
		info.=v "x" RegExReplace(Globals.Runes[k].Description,"(?P<i>\d+(\.\d+)?)","${i}") "`n"
	return info	
}

agLV:
{
	if ((A_GuiEvent="Normal"))
		ag_GuiManager(A_GuiEvent,A_EventInfo)
	else tooltip
}
