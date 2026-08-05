--[[
================================================================================
  SolarV2.lua — Zentih Custom UI Library (Fixed Dropdown Engine)
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
    CardHover = Color3.fromRGB(250, 250, 254),
    TextPrimary = Color3.fromRGB(25, 25, 30),
    TextSecondary = Color3.fromRGB(115, 115, 125),
    Accent = Color3.fromRGB(0, 95, 184),
    AccentHover = Color3.fromRGB(24, 115, 204),
    DropdownHover = Color3.fromRGB(238, 244, 255),
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

    local WIN_W, WIN_H = 760, 520
    local SIDEBAR_W = 160
    local GROUPY_BAR_H = 36
    local TOPBAR_H = 42

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

    -- 1. TOP HEADER BAR
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

    -- Top-Left Logo Icon
    local logoIcon = Instance.new("Frame")
    logoIcon.Size = UDim2.new(0, 26, 0, 26)
    logoIcon.Position = UDim2.new(0, 6, 0, 5)
    logoIcon.BackgroundColor3 = Theme.Accent
    logoIcon.Parent = groupyBar
    Instance.new("UICorner", logoIcon).CornerRadius = UDim.new(0, 6)

    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "⚡"
    logoText.TextSize = 13
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.Font = Enum.Font.GothamBold
    logoText.Parent = logoIcon

    -- Home Button
    local homeBtn = Instance.new("TextButton")
    homeBtn.Size = UDim2.new(0, 72, 0, 26)
    homeBtn.Position = UDim2.new(0, 38, 0, 5)
    homeBtn.BackgroundColor3 = Theme.GroupyTabActive
    homeBtn.Text = "🏠 Home"
    homeBtn.TextSize = 11
    homeBtn.TextColor3 = Theme.TextPrimary
    homeBtn.Font = Enum.Font.GothamMedium
    homeBtn.Parent = groupyBar
    Instance.new("UICorner", homeBtn).CornerRadius = UDim.new(0, 5)

    -- Top Tabs Container
    local topTabsScroll = Instance.new("ScrollingFrame")
    topTabsScroll.Size = UDim2.new(1, -180, 1, 0)
    topTabsScroll.Position = UDim2.new(0, 116, 0, 0)
    topTabsScroll.BackgroundTransparency = 1
    topTabsScroll.BorderSizePixel = 0
    topTabsScroll.ScrollBarThickness = 0
    topTabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    topTabsScroll.Parent = groupyBar

    local topTabsLayout = Instance.new("UIListLayout")
    topTabsLayout.FillDirection = Enum.FillDirection.Horizontal
    topTabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    topTabsLayout.Padding = UDim.new(0, 5)
    topTabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    topTabsLayout.Parent = topTabsScroll

    topTabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        topTabsScroll.CanvasSize = UDim2.new(0, topTabsLayout.AbsoluteContentSize.X + 10, 0, 0)
    end)

    -- Window Controls (- ✕)
    local winControls = Instance.new("Frame")
    winControls.Size = UDim2.new(0, 60, 1, 0)
    winControls.Position = UDim2.new(1, -60, 0, 0)
    winControls.BackgroundTransparency = 1
    winControls.Parent = groupyBar

    local winMin = Instance.new("TextButton")
    winMin.Size = UDim2.new(0, 28, 1, 0)
    winMin.Position = UDim2.new(0, 0, 0, 0)
    winMin.BackgroundTransparency = 1
    winMin.Text = "─"
    winMin.TextSize = 11
    winMin.TextColor3 = Theme.TextPrimary
    winMin.Parent = winControls

    local winClose = Instance.new("TextButton")
    winClose.Size = UDim2.new(0, 32, 1, 0)
    winClose.Position = UDim2.new(0, 28, 0, 0)
    winClose.BackgroundTransparency = 1
    winClose.Text = "✕"
    winClose.TextSize = 12
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

    local brandHeader = Instance.new("Frame")
    brandHeader.Size = UDim2.new(1, 0, 0, 38)
    brandHeader.BackgroundTransparency = 1
    brandHeader.Parent = sidebar

    local brandTitle = Instance.new("TextLabel")
    brandTitle.Size = UDim2.new(1, -16, 0, 16)
    brandTitle.Position = UDim2.new(0, 12, 0, 6)
    brandTitle.BackgroundTransparency = 1
    brandTitle.Text = HubTitle
    brandTitle.TextSize = 13
    brandTitle.TextColor3 = Theme.TextPrimary
    brandTitle.Font = Enum.Font.GothamBold
    brandTitle.TextXAlignment = Enum.TextXAlignment.Left
    brandTitle.Parent = brandHeader

    local brandSub = Instance.new("TextLabel")
    brandSub.Size = UDim2.new(1, -16, 0, 12)
    brandSub.Position = UDim2.new(0, 12, 0, 22)
    brandSub.BackgroundTransparency = 1
    brandSub.Text = HubSubtitle
    brandSub.TextSize = 10
    brandSub.TextColor3 = Theme.Accent
    brandSub.Font = Enum.Font.Gotham
    brandSub.TextXAlignment = Enum.TextXAlignment.Left
    brandSub.Parent = brandHeader

    local navScroll = Instance.new("ScrollingFrame")
    navScroll.Size = UDim2.new(1, 0, 1, -40)
    navScroll.Position = UDim2.new(0, 0, 0, 38)
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
    navPad.PaddingLeft = UDim.new(0, 6)
    navPad.PaddingRight = UDim.new(0, 6)
    navPad.Parent = navScroll

    -- 3. CONTENT AREA
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -SIDEBAR_W, 1, -GROUPY_BAR_H)
    contentArea.Position = UDim2.new(0, SIDEBAR_W, 0, GROUPY_BAR_H)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = false
    contentArea.Parent = main

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -24, 0, TOPBAR_H)
    headerTitle.Position = UDim2.new(0, 16, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Dashboard"
    headerTitle.TextSize = 16
    headerTitle.TextColor3 = Theme.TextPrimary
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = contentArea

    local pagesContainer = Instance.new("Frame")
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Size = UDim2.new(1, 0, 1, -TOPBAR_H)
    pagesContainer.Position = UDim2.new(0, 0, 0, TOPBAR_H)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.ClipsDescendants = false
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
            if activeCloseDropdown then activeCloseDropdown() activeCloseDropdown = nil end
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
        tabIcon.Position = UDim2.new(0, 8, 0, 0)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Text = iconSymbol or "📄"
        tabIcon.TextSize = 12
        tabIcon.TextColor3 = Theme.TextSecondary
        tabIcon.Parent = tabBtn

        local tabLbl = Instance.new("TextLabel")
        tabLbl.Size = UDim2.new(1, -30, 1, 0)
        tabLbl.Position = UDim2.new(0, 26, 0, 0)
        tabLbl.BackgroundTransparency = 1
        tabLbl.Text = tabName
        tabLbl.TextSize = 11
        tabLbl.TextColor3 = Theme.TextSecondary
        tabLbl.Font = Enum.Font.GothamMedium
        tabLbl.TextXAlignment = Enum.TextXAlignment.Left
        tabLbl.Parent = tabBtn

        -- Top App Tab Item
        local topTab = Instance.new("Frame")
        topTab.Size = UDim2.new(0, 120, 0, 26)
        topTab.BackgroundColor3 = Theme.GroupyTabInactive
        topTab.Parent = topTabsScroll
        Instance.new("UICorner", topTab).CornerRadius = UDim.new(0, 5)

        local topTabBtn = Instance.new("TextButton")
        topTabBtn.Size = UDim2.new(1, -18, 1, 0)
        topTabBtn.Position = UDim2.new(0, 6, 0, 0)
        topTabBtn.BackgroundTransparency = 1
        topTabBtn.Text = tabName
        topTabBtn.TextSize = 11
        topTabBtn.TextColor3 = Theme.TextSecondary
        topTabBtn.Font = Enum.Font.Gotham
        topTabBtn.TextXAlignment = Enum.TextXAlignment.Left
        topTabBtn.TextTruncate = Enum.TextTruncate.AtEnd
        topTabBtn.Parent = topTab

        local topTabClose = Instance.new("TextButton")
        topTabClose.Size = UDim2.new(0, 14, 0, 14)
        topTabClose.Position = UDim2.new(1, -16, 0.5, -7)
        topTabClose.BackgroundTransparency = 1
        topTabClose.Text = "✕"
        topTabClose.TextSize = 9
        topTabClose.TextColor3 = Theme.TextSecondary
        topTabClose.Parent = topTab

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Size = UDim2.new(1, 0, 1, 0)
        pageScroll.BackgroundTransparency = 1
        pageScroll.BorderSizePixel = 0
        pageScroll.ScrollBarThickness = 3
        pageScroll.ScrollBarImageColor3 = Theme.CardBorder
        pageScroll.ClipsDescendants = false
        pageScroll.Visible = false
        pageScroll.Parent = pagesContainer

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 10)
        pageLayout.Parent = pageScroll

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingLeft = UDim.new(0, 14)
        pagePad.PaddingRight = UDim.new(0, 18)
        pagePad.PaddingTop = UDim.new(0, 2)
        pagePad.PaddingBottom = UDim.new(0, 20)
        pagePad.Parent = pageScroll

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 24)
        end)

        pageScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if activeCloseDropdown then activeCloseDropdown() end
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
                t.TopTab.BackgroundColor3 = Theme.GroupyTabInactive
                t.TopTabBtn.TextColor3 = Theme.TextSecondary
            end
            pageScroll.Visible = true
            headerTitle.Text = tabName
            tw(activePill, {BackgroundTransparency = 0}, 0.15)
            tw(tabLbl, {TextColor3 = Theme.TextPrimary}, 0.15)
            tw(tabIcon, {TextColor3 = Theme.Accent}, 0.15)
            tw(tabBtn, {BackgroundTransparency = 0.7, BackgroundColor3 = Theme.CardBG}, 0.15)
            topTab.BackgroundColor3 = Theme.GroupyTabActive
            topTabBtn.TextColor3 = Theme.TextPrimary
        end

        tabBtn.MouseButton1Click:Connect(activate)
        topTabBtn.MouseButton1Click:Connect(activate)
        topTabClose.MouseButton1Click:Connect(function()
            topTab:Destroy()
            tabBtn:Destroy()
            pageScroll:Destroy()
        end)

        table.insert(tabsList, {
            Btn = tabBtn, Pill = activePill, Label = tabLbl, Icon = tabIcon,
            TopTab = topTab, TopTabBtn = topTabBtn, Page = pageScroll
        })

        if #tabsList == 1 then activate() end
        homeBtn.MouseButton1Click:Connect(function() if tabsList[1] then activate() end end)

        local function createCard(height)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, height or 52)
            card.BackgroundColor3 = Theme.CardBG
            card.ClipsDescendants = false
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
            secLbl.Size = UDim2.new(1, 0, 0, 20)
            secLbl.BackgroundTransparency = 1
            secLbl.Text = text
            secLbl.TextSize = 12
            secLbl.TextColor3 = Theme.Accent
            secLbl.Font = Enum.Font.GothamBold
            secLbl.TextXAlignment = Enum.TextXAlignment.Left
            secLbl.Parent = pageScroll
        end

        -- =========================================================================
        -- DROPDOWN ENGINE (ปรับให้เปิดขยายขึ้นด้านบน ตามวงสีเขียวในรูปภาพ)
        -- =========================================================================
        function TabAPI:AddDropdown(title, desc, options, default, callback, flag)
            local card = createCard(48)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.5, -16, 1, 0)
            tLbl.Position = UDim2.new(0, 14, 0, 0)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 13
            tLbl.TextColor3 = Theme.TextPrimary
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            local selected = default or options[1] or "Select"
            local open = false

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0, 150, 0, 30)
            box.Position = UDim2.new(1, -164, 0.5, -15)
            box.BackgroundColor3 = Theme.MainBG
            box.Text = ""
            box.AutoButtonColor = false
            box.Parent = card
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
            local boxStroke = Instance.new("UIStroke")
            boxStroke.Color = Theme.CardBorder
            boxStroke.Parent = box

            local boxLbl = Instance.new("TextLabel")
            boxLbl.Size = UDim2.new(1, -24, 1, 0)
            boxLbl.Position = UDim2.new(0, 10, 0, 0)
            boxLbl.BackgroundTransparency = 1
            boxLbl.Text = tostring(selected)
            boxLbl.TextColor3 = Theme.TextPrimary
            boxLbl.Font = Enum.Font.GothamMedium
            boxLbl.TextSize = 12
            boxLbl.TextXAlignment = Enum.TextXAlignment.Left
            boxLbl.TextTruncate = Enum.TextTruncate.AtEnd
            boxLbl.Parent = box

            local arrowIcon = Instance.new("TextLabel")
            arrowIcon.Size = UDim2.new(0, 16, 1, 0)
            arrowIcon.Position = UDim2.new(1, -18, 0, 0)
            arrowIcon.BackgroundTransparency = 1
            arrowIcon.Text = "▲"
            arrowIcon.TextColor3 = Theme.TextSecondary
            arrowIcon.TextSize = 9
            arrowIcon.Parent = box

            local listHeight = math.min(#options, 5) * 32 + 8

            -- Dropdown Popup Container
            local dropList = Instance.new("Frame")
            dropList.Name = "DropdownList"
            dropList.Size = UDim2.new(0, 150, 0, listHeight)
            dropList.BackgroundColor3 = Theme.CardBG
            dropList.Visible = false
            dropList.ZIndex = 100000
            dropList.Parent = sg
            Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)
            local listStroke = Instance.new("UIStroke")
            listStroke.Color = Theme.CardBorder
            listStroke.Thickness = 1.2
            listStroke.Parent = dropList

            -- Shadow Effect
            local dropShadow = Instance.new("ImageLabel")
            dropShadow.Size = UDim2.new(1, 20, 1, 20)
            dropShadow.Position = UDim2.new(0, -10, 0, -8)
            dropShadow.BackgroundTransparency = 1
            dropShadow.Image = "rbxassetid://5554236805"
            dropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            dropShadow.ImageTransparency = 0.8
            dropShadow.ScaleType = Enum.ScaleType.Slice
            dropShadow.SliceCenter = Rect.new(23, 23, 277, 277)
            dropShadow.ZIndex = 99999
            dropShadow.Parent = dropList

            local listScroll = Instance.new("ScrollingFrame")
            listScroll.Size = UDim2.new(1, -4, 1, -6)
            listScroll.Position = UDim2.new(0, 2, 0, 3)
            listScroll.BackgroundTransparency = 1
            listScroll.BorderSizePixel = 0
            listScroll.ScrollBarThickness = 2
            listScroll.ScrollBarImageColor3 = Theme.CardBorder
            listScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 32)
            listScroll.ZIndex = 100001
            listScroll.Parent = dropList

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 2)
            listLayout.Parent = listScroll

            local optionBtns = {}

            local function updateListStyle()
                for optVal, btnObj in pairs(optionBtns) do
                    local isSelected = (optVal == selected)
                    if isSelected then
                        btnObj.Btn.BackgroundColor3 = Theme.DropdownHover
                        btnObj.Lbl.TextColor3 = Theme.Accent
                        btnObj.Lbl.Font = Enum.Font.GothamBold
                        btnObj.Check.Visible = true
                    else
                        btnObj.Btn.BackgroundColor3 = Theme.CardBG
                        btnObj.Lbl.TextColor3 = Theme.TextPrimary
                        btnObj.Lbl.Font = Enum.Font.Gotham
                        btnObj.Check.Visible = false
                    end
                end
            end

            local function closeList()
                open = false
                tw(arrowIcon, {Rotation = 0}, 0.15)
                tw(boxStroke, {Color = Theme.CardBorder}, 0.15)
                dropList.Visible = false
            end

            for index, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3 = Theme.CardBG
                optBtn.Text = ""
                optBtn.AutoButtonColor = false
                optBtn.ZIndex = 100002
                optBtn.Parent = listScroll
                Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

                local optLbl = Instance.new("TextLabel")
                optLbl.Size = UDim2.new(1, -28, 1, 0)
                optLbl.Position = UDim2.new(0, 8, 0, 0)
                optLbl.BackgroundTransparency = 1
                optLbl.Text = tostring(opt)
                optLbl.TextSize = 11
                optLbl.TextColor3 = Theme.TextPrimary
                optLbl.Font = Enum.Font.Gotham
                optLbl.TextXAlignment = Enum.TextXAlignment.Left
                optLbl.ZIndex = 100003
                optLbl.Parent = optBtn

                local checkIcon = Instance.new("TextLabel")
                checkIcon.Size = UDim2.new(0, 16, 1, 0)
                checkIcon.Position = UDim2.new(1, -20, 0, 0)
                checkIcon.BackgroundTransparency = 1
                checkIcon.Text = "✓"
                checkIcon.TextSize = 11
                checkIcon.TextColor3 = Theme.Accent
                checkIcon.Font = Enum.Font.GothamBold
                checkIcon.Visible = (opt == selected)
                checkIcon.ZIndex = 100003
                checkIcon.Parent = optBtn

                optionBtns[opt] = { Btn = optBtn, Lbl = optLbl, Check = checkIcon }

                optBtn.MouseEnter:Connect(function()
                    if opt ~= selected then
                        tw(optBtn, {BackgroundColor3 = Theme.SidebarBG}, 0.1)
                    end
                end)
                optBtn.MouseLeave:Connect(function()
                    if opt ~= selected then
                        tw(optBtn, {BackgroundColor3 = Theme.CardBG}, 0.1)
                    end
                end)

                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    boxLbl.Text = tostring(selected)
                    updateListStyle()
                    closeList()
                    if callback then pcall(callback, selected) end
                end)
            end

            updateListStyle()

            box.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    if activeCloseDropdown then activeCloseDropdown() end
                    local abs = box.AbsolutePosition
                    -- คำนวณให้รายการเด้งขึ้นด้านบน
                    dropList.Position = UDim2.new(0, abs.X, 0, abs.Y - listHeight - 4)
                    dropList.Visible = true
                    tw(arrowIcon, {Rotation = 180}, 0.15)
                    tw(boxStroke, {Color = Theme.Accent}, 0.15)
                    activeCloseDropdown = closeList
                else
                    closeList()
                end
            end)

            local obj = {
                Get = function() return selected end,
                Set = function(_, v)
                    selected = v
                    boxLbl.Text = tostring(v)
                    updateListStyle()
                end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        -- BUTTON CARD
        function TabAPI:AddButton(title, desc, callback)
            local card = createCard(desc and 54 or 46)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.5, -16, 0, desc and 18 or 0)
            tLbl.Position = UDim2.new(0, 14, 0.5, desc and -16 or 0)
            if not desc then tLbl.Size = UDim2.new(0.5, -16, 1, 0) tLbl.Position = UDim2.new(0, 14, 0, 0) end
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 13
            tLbl.TextColor3 = Theme.TextPrimary
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            if desc then
                local dLbl = Instance.new("TextLabel")
                dLbl.Size = UDim2.new(0.5, -16, 0, 14)
                dLbl.Position = UDim2.new(0, 14, 0.5, 2)
                dLbl.BackgroundTransparency = 1
                dLbl.Text = desc
                dLbl.TextSize = 10
                dLbl.TextColor3 = Theme.TextSecondary
                dLbl.Font = Enum.Font.Gotham
                dLbl.TextXAlignment = Enum.TextXAlignment.Left
                dLbl.Parent = card
            end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 95, 0, 30)
            btn.Position = UDim2.new(1, -109, 0.5, -15)
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

        -- SLIDER CARD
        function TabAPI:AddSlider(title, min, max, default, callback, flag)
            min, max = min or 0, max or 100
            local val = math.clamp(default or min, min, max)
            local card = createCard(50)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.5, -16, 1, 0)
            tLbl.Position = UDim2.new(0, 14, 0, 0)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 13
            tLbl.TextColor3 = Theme.TextPrimary
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 45, 0, 20)
            valLbl.Position = UDim2.new(1, -55, 0, 5)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(val)
            valLbl.TextColor3 = Theme.Accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 12
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = card

            local track = Instance.new("Frame")
            track.Size = UDim2.new(0, 150, 0, 5)
            track.Position = UDim2.new(1, -164, 1, -13)
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

        -- INPUT TEXTBOX
        function TabAPI:AddInput(title, placeholder, callback)
            local card = createCard(46)

            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.5, -16, 1, 0)
            tLbl.Position = UDim2.new(0, 14, 0, 0)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 13
            tLbl.TextColor3 = Theme.TextPrimary
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            local inpWrap = Instance.new("Frame")
            inpWrap.Size = UDim2.new(0, 150, 0, 28)
            inpWrap.Position = UDim2.new(1, -164, 0.5, -14)
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
