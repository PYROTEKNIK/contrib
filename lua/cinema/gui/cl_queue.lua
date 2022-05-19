﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.


vgui.Register("ScoreboardQueue", {
    
TitleHeight = 64


,Init = function(self)
    self:SetZPos(1)
    self:SetSize(288, 512)
    self:SetPos(8, ScrH() / 2 - self:GetTall() / 2)
    self.Title = Label('QUEUE', self)
    self.Title:SetFont("ScoreboardTitle")
    self.Title:SetColor(Color(255, 255, 255))
    self.Videos = {}
    self.NextUpdate = 0.0
    self.VideoList = vgui.Create("TheaterList", self)
    self.VideoList:DockMargin(0, self.TitleHeight + 2, 0, 0)
    self.Options = vgui.Create("DPanelList", self)
    self.Options:SetDrawBackground(false)
    self.Options:SetPadding(4)
    self.Options:SetSpacing(4)
    -- Theater Options
    local RequestButton = vgui.Create("TheaterButton")
    RequestButton:SetText('Request Video')

    RequestButton.DoClick = function(self)
        local RequestFrame = vgui.Create("VideoRequestFrame")

        if IsValid(RequestFrame) then
            RequestFrame:Center()
            RequestFrame:MakePopup()
        end
    end

    self.Options:AddItem(RequestButton)
    local LastRequestButton = vgui.Create("TheaterButton")
    LastRequestButton:SetText('Last Video in History')

    LastRequestButton.DoClick = function(self)
        RunConsoleCommand("cinema_requestlast")
    end

    self.Options:AddItem(LastRequestButton)
    local VoteSkipButton = vgui.Create("TheaterButton")
    VoteSkipButton:SetText('Vote Skip')

    VoteSkipButton.DoClick = function(self)
        RunConsoleCommand("cinema_voteskip")
    end

    self.Options:AddItem(VoteSkipButton)
    local FullscreenButton = vgui.Create("TheaterButton")
    FullscreenButton:SetText('Toggle Fullscreen/Clicker')

    FullscreenButton.DoClick = function(self)
        RunConsoleCommand("cinema_fullscreen")
    end

    self.Options:AddItem(FullscreenButton)
    local RefreshButton = vgui.Create("TheaterButton")
    RefreshButton:SetText('Refresh Theater')

    RefreshButton.DoClick = function(self)
        RunConsoleCommand("cinema_refresh")
    end

    self.Options:AddItem(RefreshButton)
end

,AddVideo = function(self,vid)
    if self.Videos[vid.id] then
        self.Videos[vid.id]:SetVideo(vid)
    else
        local panel = vgui.Create("ScoreboardVideo", self)
        panel:SetVideo(vid)
        panel:SetVisible(true)
        self.Videos[vid.id] = panel
        self.VideoList:AddItem(panel)
    end
end

,RemoveVideo = function(self,vid)
    if ValidPanel(self.Videos[vid.id]) then
        self.VideoList:RemoveItem(self.Videos[vid.id])
        self.Videos[vid.id]:Remove()
        self.Videos[vid.id] = nil
    end
end

,Update = function(self)
    local Theater = Me:GetTheater()
    if not Theater then return end
    theater.PollServer()
end

,UpdateList = function(self)
    local ids = {}

    for _, vid in pairs(theater.GetQueue()) do
        self:AddVideo(vid)
        ids[vid.id] = true
    end

    for k, panel in pairs(self.Videos) do
        if not ids[k] then
            self:RemoveVideo(panel.Video)
        end
    end

    self.VideoList:SortVideos(function(a, b)
        if a.vto == b.vto then
            return a.rt < b.rt
        else
            return a.vto > b.vto
        end
    end)
end

,Think = function(self)
    if RealTime() > self.NextUpdate then
        self:Update()
        self:InvalidateLayout()
        self.NextUpdate = RealTime() + 0.4
    end
end

,Paint = function(self,w, h)
    -- surface.SetDrawColor(BrandColorGrayDarker)
    -- surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    SS_BackgroundPattern(self, 0, 0, w, h, false)
    local xp, _ = self:GetPos()
    BrandBackgroundPattern(0, 0, self:GetWide(), self.Title:GetTall(), xp)
    BrandDropDownGradient(0, self.Title:GetTall(), self:GetWide())
end

,PerformLayout = function(self)
    self.Title:SizeToContents()
    self.Title:SetTall(self.TitleHeight)
    self.Title:CenterHorizontal()

    if self.Title:GetWide() > self:GetWide() and self.Title:GetFont() ~= "ScoreboardTitleSmall" then
        self.Title:SetFont("ScoreboardTitleSmall")
    end

    self.VideoList:Dock(FILL)
    self.Options:Dock(BOTTOM)
    self.Options:SizeToContents()
end
})

vgui.Register("ScoreboardVideo", {
    Padding = 8,
Init = function(self)
    self:SetTall(40)

    self:DockPadding(2,0,2,0)

    self.Title = vgui("DLabel", self, function(p)
        p:Dock(TOP)
        p:SetTall(20)
        p:SetFont(Font.sans18)
        p:SetColor(Color.white)
    end)

    vgui("Panel", self, function(p)
        p:Dock(FILL)

        self.Duration = vgui("DLabel",  function(p)
            p:Dock(FILL)
            p:SetFont(Font.sans18)
            p:SetColor(Color.ccc)
        end)

        self.Controls = vgui("ScoreboardVideoVote", function(p)
            p:Dock(RIGHT)
        end)
        
    end)
        
end

,Update = function(self)
    print("UPDATECALL?") 
end

,SetVideo = function(self,vid)
    self.Video = vid
    self.Controls:SetVideo(vid)
    
    self.Title:SetText(self.Video.ttl)
    self:SetTooltip(self.Video.ttl)
    self.Duration:SetText(string.FormatSeconds(self.Video.dur))
    self.Controls:Update()
end


,Paint = function(self,w, h)
    -- surface.SetDrawColor(BrandColorGrayDark)
    -- surface.DrawRect(0, 0, self:GetSize())
    DSS_Glass(self, 0,0, self:GetSize())
end


})


