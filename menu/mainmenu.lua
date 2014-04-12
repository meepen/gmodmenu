--[[__                                       _     
 / _| __ _  ___ ___ _ __  _   _ _ __   ___| |__  
| |_ / _` |/ __/ _ \ '_ \| | | | '_ \ / __| '_ \ 
|  _| (_| | (_|  __/ |_) | |_| | | | | (__| | | |
|_|  \__,_|\___\___| .__/ \__,_|_| |_|\___|_| |_|
				   |_| 2012 --]]


include( 'background.lua' )
include( 'menu_singleplayer.lua' )

concommand.Add("lua_run_mn", function(_, _, _, ex) RunStringEx( ex, "LuaCmd" ) end)

pnlMainMenu = nil

local PANEL = {}

local HEIGHT = 28

surface.CreateFont("MainMenuFont", {
	font		= "BudgetLabel";
	size		= HEIGHT;
	weight		= 500;
	blursize	= 0;
	scanlines	= 0;
	antialias	= true;
	outline		= false;
});

surface.CreateFont("MainMenuFont02", {
	font		= "CoolVetica";
	size		= 38;
	weight		= 500;
	blursize	= 0;
	scanlines	= 0;
	antialias	= true;
	outline		= false;
});

surface.CreateFont("MainMenuFont03", {
	font		= "Roboto-Black";
	size		= 18;
	weight		= 100;
	blursize	= 0;
	scanlines	= 0;
	antialias	= false;
	outline		= true;
});

local PANEL_ALIGN_CENTERLEFT	= 0;
local PANEL_ALIGN_BOTTOMRIGHT	= 1;


function PANEL:Init()
	
	self:Dock( FILL )
	self:SetKeyboardInputEnabled( true );
	self:SetMouseInputEnabled( true );
	
	self.m_imgGMod		= vgui.Create( "DHTML", self )
	self.m_imgGMod:SetHTML( "<div align=\"center\"><img style=\"height:149px;width:201px\" src=\"asset://garrysmod/html/img/gmod_logo_brave.png\" /></div>" )
	self.m_imgGMod:SetWide( 250 )
	self.m_imgGMod:SetTall( 200 )
	self.m_imgGMod:SetPos( ScrW() / 2 - 125, 50 )
	
	self.m_txtGMod		= vgui.Create( "DLabel", self )
	self.m_txtGMod:SetFont( "MainMenuFont02" )
	self.m_txtGMod:SetText( "Garry's Mod" )
	self.m_txtGMod:SetTextColor( Color( 255, 255, 255, 255 ) )
	surface.SetFont( "MainMenuFont02" )
	local w, h = surface.GetTextSize( "Garry's Mod" )
	self.m_txtGMod:SetPos( ScrW() / 2 - w / 2, 210 )
	self.m_txtGMod:SetWide( w )
	self.m_txtGMod:SetTall( h )
	
	self.m_txtVersion 	= vgui.Create( "DLabel", self )
	self.m_txtVersion:SetFont( "MainMenuFont03" )
	self.m_txtVersion:SetText( "" )
	self.m_txtVersion:SetTextColor( Color( 255, 255, 255, 255 ) )
	
	
	local SPACING = 5;
	self.m_btnServer 	= self:AddButton( "Multiplayer", "MainMenuFont", false, 50, ScrH() / 2, PANEL_ALIGN_CENTERLEFT )
	self.m_btnOptions 	= self:AddButton( "Options", "MainMenuFont", false, 50, ScrH() / 2 + HEIGHT + SPACING, PANEL_ALIGN_CENTERLEFT )
	self.m_btnSingle	= self:AddButton( "Single Player", "MainMenuFont", false, 50, ScrH() / 2 - HEIGHT - SPACING, PANEL_ALIGN_CENTERLEFT )
	self.m_btnExit		= self:AddButton( "Exit", "MainMenuFont", false, 50, ScrH() / 2 + (HEIGHT + SPACING) * 2, PANEL_ALIGN_CENTERLEFT )
	
	function self.m_btnServer:DoClick()
		pnlMainMenu:OpenServerList()
	end
	
	function self.m_btnExit:DoClick()
		RunGameUICommand( "Quit" )
	end
	
	function self.m_btnOptions:DoClick()
		RunGameUICommand( "OpenOptionsDialog" )
	end
	
	function self.m_btnSingle.DoClick() 
		if ( not IsValid( self.m_pSinglePlayer ) ) then
			self.m_pSinglePlayer = vgui.Create( "SinglePlayerPanel", self )
		end
	end
	
	self.m_pServers	= {}

	self:MakePopup()
	self:SetPopupStayAtBack( true )
	--self:MoveToBack()
	
end

function PANEL:ScreenshotScan( folder )

	local bReturn = false;

	local Screenshots = file.Find( folder .. "*.jpg", "GAME" )		
	for k, v in RandomPairs( Screenshots ) do

		AddBackgroundImage( folder..v )
		bReturn = true
	
	end

	return bReturn;

end

function PANEL:Paint()

	DrawBackground()

	if ( self.IsInGame != IsInGame() ) then
	
		self.IsInGame = IsInGame();
		
		if ( self.IsInGame ) then
		
			if ( IsValid( self.InnerPanel ) ) then self.InnerPanel:Remove() end
			--self.HTML:QueueJavascript( "SetInGame( true )" );
		
		else 
		
			--self.HTML:QueueJavascript( "SetInGame( false )" );
			
		end
		
	end

end

function PANEL:RefreshContent()

	self:RefreshGamemodes()
	self:RefreshAddons()

end

function PANEL:RefreshGamemodes()

	self:UpdateBackgroundImages()
	
	--[[
	local json = util.TableToJSON( engine.GetGamemodes() );
	
	self.HTML:QueueJavascript( "UpdateGamemodes( "..json.." )" );
	self.HTML:QueueJavascript( "UpdateCurrentGamemode( '"..engine.ActiveGamemode().."' )" );
	]]
end

function PANEL:RefreshAddons()

	-- TODO

end


function PANEL:UpdateBackgroundImages()

	ClearBackgroundImages()

	--
	-- If there's screenshots in gamemodes/<gamemode>/backgrounds/*.jpg use them
	--
	if ( !self:ScreenshotScan( "gamemodes/" ..engine.ActiveGamemode() .. "/backgrounds/" ) ) then 
	
		--
		-- If there's no gamemode specific here we'll use the default backgrounds
		--
		self:ScreenshotScan( "backgrounds/" )

	end


	ChangeBackground( engine.ActiveGamemode() )

end

function PANEL:AddButton( text, font, bg, x, y, align, col)
	local btn = vgui.Create( "DButton", self )
	
	btn:SetFont( font )
	btn:SetText( text )
	btn:SetDrawBackground( bg )
	btn.m_colTextDef 	= ( col or Color( 200, 200, 200, 255 ) )
	btn.m_colText		= btn.m_colTextDef
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local rx, ry = x, y
	
	if ( align == PANEL_ALIGN_CENTERLEFT ) then
		ry = ry - h / 2
	elseif ( align == PANEL_ALIGN_BOTTOMRIGHT ) then
		rx = rx - w
		ry = ry - h
	end
	
	btn:SetPos( rx, ry )
	btn:SetTall( h )
	btn:SetWide( w )
	
	function btn:Think()
		local ishv = self:IsHovered()
		if ( not self.m_bWasHovered and ishv ) then
			surface.PlaySound( "garrysmod/ui_hover.wav" )
			local r = self.m_colTextDef
			self.m_colText = Color( r.r + 50, r.g + 50, r.b + 50, r.a + 50 )
			self:SetTextColor( self.m_colText )
		elseif ( not ishv and self.m_bWasHovered ) then
			self.m_colText = self.m_colTextDef
			self:SetTextColor( self.m_colText )
		end
		
		self.m_bWasHovered = ishv
	end
	
	print(h, w, rx, ry);
	
	return btn
end

function PANEL:Call( js ) --deprecated

	MsgN( "PANEL:Call() called with '"..js.."'...\n"..debug.traceback() )
	--self.HTML:QueueJavascript( js );

end

function PANEL:OnLanguageChanged( lang )
	
end

function PANEL:OnLanguagesUpdated( langs )
	
end

function PANEL:OnVersionUpdated( szVersion, szBranch )
	local text = szVersion
	self.m_txtVersion:SetText( text )
	surface.SetFont( "MainMenuFont03" )
	local w, h = surface.GetTextSize( text )
	self.m_txtVersion:SetPos( ScrW() / 2 - w / 2, 250 )
	self.m_txtVersion:SetWide( w )
	self.m_txtVersion:SetTall( h )
end

function PANEL:OnServerQueried( serv, type )
	
end

function PANEL:OnSubscriptionsUpdated( subscriptions )
	
end

function PANEL:OnPlayerListUpdated( serverip, plys )
	
end

function PANEL:OnServerSettingsUpdated( settings )
	
end

function PANEL:OnMapListUpdated( maplist )
	
end

function PANEL:OnGamesUpdated( games )
	
end


function PANEL:OpenServerList()
	if ( not pnlServList or not IsValid( pnlServList ) ) then
		pnlServList = vgui.Create( "ServerListPanel" )
	end
	if ( not self.m_bQuerying ) then
		self.m_bQuerying = true
		GetServers( "internet" )
		GetServers( "lan" )
		GetServers( "history" )
		GetServers( "favorite" )
		--history lan internet favorite
	end
end

function PANEL:AddServer( info, type )
	self.m_pServers[ info.address ] = info
	self:OnServerQueried( info, type )
end


vgui.Register( "MainMenuPanel", PANEL, "EditablePanel" )

function UpdateSteamName( id, time )

	if ( !id ) then return end

	if ( !time ) then time = 0.2 end

	local name = steamworks.GetPlayerName( id )
	if ( name != "" && name != "[unknown]" ) then

		pnlMainMenu:Call( "SteamName( \""..id.."\", \""..name.."\" )" );
		return;

	end

	steamworks.RequestPlayerInfo( id )
	timer.Simple( time, function() UpdateSteamName( id, time + 0.2 ) end )

end

---
-- Called from JS when starting a new game
--
function UpdateMapList()

	if ( !istable( g_MapListCategorised ) ) then return end

	pnlMainMenu:OnMapListUpdated( g_MapListCategorised )
	
	--json = util.TableToJSON( g_MapListCategorised );
	--if ( !isstring( json ) ) then return end

	--pnlMainMenu:Call( "UpdateMaps("..json..")" );

end

--
-- Called from JS when starting a new game
--
function UpdateServerSettings()

	local array = 
	{
		hostname	= GetConVarString( "hostname" ),
		sv_lan		= GetConVarString( "sv_lan" )
	}

	local settings_file = file.Read( "gamemodes/"..engine.ActiveGamemode().."/"..engine.ActiveGamemode()..".txt", true )
		
	if ( settings_file ) then

		local Settings = util.KeyValuesToTable( settings_file )

		if ( Settings.settings ) then

			array.settings = Settings.settings;

			for k, v in pairs( array.settings ) do
				v.Value = GetConVarString( v.name );
			end

		end

	end

	--local json = util.TableToJSON( array );
	--pnlMainMenu:Call( "UpdateServerSettings("..json..")" );
	pnlMainMenu:OnServerSettingsUpdated( array )

end

--
-- Get the player list for this server
--
function GetPlayerList( serverip )

	serverlist.PlayerList( serverip, function( tbl )
	
		pnlMainMenu:OnPlayerListUpdated( serverip, tbl )

		--local json = util.TableToJSON( tbl );
		--pnlMainMenu:Call( "SetPlayerList( '"..serverip.."', "..json..")" )

	end )

end

local Servers = {}

function GetServers( type )


	local data =
	{
		Finished = function()
			
		end,

		Callback = function( ping , name, desc, map, players, maxplayers, botplayers, pass, lastplayed, address, gamemode, workshopid )

			pnlMainMenu:AddServer({
				["name"]		= name;
				["desc"]		= desc;
				["ping"]		= ping;
				["map"]			= map;
				["players"]		= players;
				["maxpl"]		= maxplayers;
				["botpl"]		= botplayers;
				["passprot"]	= pass;
				["lastplayed"]	= lastplayed;
				["address"]		= address;
				["gm"]			= gamemode;
				["wsid"]		= workshopid;
				["pl"]			= tostring( players + botplayers ) .. "/" .. maxplayers;
				["type"]		= type;
			}, type);
		end,

		Type = type,
		GameDir = 'garrysmod',
		AppID = 4000,
	}

	serverlist.Query( data )	

end

--
-- Called from the engine any time the language changes
--
function LanguageChanged( lang )

	if ( !IsValid( pnlMainMenu ) ) then return end

	pnlMainMenu:OnLanguageChanged( lang );
	UpdateLanguages();
	--pnlMainMenu:Call( "UpdateLanguage( '"..lang.."' )" );

end

--
--
--
function UpdateGames()

	local games = engine.GetGames()
	
	pnlMainMenu:OnGamesUpdated( game )
	-- local json = util.TableToJSON( games );

	-- pnlMainMenu:Call( "UpdateGames( "..json..")" );	

end

function UpdateSubscribedAddons()

	local subscriptions = engine.GetAddons()
	--local json = util.TableToJSON( subscriptions );

	--pnlMainMenu:Call( "subscriptions.Update( "..json.." )" );
	pnlMainMenu:OnSubscriptionsUpdated( subscriptions );

end

hook.Add( "GameContentChanged", "RefreshMainMenu", function()

	if ( !IsValid( pnlMainMenu ) ) then return end

	pnlMainMenu:RefreshContent()

	UpdateGames();
	UpdateServerSettings();
	UpdateSubscribedAddons();

	-- We update the maps with a delay because another hook updates the maps on content changed
	-- so we really only want to update this after that.
	timer.Simple( 0.5, function() UpdateMapList(); end )

end );

--
-- Initialize
--
timer.Simple( 0, function()

	pnlMainMenu = vgui.Create( "MainMenuPanel" );
	pnlMainMenu:OnVersionUpdated( VERSIONSTR, BRANCH );
	--pnlMainMenu:Call( "UpdateVersion( '"..VERSIONSTR.."', '"..BRANCH.."' )" );

	local language = GetConVarString( "gmod_language" )
	pnlMainMenu:OnLanguageChanged( language )

	hook.Run( "GameContentChanged" )

end )