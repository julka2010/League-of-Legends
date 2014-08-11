mcn_GuiManager(o:="",data:="")
{
	static SummonerHwnds:={}
	static ActiveGameSearch:=0
	OnMessage(0x2000,"mcnMessageMonitor")
	if (o="nT")
	{
		if (!IsObject(data))
			data:=[data]
		loop,5
		{
			Gui,Add,Edit,w150 hWndhWnd, % data[a_index]
			SummonerHwnds[a_index]:=hWnd
		}	
		Gui,Add,Button,w150 gGoGoGo default,Go
		;Gui,Show
		return
	}
	else if (o="nS")
	{
		Gui,Submit,Nohide
		for k,v in SummonerHwnds
		{
			GuiControlGet, temp,, % v
			if temp
				Globals.Summoners[a_index]:=temp
		}
		return
	}
	else if (t_pos:=InStr(o,"nLV"))
	{
		o:=SubStr(o,t_pos+3)
		LV_Delete()
		julka_AddListView(o,data,,"LV")
		Gui,+resize
		Gui,Show
		return
	}
	else if (t_pos:=InStr(o,"set"))
	{
		o:=SubStr(o,t_pos+3)
		if (o="Summoner")
			if (IsObject(data))
			{
				for k,v in data
					if (!IsObject(v))
						GuiControl,,% SummonerHwnds[a_index],% v
			}
			else
				GuiControl,,% SummonerHwnds[1],% data
		return	
	}
	return
	GoGoGo:
	{
		mcn_GuiManager("nS")
		Globals.DownloadSummoners("sg")
		Info("gwl")
		return
	}
	
	LVGuiSize:
	{
		julka_Anchor("SysListView321","w-25ph-35p")
		return
	}
}

Guess(summoner:="")
{
	static n:=15
	static r:=1.1
	static b1:=(1-r)/(1-r**n),m:=3/n
	static times:=3
	Data:=Object()
	Ch:={}
	Row:=Column:=0
	l_S:=Globals.Summoners[summoner]
	tp:=l_S.Stats["Champions"][l_S.Stats["Champions"].Maxindex()]["Stats"]["TotalSessionsPlayed"]
	list:=""
	for k,v in l_S.Stats["Champions"]
	{
		if (v["id"]=0)
			v["Stats"]["Probs"]:=0
		else	
			v["Stats"]["Probs"]:=v["Stats"]["TotalSessionsPlayed"]/tp
	}
	Ch:=[]
	for k,v in l_S.Games
	{
		w:=v["participants"][v["participants"].MinIndex()]["Stats"]["Win"]="true" ? 1 : -1
		for key, value in l_S.Stats["Champions"]
		{
			if (value["id"]=v["participants"][v["participants"].MinIndex()]["championId"])
			{
				value["Stats"]["Probs"]*=(1+((k+1)*m*b1*r**k**w))
			}
		}
	}
	for k,v in l_S.Stats["Champions"]
	{
		foo:=a_index
		loop % times
		{
			boo:=a_index
			if (v["Stats"]["Probs"]<l_S.Stats["Champions"][Ch[times-boo+1]]["Stats"]["Probs"])
			{
				if (boo-1)
					Ch[times+2-boo]:=k
				break	
			}
			else if (times^boo)
				Ch[times+1-boo]:=Ch[times-boo]
			else Ch[1]:=foo
		}
	}
	return Ch
}

Info(o:="")
{
	Data:=Object()
	Row:=Column:=0
	for k,v in Globals.Summoners
	{
		M:=SuccessiveMains(k)
		Ch:=Guess(k)
		Data[++Row]:=Object()
		Data[Row][1]:=if InStr(o,"r") ? k : v["name"]
		loop % 3
		{
			Data[++Row]:=Object()
			Column:=1
			if InStr(o,"g")
			{
				Data[Row][++Column]:=Globals.Champions.Data[v.Stats["Champions"][Ch[a_index]]["id"]]["name"]
				Data[Row][++Column]:=v.Stats["Champions"][Ch[a_index]]["Stats"]["TotalSessionsWon"]
				Data[Row][++Column]:=v.Stats["Champions"][Ch[a_index]]["Stats"]["TotalSessionsLost"]
			}
			if InStr(o,"w")
			{
				Data[Row][++Column]:=Globals.Champions.Data[v.Stats["Champions"][M[a_index]]["id"]]["name"]
				Data[Row][++Column]:=v.Stats["Champions"][M[a_index]]["Stats"]["TotalSessionsWon"]
				Data[Row][++Column]:=v.Stats["Champions"][M[a_index]]["Stats"]["TotalSessionsLost"]
			}
			if InStr(o,"l")
			{
				Data[Row][++Column]:=Globals.Champions.Data[v.Stats["Champions"][M[M.Maxindex()+1-a_index]]["id"]]["name"]
				Data[Row][++Column]:=v.Stats["Champions"][M[M.Maxindex()+1-a_index]]["Stats"]["TotalSessionsWon"]
				Data[Row][++Column]:=v.Stats["Champions"][M[M.Maxindex()+1-a_index]]["Stats"]["TotalSessionsLost"]
			}	
		}
	}
	
	;msgbox % st_printArr(Data)
	
	if InStr(o,"r")
		return Data
	else
		columns:="LVSummoner" (InStr(o,"g") ? "|Preffered|Wins|Loses" : "")
				. (InStr(o,"w") ? "|The best mains|Wins|Loses" : "")
				. (InStr(o,"l") ? "|The worst mains|Wins|Loses" : "")
	mcn_GuiManager("nLV" columns,Data)
}

SuccessiveMains(Summoner,o:="")
{
	if (Summoner is number)
		for k,v in Globals.Summoners
			if (v["id"]=Summoner)
				Summoner:=v["name"]
	
	Champions:=Globals.Summoners[Summoner].Stats["Champions"].clone()
	Ch:={}
	
	tp:=Champions[Champions.Maxindex()]["Stats"]["TotalSessionsPlayed"]
	for k,v in Champions
	{
		;msgbox k
		foo:=a_index
		if (v["id"]=0)
			v["Stats"]["SPRate"]:=(2*v["Stats"]["TotalSessionsWon"]-v["Stats"]["TotalSessionsPlayed"])/tp
		else
			v["Stats"]["SPRate"]:=(2*v["Stats"]["TotalSessionsWon"]-v["Stats"]["TotalSessionsPlayed"])*v["Stats"]["TotalSessionsPlayed"]**0.5/tp
		
		loop % foo
		{
			boo:=a_index
			if (v["Stats"]["SPRate"]<Champions[Ch[foo-boo+1]]["Stats"]["SPRate"])
			{	
				Ch[foo+2-boo]:=foo
				break	
			}
			else
				if (foo-boo)
					Ch[foo+1-boo]:=Ch[foo-boo]
				else Ch[1]:=k
		}
	}
	
	;msgbox % "Ch:`n" st_printArr(Ch)
	
	return Ch
}

NNGuiClose:
{
	exitapp
	return
}
