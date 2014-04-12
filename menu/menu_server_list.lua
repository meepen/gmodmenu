
local PANEL = {}

local function GetTextSize(font, text)
	surface.SetFont( font )
	return surface.GetTextSize( text )
end

surface.CreateFont("ServerListFont", {
	font		= "BudgetLabel";
	size		= 12;
	weight		= 500;
	blursize	= 0;
	scanlines	= 0;
	antialias	= true;
	outline		= false;
});

local szFontName = "ServerListFont"

PANEL.m_pColumns = {
	[1] = "name";
	[2] = "map";
	[3] = "pl";
	[4] = "gm";
	[5] = "ping";
	[6] = "passprot";
}

function PANEL:Init()
	self:SetTitle( "Server List" )
	self.lblTitle:SetTextColor( Color( 0, 0, 0, 255 ) ) 
	
	self.m_pDone			= {}
	self.m_nAmount			= 0
	self.m_nMaxAmount		= 600
	self.m_nColumn			= 5
	self.m_bDescend			= false
	self.m_pServs			= pnlMainMenu.m_pServers
	self.m_pCurrent			= self.m_pServs
	self:UpdateFavorites()
	
	self:SetPos( 50, 50 )
	self:SetTall( ScrW() / 3 )
	self:SetWide( ScrW() / 3 * 2 )
	
	self.m_pContainer = vgui.Create( "EditablePanel", self )
	self.m_pContainer:SetPos( 5, 23 )
	self.m_pContainer:SetTall( self:GetTall() - 108 ) -- 23 + 85
	self.m_pContainer:SetWide( self:GetWide() - 10 ) -- 5 * 2 (border)
	self.m_pContainer.Paint = function() end
	
	self.m_pList = vgui.Create( "DListView", self.m_pContainer )
	self.m_pList:AddColumn( "Server Name" )
	self.m_pList:AddColumn( "Map" )
	self.m_pList:AddColumn( "Players" )
	self.m_pList:AddColumn( "Gamemode" )
	self.m_pList:AddColumn( "Ping" )
	self.m_pList:AddColumn( "Pass" )
	self.m_pList:SetMultiSelect( false )
	self.m_pList.OnRowRightClick = self.OnRowRightClick
	local default_width = 520
	local width = self.m_pContainer:GetWide() - 80
	self.m_pList.Columns[1]:SetWide( 239 / default_width * width )
	self.m_pList.Columns[2]:SetWide( 138 / default_width * width )
	self.m_pList.Columns[3]:SetWide( 45 )
	self.m_pList.Columns[4]:SetWide( 108 / default_width * width )
	self.m_pList.Columns[5]:SetWide( 35 )
	self.m_pList.Columns[6]:SetWide( 35 )
	self.m_pList.SortByColumn = self.SortByColumn;
	
	self.m_pSorter = vgui.Create( "EditablePanel", self )
	self.m_pSorter.Paint = function() end
	self.m_pSorter:SetPos( 0, self:GetTall() - 85 )
	self.m_pSorter:SetTall( 85 )
	self.m_pSorter:SetWide( self:GetWide() )
	
	self.m_pSorter.m_pServNames = vgui.Create( "DCheckBox", self.m_pSorter )
	self.m_pSorter.m_pServNames:SetValue( 0 )
	self.m_pSorter.m_pServNames:SetPos( 10, 5 )
	self.m_pSorter.m_pServNames.OnChange = self.OnFilterChange
	self.m_pSorter.m_pServName01 = vgui.Create( "DLabel", self.m_pSorter )
	self.m_pSorter.m_pServName01:SetFont( szFontName )
	self.m_pSorter.m_pServName01:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pServName01:SetText( "Only show server with names" )
	self.m_pSorter.m_pServName01:SetPos( self.m_pSorter.m_pServNames:GetWide() + 10 + 7, 5 )
	local w, h = GetTextSize( szFontName, "Only show server with names" )
	self.m_pSorter.m_pServName01:SetWide( w )
	self.m_pSorter.m_pServName01:SetTall( h )
	
	self.m_pSorter.m_pServName02 = vgui.Create( "DComboBox", self.m_pSorter )
	self.m_pSorter.m_pServName02:SetValue( "containing" )
	self.m_pSorter.m_pServName02:AddChoice( "containing" )
	self.m_pSorter.m_pServName02:AddChoice( "not containing" )
	local x, y = self.m_pSorter.m_pServName01:GetPos()
	self.m_pSorter.m_pServName02:SetPos( x + w + 10, y - 1 )
	self.m_pSorter.m_pServName02:SetTall( h + 2 )
	w, h = GetTextSize( szFontName, "not containing" ) -- longest
	self.m_pSorter.m_pServName02:SetFont( szFontName )
	self.m_pSorter.m_pServName02:SetTextColor( Color( 0, 0, 0, 255 ))
	self.m_pSorter.m_pServName02:SetWide( w + 24 )
	self.m_pSorter.m_pServName02.OnSelect = self.OnFilterChange
	
	self.m_pSorter.m_pServName03 = vgui.Create( "DTextEntry", self.m_pSorter )
	x, y = self.m_pSorter.m_pServName02:GetPos()
	self.m_pSorter.m_pServName03:SetPos( x + w + 24, y )
	self.m_pSorter.m_pServName03:SetWide( self:GetWide() - x - w - 24 - 10 )
	self.m_pSorter.m_pServName03:SetTall( h + 2 )
	self.m_pSorter.m_pServName03:SetFont( szFontName )
	self.m_pSorter.m_pServName03:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pServName03:SetText( "" )
	self.m_pSorter.m_pServName03.OnChange = self.OnFilterChange
	
	
	self.m_pSorter.m_pGMNames = vgui.Create( "DCheckBox", self.m_pSorter )
	self.m_pSorter.m_pGMNames:SetValue( 0 )
	self.m_pSorter.m_pGMNames:SetPos( 10, 20 )
	self.m_pSorter.m_pGMNames.OnChange = self.OnFilterChange
	self.m_pSorter.m_pGMName01 = vgui.Create( "DLabel", self.m_pSorter )
	self.m_pSorter.m_pGMName01:SetFont( szFontName )
	self.m_pSorter.m_pGMName01:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pGMName01:SetText( "Only show servers with gamemode names" )
	self.m_pSorter.m_pGMName01:SetPos( self.m_pSorter.m_pGMNames:GetWide() + 10 + 7, 20 )
	w, h = GetTextSize( szFontName, "Only show servers with gamemode names" )
	self.m_pSorter.m_pGMName01:SetWide( w )
	self.m_pSorter.m_pGMName01:SetTall( h )
	
	self.m_pSorter.m_pGMName02 = vgui.Create( "DComboBox", self.m_pSorter )
	self.m_pSorter.m_pGMName02:SetValue( "containing" )
	self.m_pSorter.m_pGMName02:AddChoice( "containing" )
	self.m_pSorter.m_pGMName02:AddChoice( "not containing" )
	x, y = self.m_pSorter.m_pGMName01:GetPos()
	self.m_pSorter.m_pGMName02:SetPos( x + w + 10, y - 1 )
	self.m_pSorter.m_pGMName02:SetTall( h + 2 )
	w, h = GetTextSize( szFontName, "not containing" ) -- longest
	self.m_pSorter.m_pGMName02:SetFont( szFontName )
	self.m_pSorter.m_pGMName02:SetTextColor( Color( 0, 0, 0, 255 ))
	self.m_pSorter.m_pGMName02:SetWide( w + 24 )
	self.m_pSorter.m_pGMName02.OnSelect = self.OnFilterChange
	
	self.m_pSorter.m_pGMName03 = vgui.Create( "DTextEntry", self.m_pSorter )
	x, y = self.m_pSorter.m_pGMName02:GetPos()
	self.m_pSorter.m_pGMName03:SetPos( x + w + 24, y )
	self.m_pSorter.m_pGMName03:SetWide( self:GetWide() - x - w - 24 - 10 )
	self.m_pSorter.m_pGMName03:SetTall( h + 2 )
	self.m_pSorter.m_pGMName03:SetFont( szFontName )
	self.m_pSorter.m_pGMName03:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pGMName03:SetText( "" )
	self.m_pSorter.m_pGMName03.OnChange = self.OnFilterChange
	
	
	self.m_pSorter.m_pPing = vgui.Create( "DCheckBox", self.m_pSorter )
	self.m_pSorter.m_pPing:SetValue( 0 )
	self.m_pSorter.m_pPing:SetPos( 10, 35 )
	self.m_pSorter.m_pPing.OnChange = self.OnFilterChange
	self.m_pSorter.m_pPing01 = vgui.Create( "DLabel", self.m_pSorter )
	self.m_pSorter.m_pPing01:SetFont( szFontName )
	self.m_pSorter.m_pPing01:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pPing01:SetText( "Only show servers with ping" )
	self.m_pSorter.m_pPing01:SetPos( self.m_pSorter.m_pPing:GetWide() + 10 + 7, 35 )
	w, h = GetTextSize( szFontName, "Only show servers with ping" )
	self.m_pSorter.m_pPing01:SetWide( w )
	self.m_pSorter.m_pPing01:SetTall( h )
	
	self.m_pSorter.m_pPing02 = vgui.Create( "DComboBox", self.m_pSorter )
	self.m_pSorter.m_pPing02:SetValue( "less than" )
	self.m_pSorter.m_pPing02:AddChoice( "less than" )
	self.m_pSorter.m_pPing02:AddChoice( "more than" )
	x, y = self.m_pSorter.m_pPing01:GetPos()
	self.m_pSorter.m_pPing02:SetPos( x + w + 10, y - 1 )
	self.m_pSorter.m_pPing02:SetTall( h + 2 )
	w, h = GetTextSize( szFontName, "more than" ) -- longest
	self.m_pSorter.m_pPing02:SetFont( szFontName )
	self.m_pSorter.m_pPing02:SetTextColor( Color( 0, 0, 0, 255 ))
	self.m_pSorter.m_pPing02:SetWide( w + 24 )
	self.m_pSorter.m_pPing02.OnSelect = self.OnFilterChange
	
	self.m_pSorter.m_pPing03 = vgui.Create( "DTextEntry", self.m_pSorter )
	x, y = self.m_pSorter.m_pPing02:GetPos()
	self.m_pSorter.m_pPing03:SetPos( x + w + 24, y )
	self.m_pSorter.m_pPing03:SetWide( self:GetWide() - x - w - 24 - 10 )
	self.m_pSorter.m_pPing03:SetTall( h + 2 )
	self.m_pSorter.m_pPing03:SetFont( szFontName )
	self.m_pSorter.m_pPing03:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pPing03:SetText( "" )
	self.m_pSorter.m_pPing03.OnChange = self.OnFilterChange
	
	
	self.m_pSorter.m_pMapNames = vgui.Create( "DCheckBox", self.m_pSorter )
	self.m_pSorter.m_pMapNames:SetValue( 0 )
	self.m_pSorter.m_pMapNames:SetPos( 10, 50 )
	self.m_pSorter.m_pMapNames.OnChange = self.OnFilterChange
	self.m_pSorter.m_pMapName01 = vgui.Create( "DLabel", self.m_pSorter )
	self.m_pSorter.m_pMapName01:SetFont( szFontName )
	self.m_pSorter.m_pMapName01:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pMapName01:SetText( "Only show servers with map names" )
	self.m_pSorter.m_pMapName01:SetPos( self.m_pSorter.m_pMapNames:GetWide() + 10 + 7, 50 )
	w, h = GetTextSize( szFontName, "Only show servers with map names" )
	self.m_pSorter.m_pMapName01:SetWide( w )
	self.m_pSorter.m_pMapName01:SetTall( h )
	
	self.m_pSorter.m_pMapName02 = vgui.Create( "DComboBox", self.m_pSorter )
	self.m_pSorter.m_pMapName02:SetValue( "containing" )
	self.m_pSorter.m_pMapName02:AddChoice( "containing" )
	self.m_pSorter.m_pMapName02:AddChoice( "not containing" )
	x, y = self.m_pSorter.m_pMapName01:GetPos()
	self.m_pSorter.m_pMapName02:SetPos( x + w + 10, y - 1 )
	self.m_pSorter.m_pMapName02:SetTall( h + 2 )
	w, h = GetTextSize( szFontName, "not containing" ) -- longest
	self.m_pSorter.m_pMapName02:SetFont( szFontName )
	self.m_pSorter.m_pMapName02:SetTextColor( Color( 0, 0, 0, 255 ))
	self.m_pSorter.m_pMapName02:SetWide( w + 24 )
	self.m_pSorter.m_pMapName02.OnSelect = self.OnFilterChange
	
	self.m_pSorter.m_pMapName03 = vgui.Create( "DTextEntry", self.m_pSorter )
	x, y = self.m_pSorter.m_pMapName02:GetPos()
	self.m_pSorter.m_pMapName03:SetPos( x + w + 24, y )
	self.m_pSorter.m_pMapName03:SetWide( self:GetWide() - x - w - 24 - 10 )
	self.m_pSorter.m_pMapName03:SetTall( h + 2 )
	self.m_pSorter.m_pMapName03:SetFont( szFontName )
	self.m_pSorter.m_pMapName03:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pMapName03:SetText( "" )
	self.m_pSorter.m_pMapName03.OnChange = self.OnFilterChange
	
	self.m_pSorter.m_pPeople = vgui.Create( "DCheckBox", self.m_pSorter )
	self.m_pSorter.m_pPeople:SetPos( 10, 65 )
	self.m_pSorter.m_pPeople.OnChange = self.OnFilterChange
	self.m_pSorter.m_pPeople01 = vgui.Create( "DLabel", self.m_pSorter )
	self.m_pSorter.m_pPeople01:SetFont( szFontName )
	self.m_pSorter.m_pPeople01:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.m_pSorter.m_pPeople01:SetText( "Show only with people on it" )
	w, h = GetTextSize( szFontName, "Show only with people on it" )
	self.m_pSorter.m_pPeople01:SetWide( w )
	self.m_pSorter.m_pPeople01:SetTall( h )
	self.m_pSorter.m_pPeople01:SetPos( 10 + self.m_pSorter.m_pPeople:GetWide() + 7, 65 )
	
	self.m_pSorter.m_pType	= vgui.Create( "DComboBox", self.m_pSorter )
	self.m_pSorter.m_pType:SetValue( "internet" )
	self.m_pSorter.m_pType:AddChoice( "lan" )
	self.m_pSorter.m_pType:AddChoice( "history" )
	self.m_pSorter.m_pType:AddChoice( "favorite" )
	self.m_pSorter.m_pType:AddChoice( "internet" )
	x, y	= self.m_pSorter.m_pPeople01:GetPos()
	w		= self.m_pSorter.m_pPeople01:GetWide()
	self.m_pSorter.m_pType:SetPos( x + w + 5, y - 1 )
	self.m_pSorter.m_pType:SetFont( szFontName )
	w, h 	= GetTextSize( szFontName, "favorite" )
	self.m_pSorter.m_pType:SetWide( w + 24 )
	self.m_pSorter.m_pType:SetTall( h + 2 )
	self.m_pSorter.m_pType.OnSelect = self.OnFilterChange
	
	
	
	self.m_pList:Dock( FILL )
	self:MakePopup()
