
local PLUGIN = PLUGIN

PLUGIN.name = "Credits Page"
PLUGIN.desc = "Adds an always up to date page listing contributors to the framework."
PLUGIN.author = "Miyoglow"

if (SERVER) then return end

PLUGIN.nsCreators = {
    -- Chessnut
    [1689094] = true,

    -- rebel1324
    [2784192] = true
}
PLUGIN.nsMaintainers = {
    -- TovarischPootis
    [54110479] = true,

    -- zoephix
    [21306782] = true
}
PLUGIN.nameOverrides = {
    [1689094] = "Chessnut",
    [2784192] = "Black Tea"
}

PLUGIN.contributorData = PLUGIN.contributorData or {
    {url = "https://github.com/Chessnut", avatar_url = "https://avatars.githubusercontent.com/u/1689094?v=4", name = "Chessnut", id = 1689094},
    {url = "https://github.com/rebel1324", avatar_url = "https://avatars.githubusercontent.com/u/2784192?v=4", name = "Black Tea", id = 2784192}
}

PLUGIN.encodedAvatarData = PLUGIN.encodedAvatarData or {}
PLUGIN.fetchedContributors = PLUGIN.fetchedContributors or false

local creatorHeight = ScreenScale(32)
local maintainerHeight = ScreenScale(32)
local contributorWidth = ScreenScale(32)

local contributorPadding = 8
local contributorMargin = 16

surface.CreateFont("nutSmallCredits", {
    font = "Segoe UI Light",
    size = ScreenScale(6),
    weight = 100
})

surface.CreateFont("nutBigCredits", {
    font = "Segoe UI Light",
    size = ScreenScale(12),
    weight = 100
})

local PANEL = {}

AccessorFunc(PANEL, "rowHeight", "RowHeight", FORCE_NUMBER)

DEFINE_BASECLASS("Panel")

function PANEL:Init()
    self.seperator = vgui.Create("Panel", self)
    self.seperator:Dock(TOP)
    self.seperator:SetTall(1)
    self.seperator.Paint = function(this, width, height)
            surface.SetDrawColor(color_white)

            surface.SetMaterial(nut.util.getMaterial("vgui/gradient-r"))
            surface.DrawTexturedRect(0, 0, width * 0.5, height)

            surface.SetMaterial(nut.util.getMaterial("vgui/gradient-l"))
            surface.DrawTexturedRect(width * 0.5, 0, width * 0.5, height)
        end
    self.seperator:DockMargin(0, 4, 0, 4)

    self.sectionLabel = vgui.Create("DLabel", self)
    self.sectionLabel:Dock(TOP)
    self.sectionLabel:SetFont("nutBigCredits")
    self.sectionLabel:SetContentAlignment(4)
end

function PANEL:Clear()
    for _, v in ipairs(self:GetChildren()) do
        if (v != self.seperator and v != self.sectionLabel) then
            v:Remove()
        end
    end
end

function PANEL:SetText(text)
    self.sectionLabel:SetText(text)
    self.sectionLabel:SizeToContents()
end

function PANEL:Add(pnl)
    return BaseClass.Add(IsValid(self.currentRow) and self.currentRow or self:newRow(), pnl)
end

function PANEL:PerformLayout(width, height)
    local tall = 0

    for _, v in ipairs(self:GetChildren()) do
        local lM, tM, rM, bM = v:GetDockMargin()
        tall = tall + v:GetTall() + tM + bM

        v:InvalidateLayout()
    end

    self:SetTall(tall)
end

function PANEL:newRow()
    self.currentRow = vgui.Create("Panel", self)
    self.currentRow:Dock(TOP)
    self.currentRow:SetTall(self:GetRowHeight())
    self.currentRow.PerformLayout = function(this)
        local totalWidth = 0

        for k, v in ipairs(this:GetChildren()) do
            if (k == 1) then
                v:DockMargin(0, 0, 0, 0)
            end

            local childWidth = v:GetWide() + v:GetDockMargin()
            totalWidth = totalWidth + childWidth

            if (totalWidth > self:GetWide() and childWidth < self:GetWide()) then
                v:SetParent(self:newRow())
            end
        end

        this:DockPadding(self:GetWide() * 0.5 - totalWidth * 0.5, 0, 0, 0)
    end

    return self.currentRow
end

vgui.Register("nutCreditsSpecialList", PANEL, "Panel")

PANEL = {}

function PANEL:Paint(w, h)
    surface.SetMaterial(nut.util.getMaterial("nutscript/logo.png"))
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(w * 0.5 - 128, h * 0.5 - 128, 256, 256)
end

vgui.Register("CreditsLogo", PANEL, "Panel")

PANEL = {}

