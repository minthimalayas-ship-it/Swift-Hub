-- Swift Hub | Blox Fruits (Full Script for Raw Hosting)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

local function GetSafeGuiParent()
    if typeof(gethui) == "function" then
        local ok, ui = pcall(gethui)
        if ok and ui then
            return ui
        end
    end
    local pg = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 15)
    return pg
end

local Config = {
    HubName = "Swift Hub",
    SubTitle = "[ Blox Fruits ]",
    LogoAssetId = "", -- ใส่ rbxassetid:// ของโลโก้ฟ้า-ขาวหากต้องการ
    ToggleKey = Enum.KeyCode.RightControl,

    Farm = {
        AutoFarm = false,
        WeaponType = "Melee",      -- Melee, Sword, Blox Fruit
        FarmMethod = "Above",      -- Above, Behind, Below
        Distance = 8,
        AutoEquip = true,
        AutoHaki = true,
        FastAttack = true,
        AttackDelay = 0.14,
    }
}

local CONFIG_FILE = "SwiftHub_BloxFruits_FarmConfig.json"

local function SaveConfig()
    if typeof(writefile) == "function" then
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(Config.Farm))
        end)
    end
end

local function LoadConfig()
    if typeof(isfile) == "function" and typeof(readfile) == "function" then
        pcall(function()
            if isfile(CONFIG_FILE) then
                local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
                if typeof(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        if Config.Farm[k] ~= nil then
                            Config.Farm[k] = v
                        end
                    end
                end
            end
        end)
    end
end

local function ResetConfig()
    Config.Farm = {
        AutoFarm = false,
        WeaponType = "Melee",
        FarmMethod = "Above",
        Distance = 8,
        AutoEquip = true,
        AutoHaki = true,
        FastAttack = true,
        AttackDelay = 0.14,
    }
    SaveConfig()
end

LoadConfig()

local Theme = {
    MainBg = Color3.fromRGB(16, 21, 30),
    SidebarBg = Color3.fromRGB(13, 17, 25),
    CardBg = Color3.fromRGB(22, 28, 39),
    CardHover = Color3.fromRGB(27, 35, 48),
    Stroke = Color3.fromRGB(36, 46, 62),
    AccentBlue = Color3.fromRGB(38, 132, 255),
    AccentCyan = Color3.fromRGB(72, 185, 255),
    TextPrimary = Color3.fromRGB(238, 243, 250),
    TextMuted = Color3.fromRGB(135, 148, 168),
    ToggleOff = Color3.fromRGB(45, 55, 72),
    ToggleOn = Color3.fromRGB(36, 130, 255),
}

local function addCorner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = inst
    return c
end

local function addStroke(inst, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function BuildUI()
    local guiParent = GetSafeGuiParent()
    if not guiParent then
        warn("[Swift Hub] ไม่พบตำแหน่งสำหรับสร้าง UI")
        return
    end

    if guiParent:FindFirstChild("SwiftHub_UI") then
        guiParent:FindFirstChild("SwiftHub_UI"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SwiftHub_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = guiParent

    local FloatToggle = Instance.new("TextButton")
    FloatToggle.Name = "FloatToggle"
    FloatToggle.Size = UDim2.fromOffset(48, 48)
    FloatToggle.Position = UDim2.new(0, 14, 0.5, -24)
    FloatToggle.BackgroundColor3 = Theme.CardBg
    FloatToggle.Text = "⚡"
    FloatToggle.TextColor3 = Theme.AccentCyan
    FloatToggle.TextSize = 20
    FloatToggle.Font = Enum.Font.GothamBold
    FloatToggle.Active = true
    FloatToggle.Draggable = true
    FloatToggle.Parent = ScreenGui
    addCorner(FloatToggle, 12)
    addStroke(FloatToggle, Theme.AccentCyan, 1.4)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(720, 420)
    MainFrame.Position = UDim2.new(0.5, -360, 0.5, -210)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    addCorner(MainFrame, 10)
    addStroke(MainFrame, Theme.Stroke, 1.2)

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = MainFrame

    local function UpdateScale()
        local cam = workspace.CurrentCamera
        if cam then
            local vx, vy = cam.ViewportSize.X, cam.ViewportSize.Y
            local sx = (vx - 30) / 720
            local sy = (vy - 30) / 420
            uiScale.Scale = math.clamp(math.min(sx, sy, 1), 0.55, 1)
        end
    end
    UpdateScale()

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Theme.SidebarBg
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    addCorner(Sidebar, 10)
    addStroke(Sidebar, Theme.Stroke, 1)

    local LogoHeader = Instance.new("Frame")
    LogoHeader.Name = "LogoHeader"
    LogoHeader.Size = UDim2.new(1, -16, 0, 58)
    LogoHeader.Position = UDim2.fromOffset(8, 8)
    LogoHeader.BackgroundColor3 = Theme.CardBg
    LogoHeader.BorderSizePixel = 0
    LogoHeader.Parent = Sidebar
    addCorner(LogoHeader, 8)
    addStroke(LogoHeader, Theme.Stroke, 1)

    local LogoBadge = Instance.new("Frame")
    LogoBadge.Size = UDim2.fromOffset(40, 40)
    LogoBadge.Position = UDim2.fromOffset(9, 9)
    LogoBadge.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
    LogoBadge.BorderSizePixel = 0
    LogoBadge.Parent = LogoHeader
    addCorner(LogoBadge, 8)
    addStroke(LogoBadge, Theme.AccentCyan, 1.2)

    local LogoImage = Instance.new("ImageLabel")
    LogoImage.Size = UDim2.new(1, -6, 1, -6)
    LogoImage.Position = UDim2.fromOffset(3, 3)
    LogoImage.BackgroundTransparency = 1
    LogoImage.ScaleType = Enum.ScaleType.Fit
    LogoImage.Image = Config.LogoAssetId
    LogoImage.Parent = LogoBadge

    local FallbackBolt = Instance.new("TextLabel")
    FallbackBolt.Size = UDim2.fromScale(1, 1)
    FallbackBolt.BackgroundTransparency = 1
    FallbackBolt.Text = "⚡"
    FallbackBolt.TextColor3 = Theme.AccentCyan
    FallbackBolt.TextSize = 20
    FallbackBolt.Font = Enum.Font.GothamBold
    FallbackBolt.Visible = (Config.LogoAssetId == "")
    FallbackBolt.Parent = LogoBadge

    local HubTitle = Instance.new("TextLabel")
    HubTitle.Size = UDim2.new(1, -60, 0, 18)
    HubTitle.Position = UDim2.fromOffset(55, 10)
    HubTitle.BackgroundTransparency = 1
    HubTitle.Text = Config.HubName
    HubTitle.TextColor3 = Theme.TextPrimary
    HubTitle.TextSize = 14
    HubTitle.Font = Enum.Font.GothamBold
    HubTitle.TextXAlignment = Enum.TextXAlignment.Left
    HubTitle.Parent = LogoHeader

    local HubSub = Instance.new("TextLabel")
    HubSub.Size = UDim2.new(1, -60, 0, 15)
    HubSub.Position = UDim2.fromOffset(55, 29)
    HubSub.BackgroundTransparency = 1
    HubSub.Text = Config.SubTitle
    HubSub.TextColor3 = Theme.AccentCyan
    HubSub.TextSize = 11
    HubSub.Font = Enum.Font.GothamMedium
    HubSub.TextXAlignment = Enum.TextXAlignment.Left
    HubSub.Parent = LogoHeader

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -16, 0, 30)
    SearchBox.Position = UDim2.fromOffset(8, 73)
    SearchBox.BackgroundColor3 = Theme.CardBg
    SearchBox.PlaceholderText = "Search..."
    SearchBox.PlaceholderColor3 = Theme.TextMuted
    SearchBox.Text = ""
    SearchBox.TextColor3 = Theme.TextPrimary
    SearchBox.TextSize = 12
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = Sidebar
    addCorner(SearchBox, 6)
    addStroke(SearchBox, Theme.Stroke, 1)

    local NavContainer = Instance.new("ScrollingFrame")
    NavContainer.Size = UDim2.new(1, -16, 1, -116)
    NavContainer.Position = UDim2.fromOffset(8, 110)
    NavContainer.BackgroundTransparency = 1
    NavContainer.ScrollBarThickness = 2
    NavContainer.CanvasSize = UDim2.fromOffset(0, 0)
    NavContainer.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0, 5)
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Parent = NavContainer

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -216, 1, -16)
    ContentArea.Position = UDim2.fromOffset(208, 8)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local HeaderBanner = Instance.new("Frame")
    HeaderBanner.Size = UDim2.new(1, 0, 0, 44)
    HeaderBanner.BackgroundColor3 = Theme.CardBg
    HeaderBanner.BorderSizePixel = 0
    HeaderBanner.Parent = ContentArea
    addCorner(HeaderBanner, 8)
    addStroke(HeaderBanner, Theme.Stroke, 1)

    local PageTitle = Instance.new("TextLabel")
    PageTitle.Size = UDim2.new(1, -20, 0, 20)
    PageTitle.Position = UDim2.fromOffset(12, 4)
    PageTitle.BackgroundTransparency = 1
    PageTitle.Text = "ตั้งค่าฟาร์ม"
    PageTitle.TextColor3 = Theme.TextPrimary
    PageTitle.TextSize = 14
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.Parent = HeaderBanner

    local PageDesc = Instance.new("TextLabel")
    PageDesc.Size = UDim2.new(1, -20, 0, 15)
    PageDesc.Position = UDim2.fromOffset(12, 24)
    PageDesc.BackgroundTransparency = 1
    PageDesc.Text = "ปรับแต่งการฟาร์ม อาวุธ ระยะห่าง และการโจมตีอัตโนมัติ"
    PageDesc.TextColor3 = Theme.TextMuted
    PageDesc.TextSize = 11
    PageDesc.Font = Enum.Font.Gotham
    PageDesc.TextXAlignment = Enum.TextXAlignment.Left
    PageDesc.Parent = HeaderBanner

    local PagesFolder = Instance.new("Frame")
    PagesFolder.Size = UDim2.new(1, 0, 1, -52)
    PagesFolder.Position = UDim2.fromOffset(0, 52)
    PagesFolder.BackgroundTransparency = 1
    PagesFolder.Parent = ContentArea

    local Pages = {}
    local NavButtons = {}

    local function CreatePage(name, title, desc, order)
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Theme.AccentBlue
        page.Visible = false
        page.CanvasSize = UDim2.fromOffset(0, 0)
        page.Parent = PagesFolder

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 7)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
        end)

        Pages[name] = { Frame = page, Title = title, Desc = desc }

        local btn = Instance.new("TextButton")
        btn.Name = name .. "_Tab"
        btn.LayoutOrder = order
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Theme.CardBg
        btn.Text = "   " .. title
        btn.TextColor3 = Theme.TextMuted
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = NavContainer
        addCorner(btn, 6)
        addStroke(btn, Theme.Stroke, 1)

        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.fromOffset(3, 16)
        indicator.Position = UDim2.fromOffset(4, 8)
        indicator.BackgroundColor3 = Theme.AccentBlue
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.Parent = btn
        addCorner(indicator, 2)

        btn.MouseButton1Click:Connect(function()
            for pName, pData in pairs(Pages) do
                local active = (pName == name)
                pData.Frame.Visible = active
                local nBtn = NavButtons[pName]
                nBtn.BackgroundColor3 = active and Theme.CardHover or Theme.CardBg
                nBtn.TextColor3 = active and Theme.TextPrimary or Theme.TextMuted
                nBtn.Indicator.Visible = active
            end
            PageTitle.Text = title
            PageDesc.Text = desc
        end)

        NavButtons[name] = btn
        NavContainer.CanvasSize = UDim2.fromOffset(0, NavLayout.AbsoluteContentSize.Y + 8)
        return page
    end

    local function CreateSectionLabel(parent, text, order)
        local lbl = Instance.new("TextLabel")
        lbl.LayoutOrder = order
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Theme.AccentCyan
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        return lbl
    end

    local function CreateToggleCard(parent, title, desc, defaultVal, order, callback)
        local card = Instance.new("Frame")
        card.Name = title
        card.LayoutOrder = order
        card.Size = UDim2.new(1, 0, 0, 52)
        card.BackgroundColor3 = Theme.CardBg
        card.BorderSizePixel = 0
        card.Parent = parent
        addCorner(card, 8)
        addStroke(card, Theme.Stroke, 1)

        local tLbl = Instance.new("TextLabel")
        tLbl.Size = UDim2.new(1, -76, 0, 18)
        tLbl.Position = UDim2.fromOffset(12, 7)
        tLbl.BackgroundTransparency = 1
        tLbl.Text = title
        tLbl.TextColor3 = Theme.TextPrimary
        tLbl.TextSize = 12
        tLbl.Font = Enum.Font.GothamBold
        tLbl.TextXAlignment = Enum.TextXAlignment.Left
        tLbl.Parent = card

        local dLbl = Instance.new("TextLabel")
        dLbl.Size = UDim2.new(1, -76, 0, 16)
        dLbl.Position = UDim2.fromOffset(12, 27)
        dLbl.BackgroundTransparency = 1
        dLbl.Text = desc
        dLbl.TextColor3 = Theme.TextMuted
        dLbl.TextSize = 11
        dLbl.Font = Enum.Font.Gotham
        dLbl.TextXAlignment = Enum.TextXAlignment.Left
        dLbl.Parent = card

        local switchBg = Instance.new("TextButton")
        switchBg.Size = UDim2.fromOffset(44, 22)
        switchBg.Position = UDim2.new(1, -56, 0.5, -11)
        switchBg.BackgroundColor3 = defaultVal and Theme.ToggleOn or Theme.ToggleOff
        switchBg.Text = ""
        switchBg.AutoButtonColor = false
        switchBg.Parent = card
        addCorner(switchBg, 11)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(16, 16)
        knob.Position = defaultVal and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.Parent = switchBg
        addCorner(knob, 8)

        local state = defaultVal
        local function setState(val)
            state = val
            switchBg.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
            knob.Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
            if callback then pcall(callback, state) end
        end

        switchBg.MouseButton1Click:Connect(function()
            setState(not state)
            SaveConfig()
        end)

        return { Set = setState, Get = function() return state end }
    end

    local function CreateDropdownCard(parent, title, desc, options, defaultOption, order, callback)
        local card = Instance.new("Frame")
        card.Name = title
        card.LayoutOrder = order
        card.Size = UDim2.new(1, 0, 0, 52)
        card.BackgroundColor3 = Theme.CardBg
        card.BorderSizePixel = 0
        card.ClipsDescendants = false
        card.Parent = parent
        addCorner(card, 8)
        addStroke(card, Theme.Stroke, 1)

        local tLbl = Instance.new("TextLabel")
        tLbl.Size = UDim2.new(1, -170, 0, 18)
        tLbl.Position = UDim2.fromOffset(12, 7)
        tLbl.BackgroundTransparency = 1
        tLbl.Text = title
        tLbl.TextColor3 = Theme.TextPrimary
        tLbl.TextSize = 12
        tLbl.Font = Enum.Font.GothamBold
        tLbl.TextXAlignment = Enum.TextXAlignment.Left
        tLbl.Parent = card

        local dLbl = Instance.new("TextLabel")
        dLbl.Size = UDim2.new(1, -170, 0, 16)
        dLbl.Position = UDim2.fromOffset(12, 27)
        dLbl.BackgroundTransparency = 1
        dLbl.Text = desc
        dLbl.TextColor3 = Theme.TextMuted
        dLbl.TextSize = 11
        dLbl.Font = Enum.Font.Gotham
        dLbl.TextXAlignment = Enum.TextXAlignment.Left
        dLbl.Parent = card

        local current = defaultOption
        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.fromOffset(140, 28)
        dropBtn.Position = UDim2.new(1, -152, 0.5, -14)
        dropBtn.BackgroundColor3 = Theme.SidebarBg
        dropBtn.Text = current .. "  v"
        dropBtn.TextColor3 = Theme.TextPrimary
        dropBtn.TextSize = 12
        dropBtn.Font = Enum.Font.GothamMedium
        dropBtn.AutoButtonColor = false
        dropBtn.Parent = card
        addCorner(dropBtn, 6)
        addStroke(dropBtn, Theme.Stroke, 1)

        local menu = Instance.new("Frame")
        menu.Size = UDim2.fromOffset(140, #options * 28)
        menu.Position = UDim2.new(1, -152, 0.5, 16)
        menu.BackgroundColor3 = Theme.SidebarBg
        menu.BorderSizePixel = 0
        menu.Visible = false
        menu.ZIndex = 30
        menu.Parent = card
        addCorner(menu, 6)
        addStroke(menu, Theme.AccentBlue, 1)

        local mLayout = Instance.new("UIListLayout")
        mLayout.Parent = menu

        for _, opt in ipairs(options) do
            local item = Instance.new("TextButton")
            item.Size = UDim2.new(1, 0, 0, 28)
            item.BackgroundTransparency = 1
            item.Text = opt
            item.TextColor3 = Theme.TextPrimary
            item.TextSize = 12
            item.Font = Enum.Font.Gotham
            item.ZIndex = 31
            item.Parent = menu

            item.MouseButton1Click:Connect(function()
                current = opt
                dropBtn.Text = current .. "  v"
                menu.Visible = false
                if callback then pcall(callback, current) end
                SaveConfig()
            end)
        end

        dropBtn.MouseButton1Click:Connect(function()
            menu.Visible = not menu.Visible
        end)

        return {
            Set = function(val)
                current = val
                dropBtn.Text = current .. "  v"
                if callback then pcall(callback, current) end
            end
        }
    end

    local function CreateNumberCard(parent, title, desc, defaultNum, minVal, maxVal, order, callback)
        local card = Instance.new("Frame")
        card.Name = title
        card.LayoutOrder = order
        card.Size = UDim2.new(1, 0, 0, 52)
        card.BackgroundColor3 = Theme.CardBg
        card.BorderSizePixel = 0
        card.Parent = parent
        addCorner(card, 8)
        addStroke(card, Theme.Stroke, 1)

        local tLbl = Instance.new("TextLabel")
        tLbl.Size = UDim2.new(1, -120, 0, 18)
        tLbl.Position = UDim2.fromOffset(12, 7)
        tLbl.BackgroundTransparency = 1
        tLbl.Text = title
        tLbl.TextColor3 = Theme.TextPrimary
        tLbl.Tex
