ag_GuiManager(o:="",data:="")
{
	if (o="n")
	{
		Gui,Add,Button,w150 gActiveGame,Search for active game
		Gui,Show
		return
	}
	else if (o="u")
	{
		columns:="Summoner Name|Runes|Masteries"
		LV_Delete()
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
		julka_AddListView(columns,data,"Count11 R11 gagLV AltSubmit w372")
		;OnMessage(0x200,"ag_MessageMonitor")
		return
	}
	else if (o="Normal")
	{
		if !(LV_GetText(summoner, data))
			return
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
		tooltip % info
		return
	}
	return
	
	ActiveGame:
	{	
		if ("Cancel"=julka_msgbox(1,,"Currently this feature works only if you play in that game."))
			return
		Globals.DownloadActiveGames()
		Globals.DownloadSummoners("p")
		ag_GuiManager("u")
		return
	}
}

agLV:
{
	if ((A_GuiEvent="Normal"))
		ag_GuiManager(A_GuiEvent,A_EventInfo)
	else tooltip
}

ag_MessageMonitor(wParam,lParam,msg,hwnd)
{
	Send 0x84
	tooltip % wParam "`n" lParam "`n" msg "`n" hwnd
}
