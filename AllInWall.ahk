#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Globals.SetUp()
GuiManager()
return

GuiManager()
{
	Gui,New,+resize
	Gui, Add, Tab2,hwndTabHandle -0x400, Ban helper|Main Champion|Active Game Search
	Gui,Tab,Ban helper
	bans_GuiManager("n")
	ButtonsAtTheBottom()
	Gui,Tab,Main Champion
	mcn_GuiManager("nT")
	ButtonsAtTheBottom()
	Gui,Tab,Active Game Search
	ag_GuiManager("n")
	ButtonsAtTheBottom()
	Gui,Tab
	
	
	Gui, Show, Autosize
}

ButtonsAtTheBottom()
{
	Gui,Add,Button,gUpdate w150,Check for newer version
	Gui,Add,Button,gCookie w150,Buy developer a cookie
}

Update:
	t:=julka_msgbox(0x4,,"Press continue to update to newer version (if such exists)",5000,"Continue","Cancel")
	if (t = "Cancel")
		return
	julka_Update("https://www.dropbox.com/s/1v20aq9olwi2vv4/AllinWall.ahk")
	return 

Cookie:
	if (julka_msgbox(0x4,,"Are you sure you want to buy a cookie for developer?")="Yes")
	{
		msgbox Omfpg!
		msgbox Thank you!
		msgbox ...
		msgbox Here, have a cookie.
	}	
	return	
	
