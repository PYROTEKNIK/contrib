﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
local PANEL = {}

function PANEL:Close()
    if IsValid(SS_PopupPanel) then
        SS_ShopMenu:SetParent()
        SS_PopupPanel:Remove()
    end

    self:SetVisible(false)
    SS_InventoryPanel:SetVisible(true)
end

function PANEL:Open(item)
    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    self.item = item
    item.applied_cfg = table.Copy(item.cfg)
    self.wear = LocalPlayer():IsPony() and "wear_p" or "wear_h"

    if IsValid(SS_PopupPanel) then
        SS_ShopMenu:SetParent()
        SS_PopupPanel:Remove()
    end

    SS_PopupPanel = vgui.Create("DFrame")
    SS_PopupPanel:SetPos(0, 0)
    SS_PopupPanel:SetSize(ScrW(), ScrH())
    SS_PopupPanel:SetDraggable(false)
    SS_PopupPanel:ShowCloseButton(false)
    SS_PopupPanel:SetTitle("")
    SS_PopupPanel.Paint = function() end
    SS_PopupPanel:MakePopup()
    SS_ShopMenu:SetParent(SS_PopupPanel)
    self:SetVisible(true)
    SS_InventoryPanel:SetVisible(false)
    self:SetBackgroundColor(SS_GridBGColor)
    local inner = vgui.Create("DPanel", self)
    inner:SetBackgroundColor(SS_TileBGColor)
    inner:DockMargin(8, 8, 8, 8)
    inner:Dock(FILL)
    local top = vgui.Create("DPanel", inner)
    top.Paint = function() end
    top:SetTall(64)
    top:Dock(TOP)
    local p = vgui.Create("DLabel", top)
    p:SetFont("SS_LargeTitle")
    p:SetText("βUSTOMIZER")
    p:SetColor(SS_SwitchableColor)
    p:SetContentAlignment(5)
    p:SizeToContents()
    p:DockMargin(80, 8, 0, 10)
    p:Dock(LEFT)
    local p = vgui.Create("DLabel", top)
    p:SetFont("SS_DESCINSTFONT")
    p:SetText("                                      WARNING:\nPornographic images or builds are not allowed!")
    p:SetColor(SS_SwitchableColor)
    p:SetContentAlignment(5)
    p:SizeToContents()
    p:DockMargin(0, 0, 32, 0)
    p:Dock(RIGHT)
    local bot = vgui.Create("DPanel", inner)
    bot.Paint = function() end
    bot:SetTall(64)
    bot:Dock(BOTTOM)
    p = vgui.Create('DButton', bot)
    p:SetText("Reset")
    p:SetFont("SS_DESCTITLEFONT")
    p:SetWide(200)

    p.Paint = function(self, w, h)
        if self:IsHovered() then
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, w, h)
        end
    end

    p.DoClick = function(butn)
        self.item.cfg = {}
        self:UpdateCfg()
        self:SetupControls()
    end

    p:Dock(LEFT)
    p = vgui.Create('DButton', bot)
    p:SetText("Cancel")
    p:SetFont("SS_DESCTITLEFONT")
    p:SetWide(200)

    p.Paint = function(self, w, h)
        if self:IsHovered() then
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, w, h)
        end
    end

    p.DoClick = function(butn)
        self.item.cfg = self.item.applied_cfg
        self:Close()
    end

    p:Dock(LEFT)
    p = vgui.Create('DButton', bot)
    p:SetText("Done")
    p:SetFont("SS_DESCTITLEFONT")

    p.Paint = function(self, w, h)
        if self:IsHovered() then
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, w, h)
        end
    end

    p.DoClick = function(butn)
        net.Start('SS_ConfigureItem')
        net.WriteUInt(self.item.id, 32)
        net.WriteTableHD(self.item.cfg)
        net.SendToServer()
        self:Close()
    end

    p:Dock(FILL)
    self.controlzone = vgui.Create("DPanel", inner)
    self.controlzone:Dock(FILL)
    self.controlzone:SetBackgroundColor(SS_TileBGColor)
    self:SetupControls()
end

