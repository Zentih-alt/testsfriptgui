--[[
================================================================================
  SolarV2.lua — Zentih Custom UI Library
  Windows 11 Inspired Clean Roblox Executor UI Library
================================================================================
]]

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local function tw(obj, props, duration, easingStyle, easingDir)
    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(duration or 0.18, easingStyle or Enum.EasingStyle.Quint, easingDir or Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

local Theme = {
    MainBG = Color3.fromRGB(246, 246, 248),
    SidebarBG = Color3.fromRGB(238, 238, 242),
    GroupyHeaderBG = Color3.fromRGB(235, 226, 238),
    GroupyTabActive = Color3.fromRGB(255, 255, 255),
    GroupyTabInactive = Color3.fromRGB(218, 208, 222),
    CardBG = Color3.fromRGB(255, 255, 255),
    CardBorder = Color3.fromRGB(225, 225, 232),
    TextPrimary = Color3.fromRGB(20, 20, 25),
    TextSecondary = Color3.fromRGB(110, 110, 120),
    Accent = Color3.fromRGB(0, 95, 184),
    AccentHover = Color3.fromRGB(24, 115, 204),
    ToggleOff = Color3.fromRGB(210, 210, 220)
}

local Solar = {}

function Solar.CreateWindow(config)
    config = config or {}
    local HubTitle = config.Title or "Zentih"
    local HubSubtitle = config.Subtitle or "None"

    local oldUI = CoreGui:FindFirstChild("Zentih_Engine") or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Zentih_Engine")
    if oldUI then oldUI:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "Zentih_Engine"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        syn.protect_gui(sg)
        sg.Parent = CoreGui
    elseif gethui then
        sg.Parent = gethui()
    else
        pcall(function() sg.Parent = CoreGui end)
        if not sg.Parent then sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    end

    local WIN_W, WIN_H = 860, 560
    local SIDEBAR_W = 175
    local GROUPY_BAR_H = 36
    local TOPBAR_H = 44

    local uiVisible = true
    local activeCloseDropdown = nil

    -- Main Window Frame
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = Theme.MainBG
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    main.Active = true
    main.Parent = sg

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.CardBorder
    mainStroke.Thickness = 1
    mainStroke.Parent = main

    -- Responsive Scale Engine
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = main

    local function updateScale()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local scale = math.min((vp.X - 30) / WIN_W, (vp.Y - 30) / WIN_H)
        uiScale.Scale = math.clamp(scale, 0.55, 1.0)
    end
    updateScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end

    -- 1. TOP BAR & APP TABS
    local groupyBar = Instance.new("Frame")
    groupyBar.Name = "TopHeaderBar"
    groupyBar.Size = UDim2.new(1, 0, 0, GROUPY_BAR_H)
    groupyBar.BackgroundColor3 = Theme.GroupyHeaderBG
    groupyBar.BorderSizePixel = 0
    groupyBar.Parent = main
    Instance.new("UICorner", groupyBar).CornerRadius = UDim.new(0, 8)

    local groupyFix = Instance.new("Frame")
    groupyFix.Size = UDim2.new(1, 0, 0, 10)
    groupyFix.Position = UDim2.new(0, 0, 1, -10)
    groupyFix.BackgroundColor3 = Theme.GroupyHeaderBG
    groupyFix.BorderSizePixel = 0
    groupyFix.Parent = groupyBar

    -- Separate Home Button (แยกปุ่มบ้านออกจากแถบแท็บ)
    local homeBtn = Instance.new("TextButton")
    homeBtn.Size = UDim2.new(0, 78, 0, 26)
    homeBtn.Position = UDim2.new(0, 8, 0, 5)
    homeBtn.BackgroundColor3 = Theme.GroupyTabActive
    homeBtn.Text = "🏠 Home"
    homeBtn.TextSize = 11
    homeBtn.TextColor3 = Theme.TextPrimary
    homeBtn.Font = Enum.Font.GothamMedium
    homeBtn.Parent = groupyBar
    Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0, 5)

    -- Tabs Container Frame
    local topTabsFrame = Instance.new("Frame")
    topTabsFrame.Size = UDim2.new(1, -160, 1, 0)
    topTabsFrame.Position = UDim2.new(0, 92, 0, 0)
    topTabsFrame.BackgroundTransparency = 1
    topTabsFrame.Parent = groupyBar

    local topTabsData = {
        { Title = "Stardock Groupy 2 Co...", Active = true },
        { Title = "Stardock Start11...", Active = false },
        { Title = "Fences 4", Active = false },
        { Title = "WindowBlinds 11...", Active = false }
    }

    local currentOffsetX = 0
    for _, tData in ipairs(topTabsData) do
        local tabW = 135
        local gTab = Instance.new("Frame")
        gTab.Size = UDim2.new(0, tabW, 0, 26)
        gTab.Position = UDim2.new(0, currentOffsetX, 0, 5)
        gTab.BackgroundColor3 = tData.Active and Theme.GroupyTabActive or Theme.GroupyTabInactive
        gTab.Parent = topTabsFrame
        Instance.new("UICorner", gTab).CornerRadius = UDim.new(0, 5)

        local gLbl = Instance.new("TextLabel")
        gLbl.Size = UDim2.new(1, -22, 1, 0)
        gLbl.Position = UDim2.new(0, 8, 0, 0)
        gLbl.BackgroundTransparency = 1
        gLbl.Text = tData.Title
        gLbl.TextSize = 11
        gLbl.TextColor3 = tData.Active and Theme.TextPrimary or Theme.TextSecondary
        gLbl.Font = Enum.Font.Gotham
        gLbl.TextXAlignment = Enum.TextXAlignment.Left
        gLbl.TextTruncate = Enum.TextTruncate.AtEnd
        gLbl.Parent = gTab

        local gClose = Instance.new("TextButton")
        gClose.Size = UDim2.new(0, 16, 0, 16)
        gClose.Position = UDim2.new(1, -18, 0.5, -8)
        gClose.BackgroundTransparency = 1
        gClose.Text = "✕"
        gClose.TextSize = 9
        gClose.TextColor3 = Theme.TextSecondary
        gClose.Parent = gTab

        gClose.MouseButton1Click:Connect(function() gTab:Destroy() end)
        currentOffsetX = currentOffsetX + tabW + 5
    end

    -- Window Controls (- ✕) เฉพาะย่อและปิดตามสั่ง
    local winControls = Instance.new("Frame")
    winControls.Size = UDim2.new(0, 65, 1, 0)
    winControls.Position = UDim2.new(1, -65, 0, 0)
    winControls.BackgroundTransparency = 1
    winControls.Parent = groupyBar

    local winMin = Instance.new("TextButton")
    winMin.Size = UDim2.new(0, 30, 1, 0)
    winMin.Position = UDim2.new(0, 0, 0, 0)
    winMin.BackgroundTransparency = 1
    winMin.Text = "─"
    winMin.TextSize = 12
    winMin.TextColor3 = Theme.TextPrimary
    winMin.Parent = winControls

    local winClose = Instance.new("TextButton")
    winClose.Size = UDim2.new(0, 35, 1, 0)
    winClose.Position = UDim2.new(0, 30, 0, 0)
    winClose.BackgroundTransparency = 1
    winClose.Text = "✕"
    winClose.TextSize = 12
    winClose.TextColor3 = Theme.TextPrimary
    winClose.Parent = winControls

    -- 2. SIDEBAR NAVIGATION (ลดขนาดเรียบหรู)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -GROUPY_BAR_H)
    sidebar.Position = UDim2.new(0, 0, 0, GROUPY_BAR_H)
    sidebar.BackgroundColor3 = Theme.SidebarBG
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local brandHeader = Instance.new("Frame")
    brandHeader.Size = UDim2.new(1, 0, 0, 42)
    brandHeader.BackgroundTransparency = 1
    brandHeader.Parent = sidebar

    local brandTitle = Instance.new("TextLabel")
    brandTitle.Size = UDim2.new(1, -20, 0, 18)
    brandTitle.Position = UDim2.new(0, 14, 0, 8)
    brandTitle.BackgroundTransparency = 1
    brandTitle.Text = HubTitle
    brandTitle.TextSize = 14
    brandTitle.TextColor3 = Theme.TextPrimary
    brandTitle.Font = Enum.Font.GothamBold
    brandTitle.TextXAlignment = Enum.TextXAlignment.Left
    brandTitle.Parent = brandHeader

    local brandSub = Instance.new("TextLabel")
    brandSub.Size = UDim2.new(1, -20, 0, 12)
    brandSub.Position = UDim2.new(0, 14, 0, 26)
    brandSub.BackgroundTransparency = 1
    brandSub.Text = HubSubtitle
    brandSub.TextSize = 10
    brandSub.TextColor3 = Theme.Accent
    brandSub.Font = Enum.Font.Gotham
    brandSub.TextXAlignment = Enum.TextXAlignment.Left
    brandSub.Parent = brandHeader

    local navScroll = Instance.new("ScrollingFrame")
    navScroll.Size = UDim2.new(1, 0, 1, -46)
    navScroll.Position = UDim2.new(0, 0, 0, 44)
    navScroll.BackgroundTransparency = 1
    navScroll.BorderSizePixel = 0
    navScroll.ScrollBarThickness = 2
    navScroll.ScrollBarImageColor3 = Theme.CardBorder
    navScroll.Parent = sidebar

    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 3)
    navLayout.Parent = navScroll

    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0, 8)
    navPad.PaddingRight = UDim.new(0, 8)
    navPad.Parent = navScroll

    -- 3. CONTENT AREA
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -SIDEBAR_W, 1, -GROUPY_BAR_H)
    contentArea.Position = UDim2.new(0, SIDEBAR_W, 0, GROUPY_BAR_H)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -30, 0, TOPBAR_H)
    headerTitle.Position = UDim2.new(0, 18, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Dashboard"
    headerTitle.TextSize = 17 -- ลดขนาดตามที่วงสีเขียว
    headerTitle.TextColor3 = Theme.TextPrimary
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = contentArea

    local pagesContainer = Instance.new("Frame")
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Size = UDim2.new(1, 0, 1, -TOPBAR_H)
    pagesContainer.Position = UDim2.new(0, 0, 0, TOPBAR_H)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.Parent = contentArea

    -- Dragging Logic
    local dragging, dragStart, startPos
    groupyBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local function toggleUI()
        uiVisible = not uiVisible
        if activeCloseDropdown then activeCloseDropdown() activeCloseDropdown = nil end
        if uiVisible then
            main.Visible = true
            tw(main, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.22)
        else
            tw(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.18)
            task.delay(0.18, function() main.Visible = false end)
        end
    end

    winMin.MouseButton1Click:Connect(toggleUI)
    winClose.MouseButton1Click:Connect(toggleUI)

    -- Window API & Tab Engine
    local WindowAPI = { Flags = {} }
    local tabsList = {}

    function WindowAPI.AddTab(tabName, iconSymbol)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 32)
        tabBtn.BackgroundColor3 = Theme.CardBG
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = ""
        tabBtn.Parent = navScroll
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 5)

        local activePill = Instance.new("Frame")
        activePill.Size = UDim2.new(0, 3, 0, 14)
        activePill.Position = UDim2.new(0, 2, 0.5, -7)
        activePill.BackgroundColor3 = Theme.Accent
        activePill.BackgroundTransparency = 1
        activePill.Parent = tabBtn
        Instance.new("UICorner", activePill).CornerRadius = UDim.new(1, 0)

        local tabIcon = Instance.new("TextLabel")
        tabIcon.Size = UDim2.new(0, 18, 1, 0)
        tabIcon.Position = UDim2.new(0, 10, 0, 0)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Text = iconSymbol or "📄"
        tabIcon.TextSize = 12
        tabIcon.TextColor3 = Theme.TextSecondary
        tabIcon.Parent = tabBtn

        local tabLbl = Instance.new("TextLabel")
        tabLbl.Size = UDim2.new(1, -34, 1, 0)
        tabLbl.Position = UDim2.new(0, 30, 0, 0)
        tabLbl.BackgroundTransparency = 1
        tabLbl.Text = tabName
        tabLbl.TextSize = 11
        tabLbl.TextColor3 = Theme.TextSecondary
        tabLbl.Font = Enum.Font.GothamMedium
        tabLbl.TextXAlignment = Enum.TextXAlignment.Left
        tabLbl.Parent = tabBtn

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Size = UDim2.new(1, 0, 1, 0)
        pageScroll.BackgroundTransparency = 1
        pageScroll.BorderSizePixel = 0
        pageScroll.ScrollBarThickness = 3
        pageScroll.ScrollBarImageColor3 = Theme.CardBorder
        pageScroll.Visible = false
        pageScroll.Parent = pagesContainer

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 12)
        pageLayout.Parent = pageScroll

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingLeft = UDim.new(0, 18)
        pagePad.PaddingRight = UDim.new(0, 22)
        pagePad.PaddingTop = UDim.new(0, 2)
        pagePad.PaddingBottom = UDim.new(0, 24)
        pagePad.Parent = pageScroll

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 30)
        end)

        local TabAPI = {}

        local function activate()
            if activeCloseDropdown then activeCloseDropdown() activeCloseDropdown = nil end
            for _, t in ipairs(tabsList) do
                t.Page.Visible = false
                tw(t.Pill, {BackgroundTransparency = 1}, 0.15)
                tw(t.Label, {TextColor3 = Theme.TextSecondary}, 0.15)
                tw(t.Icon, {TextColor3 = Theme.TextSecondary}, 0.15)
                tw(t.Btn, {BackgroundTransparency = 1}, 0.15)
            end
            pageScroll.Visible = true
            headerTitle.Text = tabName
            tw(activePill, {BackgroundTransparency = 0}, 0.15)
            tw(tabLbl, {TextColor3 = Theme.TextPrimary}, 0.15)
            tw(tabIcon, {TextColor3 = Theme.Accent}, 0.15)
            tw(tabBtn, {BackgroundTransparency = 0.7, BackgroundColor3 = Theme.CardBG}, 0.15)
        end

        tabBtn.MouseButton1Click:Connect(activate)
        table.insert(tabsList, { Btn = tabBtn, Pill = activePill, Label = tabLbl, Icon = tabIcon, Page = pageScroll })

        if #tabsList == 1 then activate() end

        -- Base Full Width Card Helper
        local function createCard(height)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, height or 54)
            card.BackgroundColor3 = Theme.CardBG
            card.Parent = pageScroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke")
            stroke.Color = Theme.CardBorder
            stroke.Thickness = 1
            stroke.Parent = card
            return card, stroke
        end

        -- SECTION LABEL
        function TabAPI:AddSection(text)
            local secLbl = Instance.new("TextLabel")
            secLbl.Size = UDim2.new(1, 0, 0, 22)
            secLbl.BackgroundTransparency = 1
            secLbl.Text = text
            secLbl.TextSize = 12
            secLbl.TextColor3 = Theme.Accent
            secLbl.Font = Enum.Font.GothamBold
            secLbl.TextXAlignment = Enum.TextXAlignment.Left
            secLbl.Parent = pageScroll
        end

        -- ROW GROUP CONTAINER (การ์ดผืนยาวสำหรับ Toggle สวิตช์แคปซูลใหญ่)
        function TabAPI:AddGroupContainer(togglesData)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, #togglesData * 56)
            container.BackgroundColor3 = Theme.CardBG
            container.Parent = pageScroll
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

            local cStroke = Instance.new("UIStroke")
            cStroke.Color = Theme.CardBorder
            cStroke.Thickness = 1
            cStroke.Parent = container

            for idx, item in ipairs(togglesData) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 56)
                row.Position = UDim2.new(0, 0, 0, (idx - 1) * 56)
                row.BackgroundTransparency = 1
                row.Parent = container

                if idx < #togglesData then
                    local line = Instance.new("Frame")
                    line.Size = UDim2.new(1, -32, 0, 1)
                    line.Position = UDim2.new(0, 16, 1, -1)
                    line.BackgroundColor3 = Theme.CardBorder
                    line.BorderSizePixel = 0
                    line.Parent = row
                end

                -- Title 50% Left Area
                local tLbl = Instance.new("TextLabel")
                tLbl.Size = UDim2.new(0.5, -20, 0, 18)
                tLbl.Position = UDim2.new(0, 16, 0, item.Description and 8 or 19)
                tLbl.BackgroundTransparency = 1
                tLbl.Text = item.Title or "Title"
                tLbl.TextSize = 12
                tLbl.TextColor3 = Theme.TextPrimary
                tLbl.Font = Enum.Font.GothamMedium
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.Parent = row

                if item.Description and item.Description ~= "" then
                    local dLbl = Instance.new("TextLabel")
                    dLbl.Size = UDim2.new(0.5, -20, 0, 22)
                    dLbl.Position = UDim2.new(0, 16, 0, 26)
                    dLbl.BackgroundTransparency = 1
                    dLbl.Text = item.Description
                    dLbl.TextSize = 10
                    dLbl.TextColor3 = Theme.TextSecondary
                    dLbl.Font = Enum.Font.Gotham
                    dLbl.TextXAlignment = Enum.TextXAlignment.Left
                    dLbl.TextWrapped = true
                    dLbl.Parent = row
                end

                -- Right 50% Control Area
                local stateText = Instance.new("TextLabel")
                stateText.Size = UDim2.new(0, 28, 0, 20)
                stateText.Position = UDim2.new(1, -88, 0.5, -10)
                stateText.BackgroundTransparency = 1
                stateText.Text = item.Default and "On" or "Off"
                stateText.TextSize = 12
                stateText.TextColor3 = Theme.TextPrimary
                stateText.Font = Enum.Font.GothamMedium
                stateText.TextXAlignment = Enum.TextXAlignment.Right
                stateText.Parent = row

                local state = item.Default or false
                local switch = Instance.new("Frame")
                switch.Size = UDim2.new(0, 44, 0, 22)
                switch.Position = UDim2.new(1, -54, 0.5, -11)
                switch.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
                switch.Parent = row
                Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 16, 0, 16)
                knob.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                knob.Parent = switch
                Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

                local clickBtn = Instance.new("TextButton")
                clickBtn.Size = UDim2.new(1, 0, 1, 0)
                clickBtn.BackgroundTransparency = 1
                clickBtn.Text = ""
                clickBtn.Parent = row

                clickBtn.MouseButton1Click:Connect(function()
                    state = not state
                    stateText.Text = state and "On" or "Off"
                    tw(switch, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}, 0.15)
                    tw(knob, {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.15)
                    if item.Callback then pcall(item.Callback, state) end
                end)
            end
        end

        -- BUTTON CARD (แบ่งครึ่ง ซ้าย 50% ขวา 50%)
        function TabAPI:AddButton(title, desc, callback)
            local card = createCard(desc and 54 or 46)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.5, -20, 0, desc and 18 or 0)
            tLbl.Position = UDim2.new(0, 16, 0.5, desc and -16 or 0)
            if not desc then tLbl.Size = UDim2.new(0.5, -20, 1, 0) tLbl.Position = UDim2.new(0, 16, 0, 0) end
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 12
            tLbl.TextColor3 = Theme.TextPrimary
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            if desc then
                local dLbl = Instance.new("TextLabel")
                dLbl.Size = UDim2.new(0.5, -20, 0, 14)
                dLbl.Position = UDim2.new(0, 16, 0.5, 2)
                dLbl.BackgroundTransparency = 1
                dLbl.Text = desc
                dLbl.TextSize = 10
                dLbl.TextColor3 = Theme.TextSecondary
                dLbl.Font = Enum.Font.Gotham
                dLbl.TextXAlignment = Enum.TextXAlignment.Left
                dLbl.Parent = card
            end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 110, 0, 30)
            btn.Position = UDim2.new(1, -126, 0.5, -15)
            btn.BackgroundColor3 = Theme.Accent
            btn.Text = "Execute"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.Parent = card
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

            btn.MouseButton1Click:Connect(function()
                tw(btn, {BackgroundColor3 = Theme.AccentHover}, 0.08)
                task.delay(0.08, function() tw(btn, {BackgroundColor3 = Theme.Accent}, 0.1) end)
                if callback then pcall(callback) end
            end)
        end

        -- SLIDER CARD (แบ่งครึ่ง ซ้าย 50% ขวา 50%)
        function TabAPI:AddSlider(title, min, max, default, callback, flag)
            min, max = min or 0, max or 100
            local val = math.clamp(default or min, min, max)
            local card = createCard(52)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.5, -20, 1, 0)
            tLbl.Position = UDim2.new(0, 16, 0, 0)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 12
            tLbl.TextColor3 = Theme.TextPrimary
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 45, 0, 20)
            valLbl.Position = UDim2.new(1, -60, 0, 6)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(val)
            valLbl.TextColor3 = Theme.Accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 12
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = card

            local track = Instance.new("Frame")
            track.Size = UDim2.new(0.42, 0, 0, 5)
            track.Position = UDim2.new(0.5, 0, 1, -14)
            track.BackgroundColor3 = Theme.CardBorder
            track.Parent = card
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((val - min)/(max - min), 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local isDragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max - min) * pos)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                valLbl.Text = tostring(val)
                if callback then pcall(callback, val) end
            end

            card.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true ; updateSlider(input)
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            local obj = {
                Set = function(_, v)
                    val = math.clamp(v, min, max)
                    fill.Size = UDim2.new((val - min)/(max - min), 0, 1, 0)
                    valLbl.Text = tostring(val)
                end,
                Get = function() return val end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        -- DROPDOWN CARD (แก้ไขปัญหาการเด้งตำแหน่งในภาพที่ 2 เด้งตรงพอดี)
        function TabAPI:AddDropdown(title, desc, options, default, callback, flag)
            local card = createCard(48)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.5, -20, 1, 0)
            tLbl.Position = UDim2.new(0, 16, 0, 0)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 12
            tLbl.TextColor3 = Theme.TextPrimary
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            local selected = default or options[1] or "Select"
            local open = false

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0, 140, 0, 28)
            box.Position = UDim2.new(1, -156, 0.5, -14)
            box.BackgroundColor3 = Theme.MainBG
            box.Text = tostring(selected) .. "  ▼"
            box.TextColor3 = Theme.TextPrimary
            box.Font = Enum.Font.Gotham
            box.TextSize = 11
            box.Parent = card
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
            Instance.new("UIStroke", box).Color = Theme.CardBorder

            local dropList = Instance.new("Frame")
            dropList.Size = UDim2.new(0, 140, 0, math.min(#options, 5) * 28 + 6)
            dropList.BackgroundColor3 = Theme.CardBG
            dropList.Visible = false
            dropList.ZIndex = 9999
            dropList.Parent = sg
            Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", dropList).Color = Theme.CardBorder

            local listScroll = Instance.new("ScrollingFrame")
            listScroll.Size = UDim2.new(1, -4, 1, -4)
            listScroll.Position = UDim2.new(0, 2, 0, 2)
            listScroll.BackgroundTransparency = 1
            listScroll.ScrollBarThickness = 2
            listScroll.Parent = dropList
            Instance.new("UIListLayout", listScroll).SortOrder = Enum.SortOrder.LayoutOrder

            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundTransparency = 1
                optBtn.Text = tostring(opt)
                optBtn.TextColor3 = Theme.TextPrimary
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.Parent = listScroll

                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    box.Text = tostring(selected) .. "  ▼"
                    dropList.Visible = false
                    open = false
                    if callback then pcall(callback, selected) end
                end)
            end

            box.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    if activeCloseDropdown then activeCloseDropdown() end
                    local abs = box.AbsolutePosition
                    dropList.Position = UDim2.new(0, abs.X, 0, abs.Y + 32)
                    dropList.Visible = true
                    activeCloseDropdown = function() dropList.Visible = false open = false end
                else
                    dropList.Visible = false
                end
            end)
        end

        -- INPUT TEXTBOX
        function TabAPI:AddInput(title, placeholder, callback)
            local card = createCard(46)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.5, -20, 1, 0)
            tLbl.Position = UDim2.new(0, 16, 0, 0)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 12
            tLbl.TextColor3 = Theme.TextPrimary
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            local inpWrap = Instance.new("Frame")
            inpWrap.Size = UDim2.new(0, 140, 0, 28)
            inpWrap.Position = UDim2.new(1, -156, 0.5, -14)
            inpWrap.BackgroundColor3 = Theme.MainBG
            inpWrap.Parent = card
            Instance.new("UICorner", inpWrap).CornerRadius = UDim.new(0, 4)
            Instance.new("UIStroke", inpWrap).Color = Theme.CardBorder

            local inpBox = Instance.new("TextBox")
            inpBox.Size = UDim2.new(1, -10, 1, 0)
            inpBox.Position = UDim2.new(0, 5, 0, 0)
            inpBox.BackgroundTransparency = 1
            inpBox.Text = ""
            inpBox.PlaceholderText = placeholder or "Enter..."
            inpBox.PlaceholderColor3 = Theme.TextSecondary
            inpBox.TextColor3 = Theme.TextPrimary
            inpBox.TextSize = 11
            inpBox.Font = Enum.Font.Gotham
            inpBox.ClearTextOnFocus = false
            inpBox.Parent = inpWrap

            inpBox.FocusLost:Connect(function()
                if callback then pcall(callback, inpBox.Text) end
            end)
        end

        return TabAPI
    end

    return WindowAPI
end

return Solar