class Globals
{
	static Ini:="Config.ini"
	static Regions:={}
	static Summoners:={}
	Static Champions:={}
	static ActiveGames:={}
	class devAPI
	{
		static key:="a250de7d-eb00-46f9-9496-9d3dbff07754"
		static versionChampion:=1.0
		static versionGame:=1.0
		static versionLeague:=1.0
		static versionStaticData:=1.0
		static versionStats:=1.0
		Static versionSummoner:=1.0
		Static versionTeam:=1.0
		version(class)
		{
			return this["version" RegExReplace(class,"[^A-Za-z]")]		
		}
		Endpoint(r)
		{
			region:=r~="\D" ? r : Regions[r]
			StringLower,region,region
			return region ".api.pvp.net"
		}
		url(region,type,query,command:="")
		{
			Sleep % this.SleepCheck()
			if (t_pos:=InStr(type,"/"))
			{
				extra:=SubStr(type,t_pos+1) (query ? "/" : "")
				type:=SubStr(type,1,t_pos-1)
			}
			else extra:=""
			query.=command ? "/" : ""
			ep:=type="static-data" ? this.Endpoint("global") : this.Endpoint(region)
			;if (type="Summoner")
			;	msgbox % type "`n" this.version(type)
			if (type="static-data")
				result:="https://" this.Endpoint("global") "/api/lol/" type "/" region 
					. "/v" this.version(type) "/" extra . query . command
					. "?api_key=" this.key
			else
				result:="https://" this.Endpoint(region) "/api/lol/" region "/v" this.version(type)
					. "/" type "/" extra . query . command "?api_key=" this.key		
			return result
		}
	}
	;Needed due to request limit
	SleepCheck(times:=10,spread:=1000)
	{
		static lastrequest:=0	;keeps track when this func was last called
		static counter:=0		;keeps track how many times was this func called during last times*spread period of time
								;by default it would be during last 10 secs
		counter:=(counter++)-(A_TickCount-lastrequest)//spread
		counter:=counter > 0 ? counter : 0
		if !(counter>times)
			t:=lastrequest+spread-A_TickCount
		lastrequest:=A_TickCount
		return t>10 ? t : 0
	}
	class specAPI
	{
		port(region)
		{
			if (region="NA")
				return "spectator.na.lol.riotgames.com:8088"
			if ((region="EUW")||(region="EUNE"))
				return "spectator.eu.lol.riotgames.com:8088"
			if ((region="BR")||(region="LAN"))
				return "spectator.br.lol.riotgames.com:8088"
			if ((region="RUS")||(region="TUR"))
				return "spectator.tr.lol.riotgames.com:80"
			if (region="PBE")
				return "spectator.pbe1.lol.riotgames.com:8088"
			if ((region="SK")||(region="TW"))
				return " QFTW1PROXY.kassad.in:8088"
			if (region="SEA")
				return "qfsea1proxy.kassad.in:8088"
		}
		url(region,method,gameID:="",command:="")
		{
			Sleep % this.SleepCheck()
			if gameID
				game:=Globals.platformId(region) "/" gameID+0 "/"
			if command
				command.="/token'"
			result:="http://" this.port(region) "/observer-mode/rest/"
					. (method ? "consumer/" : "featured/") method "/"
					. game command
			return result
		}
	}
	platformId(region)
	{
		;msgbox Hi
		if (region="NA")
			return "NA"
		if (region="EUW")
			return "EUW1"
		if (region="EUNE")
			return "EUN1"
	}
	DownloadActiveGames()
	{
		;url:=this.specAPI.url("euw","")
		;this.ActiveGames:=JSON_ToObj(URLDownloadToVar(url))["gameList"]
		;Globals.DownloadActiveGames()
			;for k,v in Globals.Summoners
			;	if (GameID:=Globals.SearchInActiveGame(v["name"]))
			;		break
			if ("Cancel"=julka_msgbox(1,,"Currently this feature works only if you play in that game.",500))
				return
				
			;Searches for the last log
			file:=""
			CreateTime:=""
			pattern:=Globals.RiotFolder "\Logs\Game - R3d Logs\*.txt"
			loop, %pattern%
			{
				if (A_LoopFileTimeCreated>CreateTime)
				{
					file:=A_LoopFileFullPath
					CreateTime:=A_LoopFileTimeCreated
				}
			}
			;Gets GameId from that
			;loop,Read,%file%
			;	if (t_pos:=InStr(A_LoopReadLine,"GameID:",1))
			;	{
			;		GameID:="0x" RegExReplace(SubStr(A_LoopReadLine,t_pos+StrLen("GameID:")),"^[\s0]*")
			;		break
			;	}
			;url:=Globals.specAPI.url("euw","getGameMetaData",GameID,1)
			;msgbox % url
			t:=0
			loop, Read, %file%
			{
				if (RegExMatch(A_LoopReadLine,"champion\s\((?P<ch>.*?)\).*team(ID)?\s?(?P<team>\d*).*summonername\s\((?P<name>.*?)\)",o))
				{
					Globals.Summoners[++t]:=oname
				}
			}
	}
	SearchInActiveGame(summoner)
	{
		for key,value in this.ActiveGames
			for k,v in value["participants"]
				if (v["SummonerName"]=summoner)
					return key
		return 0
	}
	IDtoKey(id)
	{
		for k,v in this.Summoners
			if (v["id"]=id)
				return k
		return ""
	}
	DownloadSummoners()
	{
		temp:=""
		tooltip "Searching for summoners"
		for k,v in this.Summoners
			temp.=v ? InStr(v,"?") ? "" : v "," : ""
		temp:=SubStr(temp,1,-1)
		t:=this.Summoners:=JSON_ToObj(URLDownloadToVar(url:=this.devAPI.url("euw","summoner/by-name",temp)))
		
		this.DownloadSummonersPages("runes")
		this.DownloadSummonersPages("masteries")
		
		for k,v in this.Summoners
		{
			tooltip % "Downloading " v["name"] "'s ranked stats"
			v.Stats:=JSON_ToObj(URLDownloadToVar(this.devAPI.url("euw","stats/by-summoner",v["id"],"ranked")))
			link:="https://acs.leagueoflegends.com/v1/players?name=" v["name"] "&region=EUW"
			temp:=JSON_ToObj(URLDownloadToVar(link))
			v["accountId"]:=temp["accountId"]
			v["platformId"]:=temp["platformId"]
			b:=0,e:=15
			link:="https://acs.leagueoflegends.com/v1/stats/player_history/" v["platformId"] "/" v["accountId"] "?begIndex=" b "&endIndex=" e "&queue=4"
			v["Games"]:=JSON_ToObj(URLDownloadToVar(link))["games"]["games"]
			for key, value in v["Games"]
				value.Remove("participantIdentities")
			v["Games"].full:=v["Games"].full ? v["Games"].full+e-b : e-b
		}
		tooltip
		return
	}
	DownloadSummonersPages(p_type)
	{
		tooltip "Downloading " p_type " pages"
		temp:=""
		for k,v in this.Summoners
			temp.=v["id"] ? v["id"] "," : ""
		temp:=SubStr(temp,1,-1)
		temp:=JSON_ToObj(URLDownloadToVar(url:=this.devAPI.url("euw","summoner",temp,p_type)))
		for k,v in temp
			this.Summoners[this.IDtoKey(v["summonerId"])][p_type]:=v["pages"]
	}
	DownloadChampions()
	{
		url:=this.devAPI.url("euw","static-data/champion","")
		this.Champions:=JSON_ToObj(URLDownloadToVar(url))
		t:={}
		for k,v in this.Champions.data
		{	
			v.Remove("key")
			t[v["id"]]:=v
			v:=""
		}	
		for k,v in t
			this.Champions.data[k]:=v
		t:=""
	}
	SetUp()
	{
		;Reads and updates as needed the configuration file
		
		;Reads/Gets path of League of Legends folder
		IniRead,temp,% this.Ini,Static,RiotFolderPath
		if temp in ,ERROR
		{
			FileSelectFolder,temp,,2,Select League of Legends folder
			this.RiotFolder:=temp
			IniWrite,% this.RiotFolder,% this.Ini,Static,RiotFolderPath
		}
		else this.RiotFolder:=temp
		
		;Reads/Gets supported League of Legends regions
		IniRead,temp,% this.Ini,Regions
		if temp in ,ERROR
		{
			this.Regions.Insert(0,"All","BR","EUNE","EUW","KR","LAS","LAN","NA","OCE","TR","RU","Global")
			for k,v in this.Regions
				IniWrite,%v%,% this.Ini,Regions,%k%
		}
		else
			loop,Parse,temp,`n,`r
			{
				t:=StrSplit(A_LoopField,"=")
				this.Regions[t[1]]:=t[2]
			}
		
		;Reads/Gets Riot Developer's API methods' versions
		IniRead,temp,% this.Ini,Riot Developer's API
		if temp in ,ERROR
		{
			IniWrite,1.2,% this.Ini,Riot Developer's API,versionChampion
			IniWrite,1.3,% this.Ini,Riot Developer's API,versionGame
			IniWrite,2.4,% this.Ini,Riot Developer's API,versionLeague
			IniWrite,1.2,% this.Ini,Riot Developer's API,versionStaticData
			IniWrite,1.3,% this.Ini,Riot Developer's API,versionStats
			IniWrite,1.4,% this.Ini,Riot Developer's API,versionSummoner
			IniWrite,2.3,% this.Ini,Riot Developer's API,versionTeam
		}
		else
			loop,Parse,temp,`n,`r
			{
				t:=StrSplit(A_LoopField,"=")
				this.DevAPI[t[1]]:=t[2]
			}
		
		IniRead,temp,% this.Ini,Bans
		if temp not in ,ERROR
			bans_GuiManager("set",temp)
		IniRead,temp,% this.Ini,Main Champion,Summoners
		if temp not in ,ERROR
		{
			loop,Parse,temp,csv
				Globals.Summoners[a_index]:=A_LoopField
		}
		
		;Downloads static data from the internet
		tooltip Downloading champions data
		this.DownloadChampions()
		tooltip
	}
}

class Champion
{
	__New(n,g,p,w,r:=0,t:=0)
	{
		this.Name:=n
		this.Games:=g
		this.Popularity:=p
		this.Wins:=w
		this.Loses:=g-w
		this.Ratio:=this.Wins/this.Games
		;msgbox % this.Ratio "`n" this.Ratio*2 "`n" this.Popularity "`n" p
		this.BanWorthy:=(this.Ratio*2-1)*this.Popularity
	}
}

F5::reload
return