function IsMouseOver(self)
    local x, y = self:CursorPos()

    return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()
end


vgui.Register("ScoreboardVideoVote", {
Padding = 8

,Init = function(self)
    self.Votes = Label("+99", self)
    self.Votes:SetFont(Font.sans16)
    self.Votes:SetColor(Color(255, 255, 255))
    self.VoteUp = vgui.Create("DImageButton", self)
    self.VoteUp:SetSize(16, 16)
    self.VoteUp:SetImage("theater/up.png")

    self.VoteUp.DoClick = function()
        local last = self.Video.vlo
        self.Video.vlo = last ~= 1 and 1
        self.Video.vto = self.Video.vto + (self.Video.vlo or 0) - (last or 0)
        RunConsoleCommand("cinema_vote", self.Video.id, self.Video.vlo or 0)
        self:Update()
        self.vlo_hold = RealTime() + 1
    end

    self.VoteUp.Think = function()
        if IsMouseOver(self.VoteUp) or self.VoteUp.Voted then
            self.VoteUp:SetAlpha(255)
        else
            self.VoteUp:SetAlpha(25)
        end
    end

    self.VoteDown = vgui.Create("DImageButton", self)
    self.VoteDown:SetSize(16, 16)
    self.VoteDown:SetImage("theater/down.png")

    self.VoteDown.DoClick = function()
        local last = self.Video.vlo
        self.Video.vlo = last ~= -1 and -1
        self.Video.vto = self.Video.vto + (self.Video.vlo or 0) - (last or 0)
        RunConsoleCommand("cinema_vote", self.Video.id, self.Video.vlo or 0)
        self:Update()
        self.vlo_hold = RealTime() + 1
    end

    self.VoteDown.Think = function()
        if IsMouseOver(self.VoteDown) or self.VoteDown.Voted then
            self.VoteDown:SetAlpha(255)
        else
            self.VoteDown:SetAlpha(25)
        end
    end
end


,AddRemoveButton = function(self)
    if ValidPanel(self.RemoveBtn) then return end
    self.RemoveBtn = vgui.Create("DImageButton", self)
    self.RemoveBtn:SetSize(16, 16)
    self.RemoveBtn:SetImage("theater/trashbin.png")

    self.RemoveBtn.DoClick = function()
        RunConsoleCommand("cinema_video_remove", self.Video.id)

        if ValidPanel(GuiQueue) then
            GuiQueue:RemoveVideo(self.Video)
        end
    end

    self.RemoveBtn.Think = function()
        if IsMouseOver(self.RemoveBtn) or self.RemoveBtn.Voted then
            self.RemoveBtn:SetAlpha(255)
            self.RemoveBtn:SetColor(Color(255, 0, 0))
        else
            self.RemoveBtn:SetAlpha(25)
            self.RemoveBtn:SetColor(Color(255, 255, 255))
        end
    end
end

,Vote = function(self,up)
    if up then
        self.VoteUp:SetColor(Color(0, 255, 0))
        self.VoteUp.Voted = true
        self.VoteDown:SetColor(Color(255, 255, 255))
        self.VoteDown.Voted = nil
    elseif up == false then
        self.VoteUp:SetColor(Color(255, 255, 255))
        self.VoteUp.Voted = nil
        self.VoteDown:SetColor(Color(255, 0, 0))
        self.VoteDown.Voted = true
    else
        self.VoteUp:SetColor(Color(255, 255, 255))
        self.VoteUp.Voted = nil
        self.VoteDown:SetColor(Color(255, 255, 255))
        self.VoteDown.Voted = nil
    end
end

,Update = function(self)
    if not self.Video then return end
    local prefix = self.Video.vto > 0 and "+" or ""
    self.Votes:SetText(prefix .. self.Video.vto)

    if self.Video.vlo == 1 then
        self:Vote(true)
    elseif self.Video.vlo == -1 then
        self:Vote(false)
    else
        self:Vote(nil)
    end

    local Theater = Me:GetTheater()

    if self.Video.own or Me:StaffControlTheater() or Theater and Theater:IsPrivate() and Theater:GetOwner() == Me then
        self:AddRemoveButton()
        self:SetWide(84)
    else
        self:SetWide(64)
    end
end

,SetVideo = function(self,vid)
    --keeps network delay from overwriting us
    if self.Video and (self.vlo_hold or 0) > RealTime() then
        local off = (self.Video.vlo or 0) - (vid.vlo or 0)
        vid.vto = vid.vto + off
        vid.vlo = self.Video.vlo
    end

    self.Video = vid
    self:Update()
end

,PerformLayout = function(self)
    self.VoteUp:Center()
    self.VoteUp:AlignLeft()
    self.Votes:SizeToContents()

    if self.RemoveBtn then
        self.VoteDown:Center()
        self.VoteDown:AlignRight(24)
        self.Votes:Center()
        local x, y = self.Votes:GetPos()
        self.Votes:AlignLeft(x - 12)
        self.RemoveBtn:Center()
        self.RemoveBtn:AlignRight()
    else
        self.VoteDown:Center()
        self.VoteDown:AlignRight()
        self.Votes:Center()
    end
end
})