function PANEL:SetupControls()
    for k, v in pairs(self.controlzone:GetChildren()) do
        v:Remove()
    end

    local wearzone = vgui.Create("DPanel", self.controlzone)
    wearzone:SetWide(400)
    wearzone:Dock(LEFT)
    wearzone:SetBackgroundColor(SS_TileBGColor)
    wearzone = vgui.Create("DScrollPanel", wearzone)
    wearzone:Dock(FILL)

    local function LabelMaker(parent, text, top)
        local p2 = nil

        if not top then
            p2 = vgui.Create("Panel", parent)
            p2:DockMargin(16, 16, 16, 0)
            p2:Dock(TOP)

            if parent.AddItem then
                parent:AddItem(p2)
            end
        end

        local p = vgui.Create("DLabel", p2 or parent)
        p:SetFont("SS_DESCINSTFONT")
        p:SetText(text)
        p:SetTextColor(SS_SwitchableColor)
        p:SizeToContents()

        if top then
            p:SetContentAlignment(5)
            p:DockMargin(16, 16, 16, 16)
            p:Dock(TOP)

            if parent.AddItem then
                parent:AddItem(p)
            end
        else
            p:DockMargin(0, 0, 0, 0)
            p:Dock(LEFT)
        end

        return p2
    end

    local function SliderMaker(parent, text)
        local p = vgui.Create("DNumSlider", parent)
        p:SetText(text)
        p:SetDecimals(2)
        p:DockMargin(32, 8, 32, 0)
        p:Dock(TOP)
        p:SetDark(not SS_DarkMode)
        p.TextArea:SetPaintBackground(true)
        p:SetTall(24)

        if parent.AddItem then
            parent:AddItem(p)
        end

        return p
    end

    local function CheckboxMaker(parent, text)
        local p2 = vgui.Create("Panel", parent)
        p2:DockMargin(16, 16, 16, 0)
        p2:Dock(TOP) --retarded wrapper
        local p3 = vgui.Create("DCheckBox", p2)
        --p:SetText(text)
        p3:SetDark(true)
        p3:SetPos(0, 2)
        --p:SetTall(24)
        local p = vgui.Create("DLabel", p2 or parent)
        p:SetFont("SS_DESCFONT")
        p:SetText(text)
        p:SetTextColor(SS_SwitchableColor)
        p:SetPos(24, 0)
        p:SizeToContents()

        --p2:SizeToChildren()
        if parent.AddItem then
            parent:AddItem(p2)
        end

        return p3
    end

    local pone = LocalPlayer():IsPony()
    local suffix = pone and "_p" or "_h"
    local itmcw = self.item.configurable.wear

    if (self.item.configurable or {}).wear then
        LabelMaker(wearzone, "Position (" .. (pone and "pony" or "human") .. ")", true)
        local p = vgui.Create("Panel", wearzone)
        p:DockMargin(32, 8, 32, 0)
        p:Dock(TOP)
        ATTACHSELECT = vgui.Create("DComboBox", p)
        ATTACHSELECT:SetValue((self.item.cfg[self.wear] or {}).attach or (pone and (self.item.wear.pony or {}).attach) or self.item.wear.attach)

        for k, v in pairs(SS_Attachments) do
            ATTACHSELECT:AddChoice(k)
        end

        ATTACHSELECT.OnSelect = function(panel, index, value)
            self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
            self.item.cfg[self.wear].attach = value
            self:UpdateCfg()
        end

        ATTACHSELECT:SetWide(200)
        ATTACHSELECT:Dock(RIGHT)
        p = vgui.Create("DLabel", p)
        p:Dock(LEFT)
        p:SetText("Attach to")
        p:SetDark(true)
        p:SetTextColor(SS_SwitchableColor)
        LabelMaker(wearzone, "Offset")
        local translate = (self.item.cfg[self.wear] or {}).pos or (pone and (self.item.wear.pony or {}).translate) or self.item.wear.translate
        XSL = SliderMaker(wearzone, "Forward/Backward")
        XSL:SetMinMax(itmcw.pos.min.x, itmcw.pos.max.x)
        XSL:SetValue(translate.x)
        YSL = SliderMaker(wearzone, "Left/Right")
        YSL:SetMinMax(itmcw.pos.min.y, itmcw.pos.max.z)
        YSL:SetValue(translate.y)
        ZSL = SliderMaker(wearzone, "Up/Down")
        ZSL:SetMinMax(itmcw.pos.min.z, itmcw.pos.max.z)
        ZSL:SetValue(translate.z)
        LabelMaker(wearzone, "Angle")
        local rotate = (self.item.cfg[self.wear] or {}).ang or (pone and (self.item.wear.pony or {}).rotate) or self.item.wear.rotate
        XRSL = SliderMaker(wearzone, "Pitch")
        XRSL:SetMinMax(-180, 180)
        XRSL:SetValue(rotate.p)
        YRSL = SliderMaker(wearzone, "Yaw")
        YRSL:SetMinMax(-180, 180)
        YRSL:SetValue(rotate.y)
        ZRSL = SliderMaker(wearzone, "Roll")
        ZRSL:SetMinMax(-180, 180)
        ZRSL:SetValue(rotate.r)
        local scalelabel = LabelMaker(wearzone, "Scale")
        local scale = (self.item.cfg[self.wear] or {}).scale or (pone and (self.item.wear.pony or {}).scale) or self.item.wear.scale

        if isnumber(scale) then
            scale = Vector(scale, scale, scale)
        end

        SXSL = SliderMaker(wearzone, "Length")
        SXSL:SetMinMax(itmcw.scale.min.x, itmcw.scale.max.x)
        SXSL:SetValue(scale.x)
        SYSL = SliderMaker(wearzone, "Width")
        SYSL:SetMinMax(itmcw.scale.min.y, itmcw.scale.max.y)
        SYSL:SetValue(scale.y)
        SZSL = SliderMaker(wearzone, "Height")
        SZSL:SetMinMax(itmcw.scale.min.z, itmcw.scale.max.z)
        SZSL:SetValue(scale.z)

        local function transformslidersupdate()
            self.item.cfg[self.wear] = self.item.cfg[self.wear] or {}
            self.item.cfg[self.wear].pos = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
            self.item.cfg[self.wear].ang = Angle(XRSL:GetValue(), YRSL:GetValue(), ZRSL:GetValue())
            self.item.cfg[self.wear].scale = Vector(SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue())
            self:UpdateCfg()
        end

        XSL.OnValueChanged = transformslidersupdate
        YSL.OnValueChanged = transformslidersupdate
        ZSL.OnValueChanged = transformslidersupdate
        XRSL.OnValueChanged = transformslidersupdate
        YRSL.OnValueChanged = transformslidersupdate
        ZRSL.OnValueChanged = transformslidersupdate
        SXSL.OnValueChanged = transformslidersupdate
        SYSL.OnValueChanged = transformslidersupdate
        SZSL.OnValueChanged = transformslidersupdate
        local scalebutton = vgui.Create("DButton", scalelabel)
        scalebutton:SetText("Use Uniform Scaling")
        scalebutton:SetWide(160)
        scalebutton:Dock(RIGHT)

        scalebutton.DoClick = function(btn)
            if btn.UniformMode then
                btn.UniformMode = nil
                btn:SetText("Use Uniform Scaling")
                SXSL:SetVisible(true)
                SYSL:SetVisible(true)
                SZSL:SetVisible(true)
                SUSL:SetVisible(false)
            else
                btn.UniformMode = true
                btn:SetText("Use Independent Scaling")
                SXSL:SetVisible(false)
                SYSL:SetVisible(false)
                SZSL:SetVisible(false)
                SUSL:SetVisible(true)

                local v = {SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue()}

                table.sort(v, function(a, b) return a > b end)
                SUSL:SetValue(v[2])
            end
        end

        SUSL = SliderMaker(wearzone, "Scale")
        SUSL:SetMinMax(math.max(itmcw.scale.min.x, itmcw.scale.min.y, itmcw.scale.min.z), math.min(itmcw.scale.max.x, itmcw.scale.max.y, itmcw.scale.max.z))

        SUSL.OnValueChanged = function(self)
            SXSL:SetValue(self:GetValue())
            SYSL:SetValue(self:GetValue())
            SZSL:SetValue(self:GetValue())
        end

        SUSL:SetVisible(false)

        if scale.x == scale.y and scale.y == scale.z then
            scalebutton:DoClick()
        end
    elseif (self.item.configurable or {}).bone then
        LabelMaker(wearzone, "Mod (" .. (LocalPlayer():IsPony() and "pony" or "human") .. ")", true)

        local function cleanbonename(bn)
            return bn:Replace("ValveBiped.Bip01_", ""):Replace("Lrig", ""):Replace("_LEG_", "")
        end

        local p = vgui.Create("Panel", wearzone)
        p:DockMargin(32, 8, 32, 0)
        p:Dock(TOP)
        ATTACHSELECT = vgui.Create("DComboBox", p)
        ATTACHSELECT:SetValue(cleanbonename(self.item.cfg["bone" .. suffix] or (pone and "Scull" or "Head1")))

        for x = 0, (LocalPlayer():GetBoneCount() - 1) do
            local bn = LocalPlayer():GetBoneName(x)
            local cleanname = cleanbonename(bn)

            if cleanname ~= "__INVALIDBONE__" then
                ATTACHSELECT:AddChoice(cleanname, bn)
            end
        end

        ATTACHSELECT.OnSelect = function(panel, index, word, value)
            self.item.cfg["bone" .. suffix] = value
            self:UpdateCfg()
        end

        ATTACHSELECT:SetWide(200)
        ATTACHSELECT:Dock(RIGHT)
        p = vgui.Create("DLabel", p)
        p:Dock(LEFT)
        p:SetText("Attach to")
        p:SetDark(true)
        p:SetTextColor(SS_SwitchableColor)

        --bunch of copied shit
        local function transformslidersupdate()
            if self.item.configurable.scale then
                self.item.cfg["scale" .. suffix] = Vector(SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue())
            end

            if self.item.configurable.pos then
                self.item.cfg["pos" .. suffix] = Vector(XSL:GetValue(), YSL:GetValue(), ZSL:GetValue())
            end

            self:UpdateCfg()
        end

        local itmcp = self.item.configurable.pos

        if itmcp then
            LabelMaker(wearzone, "Offset")
            local translate = self.item.cfg["pos" .. suffix] or Vector(0, 0, 0)
            XSL = SliderMaker(wearzone, "X (Along)")
            XSL:SetMinMax(itmcp.min.x, itmcp.max.x)
            XSL:SetValue(translate.x)
            YSL = SliderMaker(wearzone, "Y")
            YSL:SetMinMax(itmcp.min.y, itmcp.max.y)
            YSL:SetValue(translate.y)
            ZSL = SliderMaker(wearzone, "Z")
            ZSL:SetMinMax(itmcp.min.z, itmcp.max.z)
            ZSL:SetValue(translate.z)
            XSL.OnValueChanged = transformslidersupdate
            YSL.OnValueChanged = transformslidersupdate
            ZSL.OnValueChanged = transformslidersupdate
        end

        local itmcs = self.item.configurable.scale

        if itmcs then
            local scalelabel = LabelMaker(wearzone, "Scale")
            local scale = self.item.cfg["scale" .. suffix] or Vector(1, 1, 1)

            if isnumber(scale) then
                scale = Vector(scale, scale, scale)
            end

            SXSL = SliderMaker(wearzone, "X (Along)")
            SXSL:SetMinMax(itmcs.min.x, itmcs.max.x)
            SXSL:SetValue(scale.x)
            SYSL = SliderMaker(wearzone, "Y")
            SYSL:SetMinMax(itmcs.min.y, itmcs.max.y)
            SYSL:SetValue(scale.y)
            SZSL = SliderMaker(wearzone, "Z")
            SZSL:SetMinMax(itmcs.min.z, itmcs.max.z)
            SZSL:SetValue(scale.z)
            SXSL.OnValueChanged = transformslidersupdate
            SYSL.OnValueChanged = transformslidersupdate
            SZSL.OnValueChanged = transformslidersupdate
            local scalebutton = vgui.Create("DButton", scalelabel)
            scalebutton:SetText("Use Uniform Scaling")
            scalebutton:SetWide(160)
            scalebutton:Dock(RIGHT)

            scalebutton.DoClick = function(btn)
                if btn.UniformMode then
                    btn.UniformMode = nil
                    btn:SetText("Use Uniform Scaling")
                    SXSL:SetVisible(true)
                    SYSL:SetVisible(true)
                    SZSL:SetVisible(true)
                    SUSL:SetVisible(false)
                else
                    btn.UniformMode = true
                    btn:SetText("Use Independent Scaling")
                    SXSL:SetVisible(false)
                    SYSL:SetVisible(false)
                    SZSL:SetVisible(false)
                    SUSL:SetVisible(true)

                    local v = {SXSL:GetValue(), SYSL:GetValue(), SZSL:GetValue()}

                    table.sort(v, function(a, b) return a > b end)
                    SUSL:SetValue(v[2])
                end
            end

            SUSL = SliderMaker(wearzone, "Scale")
            SUSL:SetMinMax(math.max(itmcs.min.x, itmcs.min.y, itmcs.min.z), math.min(itmcs.max.x, itmcs.max.y, itmcs.max.z))

            SUSL.OnValueChanged = function(self)
                SXSL:SetValue(self:GetValue())
                SYSL:SetValue(self:GetValue())
                SZSL:SetValue(self:GetValue())
            end

            SUSL:SetVisible(false)

            if scale.x == scale.y and scale.y == scale.z then
                scalebutton:DoClick()
            end
        end

        --end bunch of copied shit
        if self.item.configurable.scale_children then
            CHILDCHECKBOX = CheckboxMaker(wearzone, "Scale child bones")
            CHILDCHECKBOX:SetValue(self.item.cfg["scale_children" .. suffix] and 1 or 0)

            CHILDCHECKBOX.OnChange = function(checkboxself, ch)
                self.item.cfg["scale_children" .. suffix] = ch
                self:UpdateCfg()
            end
        end
    elseif (self.item.configurable or {}).submaterial then
        LabelMaker(wearzone, "Skin ID", true)
        local p = vgui.Create("Panel", wearzone)
        p:DockMargin(32, 8, 32, 0)
        p:Dock(TOP)
        ATTACHSELECT = vgui.Create("DComboBox", p)
        ATTACHSELECT:SetValue(tostring(self.item.cfg.submaterial or 0))

        for x = 0, math.min(31, (#(LocalPlayer():GetMaterials()) - 1)) do
            ATTACHSELECT:AddChoice(tostring(x), x)
        end

        ATTACHSELECT.OnSelect = function(panel, index, word, value)
            self.item.cfg.submaterial = tonumber(value)
            self:UpdateCfg()
        end

        ATTACHSELECT:SetWide(200)
        ATTACHSELECT:Dock(RIGHT)
    end

    local colorzone = vgui.Create("DPanel", self.controlzone)
    --colorzone.Paint = function() end
    colorzone:Dock(FILL)
    colorzone:SetBackgroundColor(SS_TileBGColor)
    colorzone = vgui.Create("DScrollPanel", colorzone)
    colorzone:Dock(FILL)
    PrintTable(self.item)

    if (self.item.configurable or {}).color then
        LabelMaker(colorzone, "Appearance", true)
        local cv = Vector()
        cv:Set(self.item.cfg.color or self.item.color or Vector(1, 1, 1))
        local cvm = math.max(1, cv.x, cv.y, cv.z)
        PSCMixer = vgui.Create("DColorMixer", colorzone)
        PSCMixer:SetPalette(true)
        PSCMixer:SetAlphaBar(false)
        PSCMixer:SetWangs(true)
        PSCMixer:SetVector(cv / cvm)
        PSCMixer:SetTall(250)
        PSCMixer:DockMargin(32, 8, 32, 16)
        PSCMixer:Dock(TOP)
        PSBS = SliderMaker(colorzone, "Boost")
        PSBS:SetMinMax(1, self.item.configurable.color.max)
        PSBS:SetValue(cvm)

        local function colorchanged()
            self.item.cfg.color = PSCMixer:GetVector() * PSBS:GetValue()
            self:UpdateCfg()
        end

        PSCMixer.ValueChanged = colorchanged
        PSBS.OnValueChanged = colorchanged
        local matlabel = LabelMaker(colorzone, "Custom Material")
        IMGURREMOVEBUTTON = vgui.Create("DButton", matlabel)
        IMGURREMOVEBUTTON:SetWide(160)
        IMGURREMOVEBUTTON:Dock(RIGHT)

        IMGURREMOVEBUTTON.SetRemoveMode = function(btn, remove)
            self.removemove = remove

            if remove then
                btn:SetText("Remove Custom Material")

                btn.DoClick = function(btn)
                    IMGURENTRY:SetValue("")
                end
            else
                btn:SetText("Show Reference Material")

                btn.DoClick = function(btn)
                    local mat

                    if IsValid(SS_HoverCSModel) then
                        mat = SS_HoverCSModel:GetMaterials()[1]
                    else
                        mat = LocalPlayer():GetMaterials()[(self.item.cfg.submaterial or 0) + 1]
                    end

                    print("MAT PATH:", mat)
                    local sz = math.min(1024, ScrH() - 30)

                    if mat then
                        local Frame = vgui.Create("DFrame")
                        Frame:SetSize(sz + 10, sz + 30)
                        Frame:Center()
                        Frame:SetTitle("Take a screenshot; it'll last longer. Displayed at " .. tostring(sz) .. "x" .. tostring(sz))
                        Frame:MakePopup()
                        Frame.BasedPaint = Frame.Paint

                        function Frame:Paint(w, h)
                            cam.IgnoreZ(true)
                            draw.RoundedBox(8, 0, 0, w, h, Color(255, 0, 128))
                            cam.IgnoreZ(false)
                        end

                        local img = vgui.Create("DImage", Frame)
                        img:SetPos(5, 25)
                        img:SetSize(sz, sz)
                        img:SetImage(mat)
                        img:GetMaterial():SetInt("$flags", 0)
                        img.BasedPaint = img.Paint

                        function img:Paint(w, h)
                            cam.IgnoreZ(true)
                            self:BasedPaint(w, h)
                            cam.IgnoreZ(false)
                        end
                    else
                        LocalPlayerNotify("Couldn't find the material, sorry.")
                    end
                end
            end
        end

        local urlzone = vgui.Create("Panel", colorzone)
        urlzone:DockMargin(0, 8, 16, 0)
        urlzone:Dock(TOP)
        urlzone:SetTall(40)

        if colorzone.AddItem then
            colorzone:AddItem(urlzone)
        end

        IMGURENTRY = vgui.Create("DTextEntry", urlzone)
        IMGURENTRY:DockMargin(16, 8, 16, 0)
        IMGURENTRY:Dock(FILL)
        IMGURENTRY:SetPaintBackground(true)

        IMGURENTRY.OnValueChange = function(textself, new)
            SingleAsyncSanitizeImgurId(new, function(id)
                if not IsValid(self) then return end
                -- IMGURREMOVEBUTTON:SetVisible(id ~= nil)
                IMGURREMOVEBUTTON:SetRemoveMode(id ~= nil)

                self.item.cfg.imgur = id and {
                    url = id
                } or nil

                self:UpdateCfg()
            end)
        end

        IMGURENTRY:SetUpdateOnType(true)
        IMGURENTRY:SetValue((self.item.cfg.imgur or {}).url or "")
        local imgurinfo = vgui.Create("DLabel", urlzone)
        -- imgurinfo:SetText("Use an imgur direct URL such as:\nhttp://i.imgur.com/PxOc7TC.png\n(Right click -> Copy image address)")
        imgurinfo:SetText("Upload an image to imgur.com and enter the link.\nFor example: https://imgur.com/a/3AOvcC1\nNo videos or GIFs!")
        imgurinfo:SetColor(SS_SwitchableColor)
        imgurinfo:Dock(RIGHT)
        imgurinfo:SetWide(100)
        imgurinfo:SizeToContents()
    end

    local rawzone = vgui.Create("Panel", colorzone)
    rawzone:DockMargin(0, 8, 32, 0)
    rawzone:Dock(TOP)
    rawzone:SetTall(36)

    if colorzone.AddItem then
        colorzone:AddItem(rawzone)
    end

    local rawbutton = vgui.Create("DButton", rawzone)
    rawbutton:SetText("Raw Data")
    rawbutton:SetWide(160)
    rawbutton:DockMargin(0, 16, 0, 0)
    rawbutton:Dock(RIGHT)
    rawbutton:CenterHorizontal()

    rawbutton.DoClick = function(btn)
        RAWENTRY:SetVisible(true)
        rawzone:SetTall(160)
        btn:Remove()
    end

    RAWENTRY = vgui.Create("DTextEntry", rawzone)
    RAWENTRY:SetMultiline(true)
    RAWENTRY:DockMargin(32, 8, 0, 0)
    RAWENTRY:Dock(FILL)
    RAWENTRY:SetPaintBackground(true)

    RAWENTRY.OnValueChange = function(textself, new)
        if not textself.RECIEVE then
            self.item.cfg = util.JSONToTable(new) or {}
            self:UpdateCfg(true) -- TODO: sanitize input like on the server
        end
    end

    RAWENTRY:SetUpdateOnType(true)
    --RAWENTRY:SetValue("unset") --(self.item.cfg.imgur or {}).url or "")
    RAWENTRY:SetVisible(false)
    self:UpdateCfg()
end

function PANEL:UpdateCfg(skiptext)
    self.item:Sanitize()

    if IsValid(RAWENTRY) and not skiptext then
        RAWENTRY.RECIEVE = true
        RAWENTRY:SetValue(util.TableToJSON(self.item.cfg, true))
        RAWENTRY.RECIEVE = nil
    end
end

vgui.Register('DPointShopCustomizer', PANEL, 'DPanel')