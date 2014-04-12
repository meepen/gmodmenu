

local PANEL = {}

function PANEL:Init()
	self.m_pMaps = vgui.Create( "EditablePanel", self )
	self.m_pMaps:SetPos( 15, 15 )
	self.m_pMaps:SetSize( ScrW() - 315, ScrH() - 77 )
	self.m_pMaps.m_Color	= Color( 255, 255, 255, 255 )
	self.m_pMaps.m_pTypes 	= {}
	self.m_pMaps.m_szCurrent= "Sandbox"
	function self.m_pMaps:Paint()
		self:GetParent().P( self )
	end
	
	local i 		= 0
	local HEIGHT 	= 28
	local SPACE		= 10
	
	for k, v in pairs( g_MapListCategorised ) do
		self.m_pMaps.m_pTypes[ k ] = vgui.Create( "DButton", self.m_pMaps )
		local b = self.m_pMaps.m_pTypes[ k ]
		b:SetPos( 20, 15 + i * ( HEIGHT + SPACE ) )
		b:SetSize( 200, HEIGHT )
		b:SetText( "" )
		b.m_Font		= "Default"
		b.m_Color1 		= Color( 221, 221, 221, 255 )
		b.m_Color2 		= Color( 153, 205, 255, 255 )
		b.m_colText		= Color( 110, 110, 110, 255 )
		b.m_Border 		= 4
		b.m_Text		= k
		b.m_pMaps		= v
		local SPACE 	= 3
		function b:Paint()
			if( self.m_Text == self:GetParent().m_szCurrent ) then
				self.m_Color = self.m_Color2
			else
				self.m_Color = self.m_Color1
			end
			self:GetParent():GetParent().P(self)
			surface.SetFont( self.m_Font )
			local w, h = surface.GetTextSize( self.m_Text )
			surface.SetTextColor( self.m_colText )
			surface.SetTextPos( 5, HEIGHT / 2 - h / 2 )
			surface.DrawText( self.m_Text )
			w, h = surface.GetTextSize( tostring( table.Count( self.m_pMaps ) ) )
			draw.RoundedBox( 4, self:GetWide() - 5 - SPACE * 2 - w, self:GetTall() / 2 - h / 2 - SPACE, w + SPACE * 2, h + SPACE * 2, Color( 255, 255, 255, 255 ) )
			surface.SetTextPos( self:GetWide() - 5 - SPACE - w, self:GetTall() / 2 - h / 2 )
			surface.SetTextColor( Color( 200, 200, 200, 255 ) )
			surface.DrawText( tostring( table.Count( self.m_pMaps ) ) )
		end
		function b:DoClick()
			self:GetParent().m_szCurrent = self.m_Text 
		end
		i = i + 1
	end
	
	self.m_btnClose = vgui.Create( "DButton", self )
	function self.m_btnClose:DoClick()
		self:Close()
	end
	
	self.m_btnClose:SetSize( 130, 42 )
	self.m_btnClose:SetPos( 15, ScrH() - 52 )
	self.m_btnClose.m_Color 	= Color( 255, 255, 255, 255 )
	self.m_btnClose.m_Border	= 8
	self.m_btnClose.m_colText	= Color( 50, 50, 50, 255 )
	self.m_btnClose.m_Text		= "Back to Main"
	self.m_btnClose.m_Font		= "Default"
	self.m_btnClose:SetText( "" )
	
	function self.m_btnClose:DoClick()
		self:GetParent():Remove()
	end
	function self.m_btnClose:Paint()
		self:GetParent().P( self )
		surface.SetFont( self.m_Font )
		local w, h = surface.GetTextSize( self.m_Text )
		surface.SetTextColor( self.m_colText )
		surface.SetTextPos( self:GetWide() - 5 - w, self:GetTall() / 2 - h / 2 )
		surface.DrawText( self.m_Text )
	end
	self.m_btnClose.m_imgBack 	= vgui.Create( "DHTML", self.m_btnClose )
	self.m_btnClose.m_imgBack:SetHTML( "<img style=\"height:32px;width:32px\" src=\"asset://garrysmod/html/img/back_to_main_menu.png\" />" )
	self.m_btnClose.m_imgBack:SetSize( 60, 60 )
	self.m_btnClose.m_imgBack:SetPos( 0, -2 )
	-- self.m_btnClose.m_imgBack:SetScrollbars( false ) -- y u no work
	self.m_btnClose.m_imgBack.DoClick = self.m_btnClose.DoClick
	
	self:MakePopup()
	self:SetSize( ScrW(), ScrH() ) 
	self:SetPos( 0, 0 )
end

function PANEL:P()
	draw.RoundedBox( self.m_Border or 8, 0, 0, self:GetWide(), self:GetTall(), self.m_Color )
end

function PANEL:Paint()
end

vgui.Register( "SinglePlayerPanel", PANEL, "DPanel" ) -- change dpanel when done developing