function PANEL:Init()
    if nut.gui.creditsPanel then
        nut.gui.creditsPanel:Remove()
    end
    nut.gui.creditsPanel = self

    self.logo = self:Add("CreditsLogo")
    self.logo:SetTall(180)
    self.logo:Dock(TOP)

    self.nsLabel = self:Add("DLabel")
    self.nsLabel:SetFont("nutBigCredits")
    self.nsLabel:SetText("NutScript")
    self.nsLabel:SetContentAlignment(5)
    self.nsLabel:SizeToContents()
    self.nsLabel:Dock(TOP)

    self.repoLabel = self:Add("DLabel")
    self.repoLabel:SetFont("nutSmallCredits")
    self.repoLabel:SetText("https://github.com/NutScript")
    self.repoLabel:SetMouseInputEnabled(true)
    self.repoLabel:SetCursor("hand")
    self.repoLabel:SetContentAlignment(5)
    self.repoLabel:SizeToContents()
    self.repoLabel:Dock(TOP)
    self.repoLabel.DoClick = function()
        gui.OpenURL("https://github.com/NutScript")
    end

    if (table.Count(PLUGIN.nsCreators) > 0) then
        self.creatorList = self:Add("nutCreditsSpecialList")
        self.creatorList:Dock(TOP)
        self.creatorList:SetText("Creators")
        self.creatorList:SetRowHeight(creatorHeight)
        self.creatorList:DockMargin(0, 0, 0, 4)
    end

    if (table.Count(PLUGIN.nsMaintainers) > 0) then
        self.maintainerList = self:Add("nutCreditsSpecialList")
        self.maintainerList:Dock(TOP)
        self.maintainerList:SetText("Maintainers")
        self.maintainerList:SetRowHeight(maintainerHeight)
        self.maintainerList:DockMargin(0, 0, 0, 4)
    end

    local seperator = self:Add("Panel")
    seperator:Dock(TOP)
    seperator:SetTall(1)
    seperator.Paint = function(this, width, height)
        surface.SetDrawColor(color_white)

        surface.SetMaterial(nut.util.getMaterial("vgui/gradient-r"))
        surface.DrawTexturedRect(0, 0, width * 0.5, height)

        surface.SetMaterial(nut.util.getMaterial("vgui/gradient-l"))
        surface.DrawTexturedRect(width * 0.5, 0, width * 0.5, height)
    end
    seperator:DockMargin(0, 4, 0, 4)

    self.contribLabel = self:Add("DLabel")
    self.contribLabel:SetFont("nutBigCredits")
    self.contribLabel:SetText("Contributors")
    self.contribLabel:SetContentAlignment(4)
    self.contribLabel:SizeToContents()
    self.contribLabel:Dock(TOP)

    self.contribList = self:Add("DIconLayout")
    self.contribList:Dock(TOP)
    self.contribList:SetSpaceX(contributorMargin)
    self.contribList:SetSpaceY(contributorMargin)

    if (!PLUGIN.fetchedContributors) then
        HTTP({
            url = "https://credits-cache.nutscript.xyz/contributors.json",
            method = "GET",
            success = function(code, body, headers)
                PLUGIN.contributorData = {}
                PLUGIN.fetchedContributors = true

                local contributors = util.JSONToTable(body)

                for k, data in ipairs(contributors or {}) do
                    if (istable(data) and data.id) then
                        data.avatar_url = "https://credits-cache.nutscript.xyz/" .. data.id
                        data.url = "https://github.com/" .. data.login

                        table.insert(PLUGIN.contributorData, data)
                    end
                end

                if (IsValid(self)) then
                    self:rebuildContributors()
                end
            end,
            failed = function(message)
                if (IsValid(self)) then
                    self:rebuildContributors()
                end
            end
        })
    else
        self:rebuildContributors()
    end
end

function PANEL:rebuildContributors()
    if (IsValid(self.creatorList)) then
        self.creatorList:Clear()
    end

    if (IsValid(self.maintainerList)) then
        self.maintainerList:Clear()
    end

    self.contribList:Clear()
    self:loadContributor(1, true)
end