end

function PANEL:Paint()
	surface.SetDrawColor( 170, 170, 170, 255 )
	surface.DrawRect( 2, 2, self:GetWide() - 4, self:GetTall() - 4 )
	surface.SetDrawColor( 170, 170, 170, 150 )
	surface.DrawOutlinedRect( 1, 1, self:GetWide() - 2, self:GetTall() - 2 )
	surface.SetDrawColor( 170, 170, 170, 50 )
	surface.DrawOutlinedRect( 0, 0, self:GetWide(), self:GetTall() )
end

function PANEL:UpdateFavorites()
	self.m_pFavorites = string.Explode( " ", cookie.GetString( "favorites", "" ) ) -- no worries, this is menu state only ;)
end

function PANEL:ShouldFilterServer( serv )
	local bret = false
	if ( not bret and self.m_pSorter.m_pServNames:GetChecked() ) then
		local b = string.find( string.lower( serv.name ), string.lower( self.m_pSorter.m_pServName03:GetValue() ) )
		if ( self.m_pSorter.m_pServName02:GetValue() == "containing" ) then
			bret = not b
		else
			bret = b
		end
	end
	if ( not bret and self.m_pSorter.m_pGMNames:GetChecked() ) then
		local b = string.find( string.lower( serv.desc ), string.lower( self.m_pSorter.m_pGMName03:GetValue() ) )
		if ( self.m_pSorter.m_pGMName02:GetValue() == "containing" ) then
			bret = not b
		else
			bret = b
		end
	end
	if ( not bret and self.m_pSorter.m_pPing:GetChecked() ) then
		local b = tonumber( serv.ping )
		if ( self.m_pSorter.m_pPing02:GetValue() == "more then" ) then
			bret = b < ( tonumber( self.m_pSorter.m_pPing03:GetValue() ) or 0 )
		else
			bret = b > ( tonumber( self.m_pSorter.m_pPing03:GetValue() ) or 0 )
		end
	end
	if ( not bret and self.m_pSorter.m_pMapNames:GetChecked() ) then
		local b = string.find( string.lower( serv.map ), string.lower( self.m_pSorter.m_pMapName03:GetValue() ) )
		if ( self.m_pSorter.m_pMapName02:GetValue() == "containing" ) then
			bret = not b
		else
			bret = b
		end
	end
	if ( not bret and self.m_pSorter.m_pPeople:GetChecked() ) then
		bret = tonumber( serv.players ) <= 0
	end
	if ( not bret and self.m_pSorter.m_pType:GetValue() ~= serv.type ) then
		if( not ( self.m_pSorter.m_pType:GetValue() == "favorite" and table.HasValue( self.m_pFavorites, serv.address ) ) ) then
			bret = true
		end
	end
	return bret;
