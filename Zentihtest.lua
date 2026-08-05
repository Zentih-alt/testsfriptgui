--[[
================================================================================
  SolarV2.lua — Windows 11 Fluent UI Library for Roblox Executors
  Design inspired by Windows 11 / WinUI 3 Modern Desktop Application
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
            TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quint, easingDir or Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

local Themes = {
    ["Win11Dark"] = {
        BG = Color3.fromRGB(32, 32, 36),
        Sidebar = Color3.fromRGB(26, 26, 29),
        Card = Color3.fromRGB(42, 42, 48),
        CardHover = Color3.fromRGB(50, 50, 58),
        Border = Color3.fromRGB(60, 60, 70),
        Text = Color3.fromRGB(245, 245, 250),
        SubText = Color3.fromRGB(160, 160, 175),
        Accent = Color3.fromRGB(0, 120, 212), -- Windows 11 Accent Blue
        AccentHover = Color3.fromRGB(24, 138, 226),
        ToggleOff = Color3.fromRGB(70, 70, 82),
        DotRed = Color3.fromRGB(232, 17, 35),
        DotGreen = Color3.fromRGB(16, 124, 65)
    },
    ["Win11Light"] = {
        BG = Color3.fromRGB(243, 243, 243),
        Sidebar = Color3.fromRGB(230, 230, 235),
        Card = Color3.fromRGB(255, 255, 255),
        CardHover = Color3.fromRGB(245, 245, 250),
        Border = Color3.fromRGB(215, 215, 225),
        Text = Color3.fromRGB(30, 30, 35),
        SubText = Color3.fromRGB(100, 100, 115),
        Accent = Color3.fromRGB(0, 120, 212),
        AccentHover = Color3.fromRGB(24, 138, 226),
        ToggleOff = Color3.fromRGB(200, 200, 210),
        DotRed = Color3.fromRGB(232, 17, 35),
        DotGreen = Color3.fromRGB(16, 124, 65)
    }
}

local Solar = {}
Solar.Themes = Themes

function Solar.CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "Windows 11 Settings"
    local SubText = config.Subtitle or "Solar UI Library V2"
    local CurrentTheme = Themes[config.Theme] or Themes["Win11Dark"]
    local ToggleIcon = config.ToggleIcon or "rbxassetid://10723415903"

    -- Clean old GUI
    local oldUI = CoreGui:FindFirstChild("SolarV2_Engine") or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SolarV2_Engine")
    if oldUI then oldUI:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "SolarV2_Engine"
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

    local WIN_W, WIN_H = 820, 560
    local SIDEBAR_W = 200
    local TOPBAR_H = 48

    local uiVisible = true
    local activeDropdownClose = nil

    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = CurrentTheme.BG
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    main.Active = true
    main.Parent = sg

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = main

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = CurrentTheme.Border
    mainStroke.Thickness = 1
    mainStroke.Parent = main

    -- Responsive UI Scale
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = main

    local function updateScale()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local scale = math.min((vp.X - 30) / WIN_W, (vp.Y - 30) / WIN_H)
        uiScale.Scale = math.clamp(scale, 0.6, 1.0)
    end
    updateScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
    sidebar.BackgroundColor3 = CurrentTheme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 10)
    sidebarCorner.Parent = sidebar

    local headerWrap = Instance.new("Frame")
    headerWrap.Size = UDim2.new(1, 0, 0, TOPBAR_H + 12)
    headerWrap.BackgroundTransparency = 1
    headerWrap.Parent = sidebar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -24, 0, 20)
    titleLbl.Position = UDim2.new(0, 16, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = TitleText
    titleLbl.TextSize = 15
    titleLbl.TextColor3 = CurrentTheme.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerWrap

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -24, 0, 14)
    subLbl.Position = UDim2.new(0, 16, 0, 32)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = SubText
    subLbl.TextSize = 11
    subLbl.TextColor3 = CurrentTheme.SubText
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.Parent = headerWrap

    local navScroll = Instance.new("ScrollingFrame")
    navScroll.Size = UDim2.new(1, 0, 1, -(TOPBAR_H + 20))
    navScroll.Position = UDim2.new(0, 0, 0, TOPBAR_H + 16)
    navScroll.BackgroundTransparency = 1
    navScroll.BorderSizePixel = 0
    navScroll.ScrollBarThickness = 2
    navScroll.ScrollBarImageColor3 = CurrentTheme.Border
    navScroll.Parent = sidebar

    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 4)
    navLayout.Parent = navScroll

    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0, 10)
    navPad.PaddingRight = UDim.new(0, 10)
    navPad.Parent = navScroll

    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
    contentArea.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    -- Top Window Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
    topBar.BackgroundTransparency = 1
    topBar.Parent = contentArea

    local pageHeader = Instance.new("TextLabel")
    pageHeader.Size = UDim2.new(0.6, 0, 1, 0)
    pageHeader.Position = UDim2.new(0, 20, 0, 0)
    pageHeader.BackgroundTransparency = 1
    pageHeader.Text = "Dashboard"
    pageHeader.TextSize = 18
    pageHeader.TextColor3 = CurrentTheme.Text
    pageHeader.Font = Enum.Font.GothamBold
    pageHeader.TextXAlignment = Enum.TextXAlignment.Left
    pageHeader.Parent = topBar

    -- Window Controls (Min/Close)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 12, 0, 12)
    minBtn.Position = UDim2.new(1, -40, 0, 18)
    minBtn.BackgroundColor3 = Color3.fromRGB(245, 189, 2)
    minBtn.Text = ""
    minBtn.Parent = topBar
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 12, 0, 12)
    closeBtn.Position = UDim2.new(1, -20, 0, 18)
    closeBtn.BackgroundColor3 = CurrentTheme.DotRed
    closeBtn.Text = ""
    closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

    -- Container Frame for Pages
    local pagesContainer = Instance.new("Frame")
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Size = UDim2.new(1, 0, 1, -TOPBAR_H)
    pagesContainer.Position = UDim2.new(0, 0, 0, TOPBAR_H)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.Parent = contentArea

    -- Dragging Logic
    local dragging, dragStart, startPos
    local function enableDrag(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
    end
    enableDrag(topBar)
    enableDrag(sidebar)

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

    -- Floating Toggle Button
    local floatToggle = Instance.new("ImageButton")
    floatToggle.Name = "FloatToggle"
    floatToggle.Size = UDim2.new(0, 50, 0, 50)
    floatToggle.Position = UDim2.new(0, 20, 0.5, -25)
    floatToggle.BackgroundColor3 = CurrentTheme.Sidebar
    floatToggle.Image = ToggleIcon
    floatToggle.ZIndex = 999
    floatToggle.Parent = sg
    Instance.new("UICorner", floatToggle).CornerRadius = UDim.new(0, 12)
    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = CurrentTheme.Border
    floatStroke.Parent = floatToggle

    local function toggleUI()
        uiVisible = not uiVisible
        if activeDropdownClose then activeDropdownClose() activeDropdownClose = nil end
        if uiVisible then
            main.Visible = true
            tw(main, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.25)
        else
            tw(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            task.delay(0.2, function() main.Visible = false end)
        end
    end

    minBtn.MouseButton1Click:Connect(toggleUI)
    closeBtn.MouseButton1Click:Connect(toggleUI)
    floatToggle.MouseButton1Click:Connect(toggleUI)

    -- Window API & Tabs Setup
    local WindowAPI = { Flags = {} }
    local tabsList = {}
    local currentTab = nil

    function WindowAPI.AddTab(tabName, iconId)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 36)
        tabBtn.BackgroundColor3 = CurrentTheme.Sidebar
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = ""
        tabBtn.Parent = navScroll
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

        local pillIndicator = Instance.new("Frame")
        pillIndicator.Size = UDim2.new(0, 3, 0, 18)
        pillIndicator.Position = UDim2.new(0, 2, 0.5, -9)
        pillIndicator.BackgroundColor3 = CurrentTheme.Accent
        pillIndicator.BackgroundTransparency = 1
        pillIndicator.Parent = tabBtn
        Instance.new("UICorner", pillIndicator).CornerRadius = UDim.new(1, 0)

        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -30, 1, 0)
        tabLabel.Position = UDim2.new(0, 26, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextSize = 13
        tabLabel.TextColor3 = CurrentTheme.SubText
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabBtn

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Size = UDim2.new(1, 0, 1, 0)
        pageScroll.BackgroundTransparency = 1
        pageScroll.BorderSizePixel = 0
        pageScroll.ScrollBarThickness = 3
        pageScroll.ScrollBarImageColor3 = CurrentTheme.Border
        pageScroll.Visible = false
        pageScroll.Parent = pagesContainer

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 10)
        pageLayout.Parent = pageScroll

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingLeft = UDim.new(0, 20)
        pagePad.PaddingRight = UDim.new(0, 20)
        pagePad.PaddingTop = UDim.new(0, 10)
        pagePad.PaddingBottom = UDim.new(0, 20)
        pagePad.Parent = pageScroll

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 30)
        end)

        local TabAPI = {}

        local function activateTab()
            if activeDropdownClose then activeDropdownClose() activeDropdownClose = nil end
            for _, t in ipairs(tabsList) do
                t.Page.Visible = false
                tw(t.Pill, {BackgroundTransparency = 1}, 0.15)
                tw(t.Label, {TextColor3 = CurrentTheme.SubText}, 0.15)
                tw(t.Btn, {BackgroundTransparency = 1}, 0.15)
            end
            pageScroll.Visible = true
            pageHeader.Text = tabName
            tw(pillIndicator, {BackgroundTransparency = 0}, 0.15)
            tw(tabLabel, {TextColor3 = CurrentTheme.Text}, 0.15)
            tw(tabBtn, {BackgroundTransparency = 0.8, BackgroundColor3 = CurrentTheme.Card}, 0.15)
            currentTab = TabAPI
        end

        tabBtn.MouseButton1Click:Connect(activateTab)

        table.insert(tabsList, { Btn = tabBtn, Pill = pillIndicator, Label = tabLabel, Page = pageScroll })
        if #tabsList == 1 then activateTab() end

        -- Helper to create Win11 Standard Cards
        local function createCard(height)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, height or 48)
            card.BackgroundColor3 = CurrentTheme.Card
            card.Parent = pageScroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke")
            stroke.Color = CurrentTheme.Border
            stroke.Thickness = 1
            stroke.Parent = card
            return card, stroke
        end

        local function injectText(card, title, desc)
            local tLbl = Instance.new("TextLabel")
            tLbl.Size = UDim2.new(0.6, 0, 0, desc and 18 or 0)
            tLbl.Position = UDim2.new(0, 14, 0.5, desc and -16 or 0)
            if not desc then tLbl.Size = UDim2.new(0.6, 0, 1, 0) tLbl.Position = UDim2.new(0, 14, 0, 0) end
            tLbl.BackgroundTransparency = 1
            tLbl.Text = title
            tLbl.TextSize = 13
            tLbl.TextColor3 = CurrentTheme.Text
            tLbl.Font = Enum.Font.GothamMedium
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.Parent = card

            if desc then
                local dLbl = Instance.new("TextLabel")
                dLbl.Size = UDim2.new(0.6, 0, 0, 14)
                dLbl.Position = UDim2.new(0, 14, 0.5, 2)
                dLbl.BackgroundTransparency = 1
                dLbl.Text = desc
                dLbl.TextSize = 11
                dLbl.TextColor3 = CurrentTheme.SubText
                dLbl.Font = Enum.Font.Gotham
                dLbl.TextXAlignment = Enum.TextXAlignment.Left
                dLbl.Parent = card
            end
        end

        -- SECTION
        function TabAPI:AddSection(text)
            local secLbl = Instance.new("TextLabel")
            secLbl.Size = UDim2.new(1, 0, 0, 24)
            secLbl.BackgroundTransparency = 1
            secLbl.Text = text
            secLbl.TextSize = 12
            secLbl.TextColor3 = CurrentTheme.Accent
            secLbl.Font = Enum.Font.GothamBold
            secLbl.TextXAlignment = Enum.TextXAlignment.Left
            secLbl.Parent = pageScroll
        end

        -- BUTTON
        function TabAPI:AddButton(title, desc, callback)
            local card, stroke = createCard(desc and 52 or 44)
            injectText(card, title, desc)

            local actionBtn = Instance.new("TextButton")
            actionBtn.Size = UDim2.new(0, 90, 0, 28)
            actionBtn.Position = UDim2.new(1, -104, 0.5, -14)
            actionBtn.BackgroundColor3 = CurrentTheme.Accent
            actionBtn.Text = "Execute"
            actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            actionBtn.Font = Enum.Font.GothamMedium
            actionBtn.TextSize = 12
            actionBtn.Parent = card
            Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 4)

            actionBtn.MouseButton1Click:Connect(function()
                tw(actionBtn, {BackgroundColor3 = CurrentTheme.AccentHover}, 0.1)
                task.delay(0.1, function() tw(actionBtn, {BackgroundColor3 = CurrentTheme.Accent}, 0.1) end)
                if callback then pcall(callback) end
            end)
        end

        -- TOGGLE
        function TabAPI:AddToggle(title, desc, default, callback, flag)
            local card = createCard(desc and 52 or 44)
            injectText(card, title, desc)
            local state = default or false

            local switch = Instance.new("Frame")
            switch.Size = UDim2.new(0, 40, 0, 20)
            switch.Position = UDim2.new(1, -54, 0.5, -10)
            switch.BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.ToggleOff
            switch.Parent = card
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
            clickBtn.Parent = card

            local function updateToggle()
                tw(switch, {BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.ToggleOff}, 0.15)
                tw(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.15)
            end

            clickBtn.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
                if callback then pcall(callback, state) end
            end)

            local obj = {
                Set = function(_, val) state = val updateToggle() if callback then callback(state) end end,
                Get = function() return state end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        -- SLIDER
        function TabAPI:AddSlider(title, min, max, default, callback, flag)
            min, max = min or 0, max or 100
            local val = math.clamp(default or min, min, max)
            local card = createCard(54)
            injectText(card, title)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 50, 0, 20)
            valLbl.Position = UDim2.new(1, -64, 0, 6)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(val)
            valLbl.TextColor3 = CurrentTheme.Accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 12
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = card

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -28, 0, 4)
            track.Position = UDim2.new(0, 14, 1, -12)
            track.BackgroundColor3 = CurrentTheme.Border
            track.Parent = card
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((val - min)/(max - min), 0, 1, 0)
            fill.BackgroundColor3 = CurrentTheme.Accent
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
                    isDragging = true
                    updateSlider(input)
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

        -- WIN11 GRID CARD SELECTOR (ไฮไลต์หลักตามดีไซน์ต้นแบบ)
        function TabAPI:AddGridSelect(title, options, defaultIndex, callback)
            local headerLbl = Instance.new("TextLabel")
            headerLbl.Size = UDim2.new(1, 0, 0, 20)
            headerLbl.BackgroundTransparency = 1
            headerLbl.Text = title
            headerLbl.TextSize = 13
            headerLbl.TextColor3 = CurrentTheme.Text
            headerLbl.Font = Enum.Font.GothamMedium
            headerLbl.TextXAlignment = Enum.TextXAlignment.Left
            headerLbl.Parent = pageScroll

            local gridFrame = Instance.new("Frame")
            gridFrame.Size = UDim2.new(1, 0, 0, 120)
            gridFrame.BackgroundTransparency = 1
            gridFrame.Parent = pageScroll

            local gridLayout = Instance.new("UIGridLayout")
            gridLayout.CellSize = UDim2.new(0, 175, 0, 110)
            gridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
            gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
            gridLayout.Parent = gridFrame

            local selectedIdx = defaultIndex or 1
            local cardBtns = {}

            for i, opt in ipairs(options) do
                local cCard = Instance.new("TextButton")
                cCard.Name = opt.Title or "Option"
                cCard.BackgroundColor3 = CurrentTheme.Card
                cCard.Text = ""
                cCard.Parent = gridFrame
                Instance.new("UICorner", cCard).CornerRadius = UDim.new(0, 6)

                local stroke = Instance.new("UIStroke")
                stroke.Color = (i == selectedIdx) and CurrentTheme.Accent or CurrentTheme.Border
                stroke.Thickness = (i == selectedIdx) and 2 or 1
                stroke.Parent = cCard

                -- Preview Box Inside Grid Item
                local prevBox = Instance.new("Frame")
                prevBox.Size = UDim2.new(1, -16, 0, 48)
                prevBox.Position = UDim2.new(0, 8, 0, 8)
                prevBox.BackgroundColor3 = CurrentTheme.BG
                prevBox.Parent = cCard
                Instance.new("UICorner", prevBox).CornerRadius = UDim.new(0, 4)

                if opt.Image then
                    local img = Instance.new("ImageLabel")
                    img.Size = UDim2.new(1, 0, 1, 0)
                    img.BackgroundTransparency = 1
                    img.Image = opt.Image
                    img.Parent = prevBox
                    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 4)
                end

                local cTitle = Instance.new("TextLabel")
                cTitle.Size = UDim2.new(1, -16, 0, 16)
                cTitle.Position = UDim2.new(0, 8, 0, 60)
                cTitle.BackgroundTransparency = 1
                cTitle.Text = opt.Title or "Tab Style"
                cTitle.TextSize = 12
                cTitle.TextColor3 = CurrentTheme.Text
                cTitle.Font = Enum.Font.GothamBold
                cTitle.TextXAlignment = Enum.TextXAlignment.Left
                cTitle.Parent = cCard

                local cDesc = Instance.new("TextLabel")
                cDesc.Size = UDim2.new(1, -16, 0, 24)
                cDesc.Position = UDim2.new(0, 8, 0, 78)
                cDesc.BackgroundTransparency = 1
                cDesc.Text = opt.Description or "Description text..."
                cDesc.TextSize = 10
                cDesc.TextColor3 = CurrentTheme.SubText
                cDesc.Font = Enum.Font.Gotham
                cDesc.TextWrapped = true
                cDesc.TextXAlignment = Enum.TextXAlignment.Left
                cDesc.Parent = cCard

                local checkIcon = Instance.new("TextLabel")
                checkIcon.Size = UDim2.new(0, 16, 0, 16)
                checkIcon.Position = UDim2.new(1, -20, 1, -20)
                checkIcon.BackgroundTransparency = 1
                checkIcon.Text = "✓"
                checkIcon.TextColor3 = CurrentTheme.Accent
                checkIcon.Font = Enum.Font.GothamBold
                checkIcon.TextSize = 12
                checkIcon.Visible = (i == selectedIdx)
                checkIcon.Parent = cCard

                table.insert(cardBtns, { Card = cCard, Stroke = stroke, Check = checkIcon })

                cCard.MouseButton1Click:Connect(function()
                    selectedIdx = i
                    for idx, item in ipairs(cardBtns) do
                        item.Stroke.Color = (idx == selectedIdx) and CurrentTheme.Accent or CurrentTheme.Border
                        item.Stroke.Thickness = (idx == selectedIdx) and 2 or 1
                        item.Check.Visible = (idx == selectedIdx)
                    end
                    if callback then pcall(callback, opt, i) end
                end)
            end
        end

        -- DROPDOWN
        function TabAPI:AddDropdown(title, desc, options, default, callback, flag)
            local card = createCard(desc and 52 or 44)
            injectText(card, title, desc)
            local selected = default or options[1] or "Select"
            local open = false

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0, 130, 0, 28)
            box.Position = UDim2.new(1, -144, 0.5, -14)
            box.BackgroundColor3 = CurrentTheme.BG
            box.Text = tostring(selected) .. "  ▼"
            box.TextColor3 = CurrentTheme.Text
            box.Font = Enum.Font.Gotham
            box.TextSize = 11
            box.Parent = card
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
            local boxStroke = Instance.new("UIStroke")
            boxStroke.Color = CurrentTheme.Border
            boxStroke.Parent = box

            local dropList = Instance.new("Frame")
            dropList.Size = UDim2.new(0, 130, 0, math.min(#options, 5) * 28 + 6)
            dropList.BackgroundColor3 = CurrentTheme.Card
            dropList.Visible = false
            dropList.ZIndex = 500
            dropList.Parent = sg
            Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", dropList).Color = CurrentTheme.Border

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
                optBtn.TextColor3 = CurrentTheme.Text
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
                    local abs = box.AbsolutePosition
                    dropList.Position = UDim2.new(0, abs.X, 0, abs.Y + 32)
                    dropList.Visible = true
                    activeDropdownClose = function() dropList.Visible = false open = false end
                else
                    dropList.Visible = false
                end
            end)
        end

        return TabAPI
    end

    return WindowAPI
end

return Solar
