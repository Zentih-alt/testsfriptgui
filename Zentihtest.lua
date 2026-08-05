--[[
================================================================================
  SolarV2.lua — Exact Windows 11 / Stardock Groupy 2 UI Library
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

-- โทนสีแกะถอดจากรูปภาพ 100%
local Theme = {
    MainBG = Color3.fromRGB(246, 246, 248),
    SidebarBG = Color3.fromRGB(240, 240, 244),
    GroupyHeaderBG = Color3.fromRGB(235, 226, 238), -- สีแท็บแอปด้านบนสุดสไตล์ Groupy 2
    GroupyTabActive = Color3.fromRGB(255, 255, 255),
    GroupyTabInactive = Color3.fromRGB(218, 208, 222),
    CardBG = Color3.fromRGB(255, 255, 255),
    CardBorder = Color3.fromRGB(225, 225, 232),
    CardHover = Color3.fromRGB(250, 250, 254),
    TextPrimary = Color3.fromRGB(30, 30, 35),
    TextSecondary = Color3.fromRGB(115, 115, 125),
    Accent = Color3.fromRGB(0, 95, 184), -- Windows 11 Blue Accent
    AccentHover = Color3.fromRGB(24, 115, 204),
    MockupBG = Color3.fromRGB(232, 238, 246),
    MockupInner = Color3.fromRGB(212, 224, 240)
}

local Solar = {}

function Solar.CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "Tab appearance"

    local oldUI = CoreGui:FindFirstChild("SolarV2_Win11") or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SolarV2_Win11")
    if oldUI then oldUI:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "SolarV2_Win11"
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

    local WIN_W, WIN_H = 880, 570
    local SIDEBAR_W = 195
    local GROUPY_BAR_H = 36
    local TOPBAR_H = 50

    local uiVisible = true

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

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = main

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

    -- 1. GROUPY 2 TOP APP TAB BAR (ถอดจากรูปเป๊ะๆ)
    local groupyBar = Instance.new("Frame")
    groupyBar.Name = "GroupyBar"
    groupyBar.Size = UDim2.new(1, 0, 0, GROUPY_BAR_H)
    groupyBar.BackgroundColor3 = Theme.GroupyHeaderBG
    groupyBar.BorderSizePixel = 0
    groupyBar.Parent = main

    local groupyCorner = Instance.new("UICorner")
    groupyCorner.CornerRadius = UDim.new(0, 8)
    groupyCorner.Parent = groupyBar

    local groupyFix = Instance.new("Frame")
    groupyFix.Size = UDim2.new(1, 0, 0, 10)
    groupyFix.Position = UDim2.new(0, 0, 1, -10)
    groupyFix.BackgroundColor3 = Theme.GroupyHeaderBG
    groupyFix.BorderSizePixel = 0
    groupyFix.Parent = groupyBar

    -- Top Tabs Data
    local topTabsData = {
        { Title = "Stardock Groupy 2 Co...", Active = true },
        { Title = "Stardock Start11 Configur...", Active = false },
        { Title = "Fences 4", Active = false },
        { Title = "WindowBlinds 11 Configu...", Active = false },
        { Title = "Home", Active = false }
    }

    local currentOffsetX = 30
    for _, tData in ipairs(topTabsData) do
        local tabW = tData.Active and 165 or 145
        local gTab = Instance.new("Frame")
        gTab.Size = UDim2.new(0, tabW, 0, 26)
        gTab.Position = UDim2.new(0, currentOffsetX, 0, 5)
        gTab.BackgroundColor3 = tData.Active and Theme.GroupyTabActive or Theme.GroupyTabInactive
        gTab.Parent = groupyBar
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

        local gClose = Instance.new("TextLabel")
        gClose.Size = UDim2.new(0, 14, 0, 14)
        gClose.Position = UDim2.new(1, -18, 0.5, -7)
        gClose.BackgroundTransparency = 1
        gClose.Text = "✕"
        gClose.TextSize = 9
        gClose.TextColor3 = Theme.TextSecondary
        gClose.Parent = gTab

        currentOffsetX = currentOffsetX + tabW + 6
    end

    -- Windows Controls (- □ ✕) ชิดขวา
    local winControls = Instance.new("Frame")
    winControls.Size = UDim2.new(0, 95, 1, 0)
    winControls.Position = UDim2.new(1, -95, 0, 0)
    winControls.BackgroundTransparency = 1
    winControls.Parent = groupyBar

    local winMin = Instance.new("TextButton")
    winMin.Size = UDim2.new(0, 30, 1, 0)
    winMin.Position = UDim2.new(0, 0, 0, 0)
    winMin.BackgroundTransparency = 1
    winMin.Text = "─"
    winMin.TextSize = 10
    winMin.TextColor3 = Theme.TextPrimary
    winMin.Parent = winControls

    local winMax = Instance.new("TextButton")
    winMax.Size = UDim2.new(0, 30, 1, 0)
    winMax.Position = UDim2.new(0, 30, 0, 0)
    winMax.BackgroundTransparency = 1
    winMax.Text = "▢"
    winMax.TextSize = 10
    winMax.TextColor3 = Theme.TextPrimary
    winMax.Parent = winControls

    local winClose = Instance.new("TextButton")
    winClose.Size = UDim2.new(0, 35, 1, 0)
    winClose.Position = UDim2.new(0, 60, 0, 0)
    winClose.BackgroundTransparency = 1
    winClose.Text = "✕"
    winClose.TextSize = 11
    winClose.TextColor3 = Theme.TextPrimary
    winClose.Parent = winControls

    -- 2. SIDEBAR NAVIGATION
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -GROUPY_BAR_H)
    sidebar.Position = UDim2.new(0, 0, 0, GROUPY_BAR_H)
    sidebar.BackgroundColor3 = Theme.SidebarBG
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 28, 0, 28)
    backBtn.Position = UDim2.new(0, 16, 0, 12)
    backBtn.BackgroundTransparency = 1
    backBtn.Text = "←"
    backBtn.TextSize = 18
    backBtn.TextColor3 = Theme.TextPrimary
    backBtn.Font = Enum.Font.GothamMedium
    backBtn.Parent = sidebar

    local navScroll = Instance.new("ScrollingFrame")
    navScroll.Size = UDim2.new(1, 0, 1, -50)
    navScroll.Position = UDim2.new(0, 0, 0, 48)
    navScroll.BackgroundTransparency = 1
    navScroll.BorderSizePixel = 0
    navScroll.ScrollBarThickness = 2
    navScroll.ScrollBarImageColor3 = Theme.CardBorder
    navScroll.Parent = sidebar

    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 4)
    navLayout.Parent = navScroll

    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0, 10)
    navPad.PaddingRight = UDim.new(0, 10)
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
    headerTitle.Position = UDim2.new(0, 15, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = TitleText
    headerTitle.TextSize = 22
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

    -- Dragging System
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

    -- Window API & Tab Logic
    local WindowAPI = { Flags = {} }
    local tabsList = {}

    function WindowAPI.AddTab(tabName, iconSymbol)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 36)
        tabBtn.BackgroundColor3 = Theme.CardBG
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = ""
        tabBtn.Parent = navScroll
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 5)

        local activePill = Instance.new("Frame")
        activePill.Size = UDim2.new(0, 3, 0, 16)
        activePill.Position = UDim2.new(0, 3, 0.5, -8)
        activePill.BackgroundColor3 = Theme.Accent
        activePill.BackgroundTransparency = 1
        activePill.Parent = tabBtn
        Instance.new("UICorner", activePill).CornerRadius = UDim.new(1, 0)

        local tabIcon = Instance.new("TextLabel")
        tabIcon.Size = UDim2.new(0, 20, 1, 0)
        tabIcon.Position = UDim2.new(0, 12, 0, 0)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Text = iconSymbol or "🗔"
        tabIcon.TextSize = 13
        tabIcon.TextColor3 = Theme.TextSecondary
        tabIcon.Parent = tabBtn

        local tabLbl = Instance.new("TextLabel")
        tabLbl.Size = UDim2.new(1, -40, 1, 0)
        tabLbl.Position = UDim2.new(0, 36, 0, 0)
        tabLbl.BackgroundTransparency = 1
        tabLbl.Text = tabName
        tabLbl.TextSize = 12
        tabLbl.TextColor3 = Theme.TextSecondary
        tabLbl.Font = Enum.Font.GothamMedium
        tabLbl.TextXAlignment = Enum.TextXAlignment.Left
        tabLbl.Parent = tabBtn

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Size = UDim2.new(1, 0, 1, 0)
        pageScroll.BackgroundTransparency = 1
        pageScroll.BorderSizePixel = 0
        pageScroll.ScrollBarThickness = 4
        pageScroll.ScrollBarImageColor3 = Theme.CardBorder
        pageScroll.Visible = false
        pageScroll.Parent = pagesContainer

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 16)
        pageLayout.Parent = pageScroll

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingLeft = UDim.new(0, 15)
        pagePad.PaddingRight = UDim.new(0, 20)
        pagePad.PaddingTop = UDim.new(0, 2)
        pagePad.PaddingBottom = UDim.new(0, 24)
        pagePad.Parent = pageScroll

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 30)
        end)

        local TabAPI = {}

        local function activate()
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
            tw(tabBtn, {BackgroundTransparency = 0.6, BackgroundColor3 = Theme.CardBG}, 0.15)
        end

        tabBtn.MouseButton1Click:Connect(activate)
        table.insert(tabsList, { Btn = tabBtn, Pill = activePill, Label = tabLbl, Icon = tabIcon, Page = pageScroll })

        if #tabsList == 1 then activate() end

        -- 1. ADD GRID SELECTOR (การ์ดเลือกสไตล์ Windows 11 ตามรูป)
        function TabAPI:AddGridSelect(titleText, optionsList, defaultIdx, columns, callback)
            columns = columns or 2
            local sectionWrap = Instance.new("Frame")
            sectionWrap.Size = UDim2.new(1, 0, 0, 0)
            sectionWrap.AutomaticSize = Enum.AutomaticSize.Y
            sectionWrap.BackgroundTransparency = 1
            sectionWrap.Parent = pageScroll

            local sTitle = Instance.new("TextLabel")
            sTitle.Size = UDim2.new(1, 0, 0, 20)
            sTitle.BackgroundTransparency = 1
            sTitle.Text = titleText
            sTitle.TextSize = 13
            sTitle.TextColor3 = Theme.TextPrimary
            sTitle.Font = Enum.Font.GothamMedium
            sTitle.TextXAlignment = Enum.TextXAlignment.Left
            sTitle.Parent = sectionWrap

            local gridContainer = Instance.new("Frame")
            gridContainer.Size = UDim2.new(1, 0, 0, 0)
            gridContainer.Position = UDim2.new(0, 0, 0, 26)
            gridContainer.AutomaticSize = Enum.AutomaticSize.Y
            gridContainer.BackgroundTransparency = 1
            gridContainer.Parent = sectionWrap

            local cellW = (columns == 4) and 152 or 318
            local cellH = (columns == 4) and 135 or 125

            local gridLayout = Instance.new("UIGridLayout")
            gridLayout.CellSize = UDim2.new(0, cellW, 0, cellH)
            gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
            gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
            gridLayout.Parent = gridContainer

            local selectedIndex = defaultIdx or 1
            local createdCards = {}

            for idx, opt in ipairs(optionsList) do
                local cardBtn = Instance.new("TextButton")
                cardBtn.Name = opt.Title or "Option"
                cardBtn.BackgroundColor3 = Theme.CardBG
                cardBtn.Text = ""
                cardBtn.AutoButtonColor = false
                cardBtn.Parent = gridContainer
                Instance.new("UICorner", cardBtn).CornerRadius = UDim.new(0, 6)

                local cStroke = Instance.new("UIStroke")
                cStroke.Color = (idx == selectedIndex) and Theme.Accent or Theme.CardBorder
                cStroke.Thickness = (idx == selectedIndex) and 2 or 1
                cStroke.Parent = cardBtn

                -- Mockup Preview Graphics
                if columns == 2 then
                    local graphicBox = Instance.new("Frame")
                    graphicBox.Size = UDim2.new(0, 130, 0, 75)
                    graphicBox.Position = UDim2.new(0, 12, 0, 12)
                    graphicBox.BackgroundColor3 = Theme.MockupBG
                    graphicBox.BorderSizePixel = 0
                    graphicBox.Parent = cardBtn
                    Instance.new("UICorner", graphicBox).CornerRadius = UDim.new(0, 4)

                    local mockBar = Instance.new("Frame")
                    mockBar.Size = UDim2.new(1, -12, 0, 16)
                    mockBar.Position = UDim2.new(0, 6, 0, 12)
                    mockBar.BackgroundColor3 = Theme.MockupInner
                    mockBar.BorderSizePixel = 0
                    mockBar.Parent = graphicBox
                    Instance.new("UICorner", mockBar).CornerRadius = UDim.new(0, 3)

                    local mockTab = Instance.new("Frame")
                    mockTab.Size = UDim2.new(0, 32, 0, 12)
                    mockTab.Position = UDim2.new(0, 4, 0, 2)
                    mockTab.BackgroundColor3 = Theme.Accent
                    mockTab.BorderSizePixel = 0
                    mockTab.Parent = mockBar
                    Instance.new("UICorner", mockTab).CornerRadius = UDim.new(0, opt.Rounded and 3 or 1)

                    local tLbl = Instance.new("TextLabel")
                    tLbl.Size = UDim2.new(1, -160, 0, 18)
                    tLbl.Position = UDim2.new(0, 152, 0, 12)
                    tLbl.BackgroundTransparency = 1
                    tLbl.Text = opt.Title or "Title"
                    tLbl.TextSize = 13
                    tLbl.TextColor3 = Theme.TextPrimary
                    tLbl.Font = Enum.Font.GothamBold
                    tLbl.TextXAlignment = Enum.TextXAlignment.Left
                    tLbl.Parent = cardBtn

                    local dLbl = Instance.new("TextLabel")
                    dLbl.Size = UDim2.new(1, -160, 0, 50)
                    dLbl.Position = UDim2.new(0, 152, 0, 32)
                    dLbl.BackgroundTransparency = 1
                    dLbl.Text = opt.Description or ""
                    dLbl.TextSize = 10
                    dLbl.TextColor3 = Theme.TextSecondary
                    dLbl.Font = Enum.Font.Gotham
                    dLbl.TextXAlignment = Enum.TextXAlignment.Left
                    dLbl.TextYAlignment = Enum.TextYAlignment.Top
                    dLbl.TextWrapped = true
                    dLbl.Parent = cardBtn
                else
                    -- Columns == 4 (Vertical Graphic Style)
                    local graphicBox = Instance.new("Frame")
                    graphicBox.Size = UDim2.new(1, -16, 0, 65)
                    graphicBox.Position = UDim2.new(0, 8, 0, 8)
                    graphicBox.BackgroundColor3 = Theme.MockupBG
                    graphicBox.BorderSizePixel = 0
                    graphicBox.Parent = cardBtn
                    Instance.new("UICorner", graphicBox).CornerRadius = UDim.new(0, 4)

                    local mockBar = Instance.new("Frame")
                    mockBar.Size = UDim2.new(1, -10, 0, 14)
                    mockBar.Position = UDim2.new(0, 5, 0, 8)
                    mockBar.BackgroundColor3 = Theme.MockupInner
                    mockBar.BorderSizePixel = 0
                    mockBar.Parent = graphicBox
                    Instance.new("UICorner", mockBar).CornerRadius = UDim.new(0, 3)

                    local mockTab = Instance.new("Frame")
                    mockTab.Size = UDim2.new(0, 28, 0, 10)
                    mockTab.Position = UDim2.new(0, 4, 0, 2)
                    mockTab.BackgroundColor3 = Theme.Accent
                    mockTab.BorderSizePixel = 0
                    mockTab.Parent = mockBar
                    Instance.new("UICorner", mockTab).CornerRadius = UDim.new(0, 2)

                    local tLbl = Instance.new("TextLabel")
                    tLbl.Size = UDim2.new(1, -16, 0, 16)
                    tLbl.Position = UDim2.new(0, 8, 0, 78)
                    tLbl.BackgroundTransparency = 1
                    tLbl.Text = opt.Title or "Title"
                    tLbl.TextSize = 11
                    tLbl.TextColor3 = Theme.TextPrimary
                    tLbl.Font = Enum.Font.GothamBold
                    tLbl.TextXAlignment = Enum.TextXAlignment.Left
                    tLbl.Parent = cardBtn

                    local dLbl = Instance.new("TextLabel")
                    dLbl.Size = UDim2.new(1, -16, 0, 32)
                    dLbl.Position = UDim2.new(0, 8, 0, 96)
                    dLbl.BackgroundTransparency = 1
                    dLbl.Text = opt.Description or ""
                    dLbl.TextSize = 9
                    dLbl.TextColor3 = Theme.TextSecondary
                    dLbl.Font = Enum.Font.Gotham
                    dLbl.TextXAlignment = Enum.TextXAlignment.Left
                    dLbl.TextYAlignment = Enum.TextYAlignment.Top
                    dLbl.TextWrapped = true
                    dLbl.Parent = cardBtn
                end

                local checkMark = Instance.new("TextLabel")
                checkMark.Size = UDim2.new(0, 14, 0, 14)
                checkMark.Position = UDim2.new(1, -18, 1, -18)
                checkMark.BackgroundTransparency = 1
                checkMark.Text = "✓"
                checkMark.TextSize = 12
                checkMark.TextColor3 = Theme.TextPrimary
                checkMark.Font = Enum.Font.GothamBold
                checkMark.Visible = (idx == selectedIndex)
                checkMark.Parent = cardBtn

                table.insert(createdCards, { Card = cardBtn, Stroke = cStroke, Check = checkMark })

                cardBtn.MouseButton1Click:Connect(function()
                    selectedIndex = idx
                    for i, c in ipairs(createdCards) do
                        c.Stroke.Color = (i == selectedIndex) and Theme.Accent or Theme.CardBorder
                        c.Stroke.Thickness = (i == selectedIndex) and 2 or 1
                        c.Check.Visible = (i == selectedIndex)
                    end
                    if callback then pcall(callback, opt, idx) end
                end)
            end
        end

        -- 2. ADD ROW GROUP CONTAINER (การ์ดผืนยาวสำหรับปุ่ม Toggle ตามรูป)
        function TabAPI:AddGroupContainer(togglesData)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, #togglesData * 54)
            container.BackgroundColor3 = Theme.CardBG
            container.Parent = pageScroll
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

            local cStroke = Instance.new("UIStroke")
            cStroke.Color = Theme.CardBorder
            cStroke.Thickness = 1
            cStroke.Parent = container

            for idx, item in ipairs(togglesData) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 54)
                row.Position = UDim2.new(0, 0, 0, (idx - 1) * 54)
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

                local pBox = Instance.new("Frame")
                pBox.Size = UDim2.new(0, 75, 0, 36)
                pBox.Position = UDim2.new(0, 12, 0.5, -18)
                pBox.BackgroundColor3 = Theme.MockupBG
                pBox.BorderSizePixel = 0
                pBox.Parent = row
                Instance.new("UICorner", pBox).CornerRadius = UDim.new(0, 4)

                local pBar = Instance.new("Frame")
                pBar.Size = UDim2.new(1, -10, 0, 14)
                pBar.Position = UDim2.new(0, 5, 0, 6)
                pBar.BackgroundColor3 = Theme.Accent
                pBar.BorderSizePixel = 0
                pBar.Parent = pBox
                Instance.new("UICorner", pBar).CornerRadius = UDim.new(0, 2)

                local tLbl = Instance.new("TextLabel")
                tLbl.Size = UDim2.new(1, -210, 0, 16)
                tLbl.Position = UDim2.new(0, 102, 0, item.Description and 8 or 19)
                tLbl.BackgroundTransparency = 1
                tLbl.Text = item.Title or "Title"
                tLbl.TextSize = 12
                tLbl.TextColor3 = Theme.TextPrimary
                tLbl.Font = Enum.Font.GothamMedium
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.Parent = row

                if item.Description and item.Description ~= "" then
                    local dLbl = Instance.new("TextLabel")
                    dLbl.Size = UDim2.new(1, -210, 0, 22)
                    dLbl.Position = UDim2.new(0, 102, 0, 25)
                    dLbl.BackgroundTransparency = 1
                    dLbl.Text = item.Description
                    dLbl.TextSize = 10
                    dLbl.TextColor3 = Theme.TextSecondary
                    dLbl.Font = Enum.Font.Gotham
                    dLbl.TextXAlignment = Enum.TextXAlignment.Left
                    dLbl.TextWrapped = true
                    dLbl.Parent = row
                end

                local stateText = Instance.new("TextLabel")
                stateText.Size = UDim2.new(0, 25, 0, 20)
                stateText.Position = UDim2.new(1, -85, 0.5, -10)
                stateText.BackgroundTransparency = 1
                stateText.Text = item.Default and "On" or "Off"
                stateText.TextSize = 12
                stateText.TextColor3 = Theme.TextPrimary
                stateText.Font = Enum.Font.Gotham
                stateText.TextXAlignment = Enum.TextXAlignment.Right
                stateText.Parent = row

                local state = item.Default or false
                local switch = Instance.new("Frame")
                switch.Size = UDim2.new(0, 40, 0, 20)
                switch.Position = UDim2.new(1, -52, 0.5, -10)
                switch.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(210, 210, 215)
                switch.Parent = row
                Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 14, 0, 14)
                knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
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
                    tw(switch, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(210, 210, 215)}, 0.15)
                    tw(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.15)
                    if item.Callback then pcall(item.Callback, state) end
                end)
            end
        end

        return TabAPI
    end

    return WindowAPI
end

return Solar