end

function PANEL:OnFilterChange()
	pnlServList.m_pList:SortByColumn( pnlServList.m_nColumn, pnlServList.m_bDescend, pnlServList.m_pServs )
end

function PANEL:SortByColumn( nColumn, bDescending, servs )
	local self = self:GetParent():GetParent()
	self.m_nColumn	= nColumn
	self.m_bDescend = bDescending
	local index		= self.m_pColumns[ nColumn ]
	local function _p( t, f )
		local indexes = {}
		for k in pairs( t ) do indexes[ #indexes + 1 ] = k end
		local function iterator( x, y )
			local rx, ry = t[ x ][ index ], t[ y ][ index ]
			if ( index == "pl" ) then
				local strstr = string.find( rx, "/", 0, true )
				rx = tonumber(string.sub( rx, 0, strstr - 1 ))
				local strstr = string.find( ry, "/", 0, true )
				ry = tonumber(string.sub( ry, 0, strstr - 1 ))
			end
			if ( bDescending ) then
				return rx > ry
			else
				return rx < ry
			end
		end
		table.sort(indexes, iterator)
		local i = 0
		local function ret()
			i = i + 1
			return indexes[ i ], t[ indexes [ i ] ]
		end
		return ret
	end
	local ls = self.m_pList:GetLines()
	for i = 1, #ls do
		self.m_pList:RemoveLine( i )
	end
	self.m_nAmount = 0;
	for k,v in _p( self.m_pServs ) do
		self:AddServer( v )
	end
end

function PANEL:OnRowRightClick( line, panel )
	local info = pnlServList.m_pServs[panel:GetValue(7)];
	g_RightClickMenu = DermaMenu()
	g_RightClickMenu:AddOption( "Connect to Server", function() 
		if ( info.passprot ) then
			Derma_StringRequest( "Password", "Please put the password here.", "", function( text ) 
				RunGameUICommand( "engine sv_password "..text ) 
				RunGameUICommand( "engine connect "..info.address ) 
				
			end, function() end )
		else
			RunGameUICommand( "engine connect "..info.address ) 
		end
	end )
	g_RightClickMenu:AddOption( "Add to Favorites", function() 
		if ( not table.HasValue( pnlServList.m_pFavorites, info.address ) ) then
			--RunGameUICommand( "AddToFavorites "..info.address )
			--GetServers( "favorite" )
			cookie.Set( "favorites", table.concat( pnlServList.m_pFavorites, " " ).." "..info.address )
			pnlServList:UpdateFavorites()
		end
	end )
	g_RightClickMenu:AddOption( "Copy IP to clipboard", function()
		SetClipboardText( info.address ) 
	end )
	if ( table.HasValue( pnlServList.m_pFavorites, info.address ) ) then
		g_RightClickMenu:AddOption( "Remove from Favorites", function()	
			for k,v in pairs( pnlServList.m_pFavorites ) do
				if ( v == info.address ) then
					table.remove( pnlServList.m_pFavorites, k )
				end
			end
			cookie.Set( "favorites", table.concat( pnlServList.m_pFavorites, " " ) )
			pnlServList:UpdateFavorites()
			pnlServList:OnFilterChange()
		
		end )
	end
	g_RightClickMenu:SetPos( input.GetCursorPos() )
	g_RightClickMenu:MakePopup()
end

function PANEL:AddServer( serv )
	self.m_pDone[ serv.address ] = true
	if ( self.m_nAmount < self.m_nMaxAmount and not self:ShouldFilterServer( serv ) ) then
		self.m_nAmount = self.m_nAmount + 1
		self.m_pList:AddLine( serv.name, serv.map, serv.pl, serv.desc, serv.ping, ( serv.passprot and "yes" or "" ), serv.address ) 
	end
end

function PANEL:Refresh()
	for k,v in pairs( self.m_pDone ) do
		self.m_pDone[ k ] = nil
	end
end

local serversperupdate = 10

timer.Create("ServerListTimer", 0.05, 0, function()
	local pnl = pnlServList
	if ( pnl and IsValid( pnl ) ) then
		local done = 0;
		for k, info in pairs( pnl.m_pServs ) do
			if ( done > serversperupdate ) then break end
			if ( not pnl.m_pDone[ k ] ) then
				done = done + 1
				pnl:AddServer( info )
			end
		end
		
	end
end)

vgui.Register( "ServerListPanel", PANEL, "DFrame" )