function PANEL:loadContributor(contributor, bLoadNextChunk)
    if (PLUGIN.contributorData[contributor]) then
        local isCreator = PLUGIN.nsCreators[PLUGIN.contributorData[contributor].id]
        local isMaintainer = PLUGIN.nsMaintainers[PLUGIN.contributorData[contributor].id]

        local container = vgui.Create("Panel")
        
        if (isCreator) then
            self.creatorList:Add(container)
        elseif (isMaintainer) then
            self.maintainerList:Add(container)
        else
            self.contribList:Add(container)
        end

        container:Dock((isCreator or isMaintainer) and LEFT or NODOCK)
        container:DockMargin(unpack((isCreator or isMaintainer) and {contributorMargin, 0, 0, 0} or {0, 0, 0, 0}))

        container:DockPadding(contributorPadding, contributorPadding, contributorPadding, contributorPadding)

        container.highlightAlpha = 0
        container.Paint = function(this, width, height)
            if (this:IsHovered()) then
                this.highlightAlpha = Lerp(FrameTime() * 16, this.highlightAlpha, 128)
            else
                this.highlightAlpha = Lerp(FrameTime() * 16, this.highlightAlpha, 0)
            end

            surface.SetDrawColor(ColorAlpha(nut.config.get("color"), this.highlightAlpha * 0.5))
            surface.SetMaterial((isCreator or isMaintainer) and nut.util.getMaterial("vgui/gradient-l") or nut.util.getMaterial("vgui/gradient-d"))
            surface.DrawTexturedRect(0, 0, width, height)

            surface.SetDrawColor(ColorAlpha(nut.config.get("color"), this.highlightAlpha))

            if (isCreator or isMaintainer) then
                surface.DrawRect(0, 0, 1, height)
            else
                surface.DrawRect(0, height - 1, width, 1)
            end
        end
        container.OnMousePressed = function(this, keyCode)
            if (keyCode == 107) then
                gui.OpenURL(PLUGIN.contributorData[contributor].url)
            end
        end
        container.OnMouseWheeled = function(this, delta)
            self:OnMouseWheeled(delta)
        end
        container:SetCursor("hand")
        container:SetTooltip(PLUGIN.contributorData[contributor].url)
        
        local avatar = container:Add("DHTML")
        avatar:SetMouseInputEnabled(false)

        avatar:Dock((isCreator or isMaintainer) and LEFT or FILL)
        avatar:DockMargin(unpack((isCreator or isMaintainer) and {0, 0, contributorPadding, 0} or {0, 0, 0, contributorPadding}))
        avatar:SetWide(isCreator and creatorHeight - contributorPadding * 2 or isMaintainer and maintainerHeight - contributorPadding * 2 or 0)

        if (!PLUGIN.encodedAvatarData[contributor]) then
            HTTP({
                url = PLUGIN.contributorData[contributor].avatar_url,
                method = "GET",
                success = function(code, body)
                    PLUGIN.encodedAvatarData[contributor] = util.Base64Encode(body)
    
                    if (IsValid(avatar)) then
                        avatar:SetHTML(
                            "<style>body {overflow: hidden; margin:0;} img {height: 100%; width: 100%; border-radius: 50%;}</style><img src=\"data:image/png;base64,"
                            .. PLUGIN.encodedAvatarData[contributor] .. "\">"
                        )
                    end
                end
            })
        else
            avatar:SetHTML(
                "<style>body {overflow: hidden; margin:0;} img {height: 100%; width: 100%; border-radius: 50%;}</style><img src=\"data:image/png;base64,"
                .. PLUGIN.encodedAvatarData[contributor] .. "\">"
            )
        end

        if (bLoadNextChunk) then
            avatar.OnFinishLoadingDocument = function(this, url)                    
                local toLoad = 3

                for i = 1, toLoad do
                    if (contributor + i > #PLUGIN.contributorData) then
                        return
                    end

                    if (BRANCH != "x86-64") then
                        timer.Simple(0.1, function()
                            if (IsValid(self)) then
                                self:loadContributor(contributor + i, i == toLoad)
                            end
                        end)
                    else
                       self:loadContributor(contributor + i, i == toLoad)
                    end
                end
            end
        end

        local name = container:Add("DLabel")
        name:SetMouseInputEnabled(false)
        name:SetText(PLUGIN.nameOverrides[PLUGIN.contributorData[contributor].id] or PLUGIN.contributorData[contributor].name)
        name:SetContentAlignment(5)

        name:Dock((isCreator or isMaintainer) and FILL or BOTTOM)
        name:SetFont((isCreator or isMaintainer) and "nutBigCredits" or "nutSmallCredits")
        name:SizeToContents()

        container:SetSize(
            isCreator and name:GetWide() + creatorHeight + contributorPadding
            or isMaintainer and name:GetWide() + maintainerHeight + contributorPadding
            or contributorWidth,
            name:GetTall() + contributorWidth + contributorPadding
        )
    end
end

vgui.Register("nutCreditsList", PANEL, "DScrollPanel")

hook.Add("BuildHelpMenu", "nutCreditsList", function(tabs)
	tabs["Credits"] = function()
        if helpPanel then
            local credits = helpPanel:Add("nutCreditsList")
            credits:Dock(FILL)
        end
        return ""
    end
end)
