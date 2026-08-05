--[[
========================================================
 Solar.lua — Zenith Soul UI Library (740x520 Reverted Version)
========================================================
นี่คือ "ไลบรารี" ไม่ใช่ตัวสคริปฮับที่รันแล้วมี UI ทันที
เอาไปใช้โดยดึงมาก่อน แล้วค่อยเรียก Solar.CreateWindow(...) ในสคริปของตัวเอง (เช่น Main.lua)

วิธีดึงไปใช้ (สำหรับคนอื่นที่หยิบไลบรารีนี้ไปทำฮับของตัวเอง):

    local Solar = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Zentih-alt/Zentih-Soul-hub/refs/heads/main/Solar.lua"
    ))()

    local Window = Solar.CreateWindow({
        Title = "ชื่อฮับของคุณ",
        Subtitle = "ซับไตเติลของคุณ",
        Theme = "Black",              -- ตัวเลือก: "Black" / "White" / "GreenBlack" / "NeonPurple"
        Icon = "rbxassetid://0",      -- (ไม่ใส่ก็ได้ = ไม่โชว์รูป)
    })

    local Tab = Window.AddTab("ชื่อแท็บ", "ชื่อหมวดหมู่")
    Tab:AddButton("กดฉัน", function() print("โดนกด!") end)
========================================================
]]

-- ========================================================
-- SECTION 1: SERVICES & HELPERS
-- ========================================================
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local function tw(obj, props, t, style, dir)
    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

-- เช็คว่า icon id ที่ส่งมา "มีรูปจริง" หรือเปล่า
local function hasIcon(id)
    if not id or id == "" then return false end
    local assetNum = tostring(id):match("rbxassetid://(%d+)")
    if assetNum and tonumber(assetNum) == 0 then return false end
    return true
end

-- ========================================================
-- SECTION 2: THEMES — แก้/เพิ่มสีใหม่ตรงนี้จุดเดียว
-- ========================================================
local Themes = {
    -- สี1: ดำมนๆ ปกติ ตัวหนังสือขาว
    ["Black"] = {
        BG = Color3.fromRGB(22, 22, 24), Sidebar = Color3.fromRGB(16, 16, 18),
        Card = Color3.fromRGB(30, 30, 33), Border = Color3.fromRGB(44, 44, 48),
        Text = Color3.fromRGB(255, 255, 255), Sub = Color3.fromRGB(185, 185, 192),
        Active = Color3.fromRGB(38, 38, 42), Accent = Color3.fromRGB(80, 160, 255),
        DotRed = Color3.fromRGB(255, 95, 87), DotGreen = Color3.fromRGB(40, 200, 64)
    },
    -- สี2: ขาวหมด ตัวหนังสือดำ
    ["White"] = {
        BG = Color3.fromRGB(255, 255, 255), Sidebar = Color3.fromRGB(242, 242, 245),
        Card = Color3.fromRGB(250, 250, 252), Border = Color3.fromRGB(220, 220, 225),
        Text = Color3.fromRGB(20, 20, 22), Sub = Color3.fromRGB(80, 80, 90),
        Active = Color3.fromRGB(230, 230, 235), Accent = Color3.fromRGB(30, 110, 255),
        DotRed = Color3.fromRGB(255, 95, 87), DotGreen = Color3.fromRGB(40, 200, 64)
    },
    -- สี3: เขียวผสมดำมนๆ ตัวหนังสือเขียวอ่อน
    ["GreenBlack"] = {
        BG = Color3.fromRGB(16, 22, 18), Sidebar = Color3.fromRGB(11, 16, 13),
        Card = Color3.fromRGB(22, 30, 24), Border = Color3.fromRGB(34, 48, 38),
        Text = Color3.fromRGB(190, 255, 200), Sub = Color3.fromRGB(150, 205, 160),
        Active = Color3.fromRGB(28, 40, 31), Accent = Color3.fromRGB(120, 255, 150),
        DotRed = Color3.fromRGB(255, 95, 87), DotGreen = Color3.fromRGB(40, 200, 64)
    },
    -- สี4 (คิดเอง): ม่วงเข้มมนๆ ผสมดำ ตัวหนังสือขาว เน้นสีฟ้านีออน
    ["NeonPurple"] = {
        BG = Color3.fromRGB(24, 18, 32), Sidebar = Color3.fromRGB(17, 13, 24),
        Card = Color3.fromRGB(32, 24, 42), Border = Color3.fromRGB(48, 36, 62),
        Text = Color3.fromRGB(255, 255, 255), Sub = Color3.fromRGB(200, 190, 215),
        Active = Color3.fromRGB(40, 30, 52), Accent = Color3.fromRGB(100, 230, 255),
        DotRed = Color3.fromRGB(255, 95, 87), DotGreen = Color3.fromRGB(40, 200, 64)
    }
}

local Library = {}
Library.Themes = Themes

-- ========================================================
-- SECTION 3: Library.CreateWindow
-- ========================================================
function Library.CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "Zenith Soul"
    local SubText = config.Subtitle or "HUB · V8"
    local Th = Themes[config.Theme] or Themes["Black"]
    local BackgroundImage = config.BackgroundImage
    local BackgroundImageTransparency = config.BackgroundImageTransparency or 0.65
    local ProfileIcon = config.Icon
    local ToggleIcon = config.ToggleIcon or "rbxassetid://83564638132604"

    local oldUI = game:GetService("CoreGui"):FindFirstChild("ZenithSoul_Engine") or game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ZenithSoul_Engine")
    if oldUI then oldUI:Destroy() end

    -- ล้าง connection เก่าป้องกันปัญหาการลากหน่วง
    if _G.__ZenithSoul_Conns then
        for _, c in ipairs(_G.__ZenithSoul_Conns) do
            pcall(function() c:Disconnect() end)
        end
    end
    _G.__ZenithSoul_Conns = {}
    local function trackConn(conn)
        table.insert(_G.__ZenithSoul_Conns, conn)
        return conn
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "ZenithSoul_Engine"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- ย้อนกลับมาใช้ขนาดดั้งเดิม 740x520 เพื่อให้พอดีกับจอภาพหลัก
    local WIN_W, WIN_H = 740, 520
    local SIDEBAR_W = 175
    local TOPBAR_H = 48

    local uiVisible = true
    local fullscreen = false
    local savedSize, savedPos
    local openDropdownClose = nil
    local currentActiveTab = nil
    
    -- คงความโปร่งใสในวงสีเขียวไว้ที่ 0.08 (ทึบ 92%) ตามที่คุณระบุ
    local windowTrans = 0.08
    local cardTrans = 0
    local currentThemeName = config.Theme or "Black"
    local main
    local WindowAPI

    -- ========================================================
    -- ระบบเซฟ/โหลดสถานะ GUI
    -- ========================================================
    local GuiStateFolder = "ZenithSoul/configs"
    local GuiStateFile = GuiStateFolder .. "/_gui_state.json"
    local function loadGuiState()
        local ok, data = pcall(function()
            if readfile and isfile and isfile(GuiStateFile) then
                return game:GetService("HttpService"):JSONDecode(readfile(GuiStateFile))
            end
        end)
        if ok and type(data) == "table" then return data end
        return nil
    end
    local function saveGuiState(extra)
        if not (writefile and isfolder and makefolder) then return end
        pcall(function()
            if not isfolder(GuiStateFolder) then makefolder(GuiStateFolder) end
            local data = {
                Theme = currentThemeName,
                WindowTrans = windowTrans,
                CardTrans = cardTrans,
                PosXS = main.Position.X.Scale, PosXO = main.Position.X.Offset,
                PosYS = main.Position.Y.Scale, PosYO = main.Position.Y.Offset,
            }
            if extra then for k, v in pairs(extra) do data[k] = v end end
            writefile(GuiStateFile, game:GetService("HttpService"):JSONEncode(data))
        end)
    end
    local GuiState = loadGuiState()
    if GuiState then
        if GuiState.Theme and Themes[GuiState.Theme] and not config.Theme then
            currentThemeName = GuiState.Theme
        end
        if type(GuiState.WindowTrans) == "number" then windowTrans = GuiState.WindowTrans end
        if type(GuiState.CardTrans) == "number" then cardTrans = GuiState.CardTrans end
    end
    Th = Themes[currentThemeName] or Th

    main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = Th.BG
    main.BackgroundTransparency = 0
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Active = true
    main.Parent = sg
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,8) c.Parent = main end
    local mainStroke = Instance.new("UIStroke") mainStroke.Color = Th.Border mainStroke.Thickness = 1 mainStroke.Parent = main

    -- เงาใต้หน้าต่าง
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "WindowShadow"
    shadow.AnchorPoint = Vector2.new(0.5,0.5)
    shadow.Size = UDim2.new(1,60,1,60)
    shadow.Position = UDim2.new(0.5,0,0.5,8)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.45
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23,23,277,277)
    shadow.ZIndex = -1
    shadow.Parent = main

    -- ระบบปรับสเกลอัตโนมัติย้อนคืนตามสัดส่วนเดิม 740x520
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = main

    local function scaleForWidth(w)
        if w <= 350 then
            return 0.75
        elseif w <= 430 then
            return 0.75 + (w - 350) / (430 - 350) * (0.85 - 0.75)
        elseif w <= 500 then
            return 0.85 + (w - 430) / (500 - 430) * (0.95 - 0.85)
        else
            return 1.0
        end
    end

    local function applyResponsiveScale()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
        if not vp then return end
        local margin = 40
        local fitScale = (vp.X - margin) / WIN_W
        local widthScale = math.min(scaleForWidth(vp.X), fitScale)
        local verticalSafety = math.clamp((vp.Y - margin) / WIN_H, 0.7, 1.5)
        local scale = math.min(widthScale, verticalSafety)
        scale = math.clamp(scale, 0.55, 1.0)
        uiScale.Scale = scale
    end

    applyResponsiveScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveScale)
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        applyResponsiveScale()
        if workspace.CurrentCamera then
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveScale)
        end
    end)

    -- พื้นหลังรูปภาพ
    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "BackgroundArt"
    bgImage.Size = UDim2.new(1,0,1,0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = BackgroundImage or ""
    bgImage.ImageTransparency = BackgroundImageTransparency
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 0
    bgImage.Visible = BackgroundImage ~= nil
    bgImage.Parent = main
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,8) c.Parent = bgImage end

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
    sidebar.BackgroundColor3 = Th.Sidebar
    sidebar.BackgroundTransparency = 0
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    sidebar.Active = true
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,8) c.Parent = sidebar end
    local sidebarSheen = Instance.new("UIGradient")
    sidebarSheen.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180,180,180)),
    })
    sidebarSheen.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 1),
    })
    sidebarSheen.Rotation = 90
    sidebarSheen.Parent = sidebar

    local sbFix = Instance.new("Frame")
    sbFix.Size = UDim2.new(0,10,1,0)
    sbFix.Position = UDim2.new(1,-10,0,0)
    sbFix.BackgroundColor3 = Th.Sidebar
    sbFix.BackgroundTransparency = 0
    sbFix.BorderSizePixel = 0
    sbFix.Parent = sidebar

    local headerWrap = Instance.new("Frame")
    headerWrap.Size = UDim2.new(1,0,0,62)
    headerWrap.BackgroundTransparency = 1
    headerWrap.Parent = sidebar
    headerWrap.Active = true

    local profileIcon = Instance.new("ImageLabel")
    profileIcon.Name = "ProfileIcon"
    profileIcon.Size = UDim2.new(0,34,0,34)
    profileIcon.Position = UDim2.new(0,12,0,14)
    profileIcon.BackgroundColor3 = Th.Active
    profileIcon.Image = hasIcon(ProfileIcon) and ProfileIcon or ""
    profileIcon.Visible = hasIcon(ProfileIcon)
    profileIcon.ScaleType = Enum.ScaleType.Crop
    profileIcon.Parent = headerWrap
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,8) c.Parent = profileIcon end
    local profileStroke = Instance.new("UIStroke") profileStroke.Color = Th.Border profileStroke.Parent = profileIcon

    local titleOffsetX = profileIcon.Visible and 52 or 12

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1,-16-titleOffsetX,0,16)
    titleLbl.Position = UDim2.new(0,titleOffsetX,0,16)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = TitleText
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = Th.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.Parent = headerWrap

    local subTitleLbl = Instance.new("TextLabel")
    subTitleLbl.Size = UDim2.new(1,-16-titleOffsetX,0,12)
    subTitleLbl.Position = UDim2.new(0,titleOffsetX,0,33)
    subTitleLbl.BackgroundTransparency = 1
    subTitleLbl.Text = SubText
    subTitleLbl.TextSize = 11
    subTitleLbl.TextColor3 = Th.Accent
    subTitleLbl.Font = Enum.Font.GothamBold
    subTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    subTitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    subTitleLbl.Parent = headerWrap

    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0,17,0,3)
    accentBar.Position = UDim2.new(0,12,0,50)
    accentBar.BackgroundColor3 = Th.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = headerWrap
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = accentBar end

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1,-16,0,1)
    headerLine.Position = UDim2.new(0,8,0,62)
    headerLine.BackgroundColor3 = Th.Border
    headerLine.BorderSizePixel = 0
    headerLine.Parent = sidebar

    local navScroll = Instance.new("ScrollingFrame")
    navScroll.Size = UDim2.new(1,0,1,-70)
    navScroll.Position = UDim2.new(0,0,0,66)
    navScroll.BackgroundTransparency = 1
    navScroll.BorderSizePixel = 0
    navScroll.ScrollBarThickness = 0
    navScroll.Parent = sidebar

    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0,2)
    navLayout.Parent = navScroll

    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0,8)
    navPad.PaddingRight = UDim.new(0,8)
    navPad.PaddingTop = UDim.new(0,4)
    navPad.Parent = navScroll

    navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        navScroll.CanvasSize = UDim2.new(0,0,0, navLayout.AbsoluteContentSize.Y + 10)
    end)

    local rightSide = Instance.new("Frame")
    rightSide.Size = UDim2.new(1,-SIDEBAR_W,1,0)
    rightSide.Position = UDim2.new(0,SIDEBAR_W,0,0)
    rightSide.BackgroundTransparency = 1
    rightSide.Parent = main

    -- ตั้งค่าค่าความโปร่งใสในวงสีเขียว 0.08 (ทึบ 92% มองทะลุบาง ๆ) ใช้งานอย่างสมดุลร่วมกับขนาด 740
    local contentBG = Instance.new("Frame")
    contentBG.Name = "ContentBG"
    contentBG.Size = UDim2.new(1,0,1,-TOPBAR_H)
    contentBG.Position = UDim2.new(0,0,0,TOPBAR_H)
    contentBG.BackgroundColor3 = Th.BG
    contentBG.BackgroundTransparency = windowTrans
    contentBG.BorderSizePixel = 0
    contentBG.ZIndex = 0
    contentBG.Parent = rightSide

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1,0,0,TOPBAR_H)
    topBar.BackgroundTransparency = 1
    topBar.Parent = rightSide
    topBar.Active = true

    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(0.4,0,0,20)
    pageTitle.Position = UDim2.new(0,12,0,10)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Dashboard"
    pageTitle.TextSize = 16
    pageTitle.TextColor3 = Th.Text
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.Parent = topBar

    local searchWrap = Instance.new("Frame")
    searchWrap.Size = UDim2.new(0, 130, 0, 26)
    searchWrap.AnchorPoint = Vector2.new(1, 0.5)
    searchWrap.Position = UDim2.new(1, -40, 0.5, 0)
    searchWrap.BackgroundColor3 = Th.BG
    searchWrap.BackgroundTransparency = 0
    searchWrap.Parent = topBar
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,6) c.Parent = searchWrap end
    local searchStroke = Instance.new("UIStroke") searchStroke.Color = Th.Border searchStroke.Thickness = 1.2 searchStroke.Parent = searchWrap

    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0,24,1,0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextSize = 11
    searchIcon.TextColor3 = Th.Sub
    searchIcon.Parent = searchWrap

    local searchInput = Instance.new("TextBox")
    searchInput.Size = UDim2.new(1,-28,1,0)
    searchInput.Position = UDim2.new(0,24,0,0)
    searchInput.BackgroundTransparency = 1
    searchInput.Text = ""
    searchInput.PlaceholderText = "Search..."
    searchInput.PlaceholderColor3 = Th.Sub
    searchInput.TextSize = 12
    searchInput.TextColor3 = Th.Text
    searchInput.Font = Enum.Font.Gotham
    searchInput.TextXAlignment = Enum.TextXAlignment.Left
    searchInput.Parent = searchWrap

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0,8,0,8)
    minBtn.AnchorPoint = Vector2.new(1,0.5)
    minBtn.Position = UDim2.new(1,-24,0.5,0)
    minBtn.BackgroundColor3 = Th.DotRed
    minBtn.Text = ""
    minBtn.AutoButtonColor = false
    minBtn.Parent = topBar
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = minBtn end

    local maxBtn = Instance.new("TextButton")
    maxBtn.Size = UDim2.new(0,8,0,8)
    maxBtn.AnchorPoint = Vector2.new(1,0.5)
    maxBtn.Position = UDim2.new(1,-10,0.5,0)
    maxBtn.BackgroundColor3 = Th.DotGreen
    maxBtn.Text = ""
    maxBtn.AutoButtonColor = false
    maxBtn.Parent = topBar
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = maxBtn end

    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1,-20,0,1)
    topLine.Position = UDim2.new(0,10,1,-1)
    topLine.BackgroundColor3 = Th.Border
    topLine.BorderSizePixel = 0
    topLine.Parent = topBar

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1,0,1,-TOPBAR_H)
    contentFrame.Position = UDim2.new(0,0,0,TOPBAR_H)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = rightSide

    local notifyList = Instance.new("Frame")
    notifyList.Name = "Notifications"
    notifyList.AnchorPoint = Vector2.new(1,1)
    notifyList.Size = UDim2.new(0, 240, 0, 300)
    notifyList.Position = UDim2.new(1, -14, 1, -14)
    notifyList.BackgroundTransparency = 1
    notifyList.ZIndex = 9999
    notifyList.Parent = sg
    local notifyLayout = Instance.new("UIListLayout")
    notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifyLayout.Padding = UDim.new(0, 8)
    notifyLayout.Parent = notifyList

    local dragStart, startPos
    local isDraggingMain = false

    local function enableDragging(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if openDropdownClose then openDropdownClose() openDropdownClose = nil end
                isDraggingMain = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
    end

    trackConn(UIS.InputChanged:Connect(function(input)
        if isDraggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    trackConn(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDraggingMain then saveGuiState() end
            isDraggingMain = false
        end
    end))

    enableDragging(topBar)
    enableDragging(sidebar)
    enableDragging(headerWrap)

    local function toggleUI()
        uiVisible = not uiVisible
        if uiVisible then
            main.Visible = true
            main.Size = UDim2.new(0, 0, 0, 0)
            tw(main, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        else
            tw(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.16, function() main.Visible = false end)
        end
        if openDropdownClose then openDropdownClose() openDropdownClose = nil end
    end
    minBtn.MouseButton1Click:Connect(toggleUI)

    local floatToggle = Instance.new("ImageButton")
    floatToggle.Name = "FloatToggle"
    floatToggle.BackgroundColor3 = Th.Sidebar
    floatToggle.Image = ToggleIcon
    floatToggle.ScaleType = Enum.ScaleType.Fit
    floatToggle.AutoButtonColor = false
    floatToggle.Active = true
    floatToggle.Draggable = false
    floatToggle.ZIndex = 500
    floatToggle.Parent = sg
    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,14) c.Parent = floatToggle end
    local floatPad = Instance.new("UIPadding") floatPad.PaddingLeft=UDim.new(0,8) floatPad.PaddingRight=UDim.new(0,8) floatPad.PaddingTop=UDim.new(0,8) floatPad.PaddingBottom=UDim.new(0,8) floatPad.Parent = floatToggle

    local function refreshFloatSize()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        local sz
        if UIS.TouchEnabled and vp.X < 700 then
            sz = 40
        elseif vp.X < 1100 then
            sz = 50
        else
            sz = 58
        end
        floatToggle.Size = UDim2.new(0, sz, 0, sz)
    end
    refreshFloatSize()
    if workspace.CurrentCamera then
        trackConn(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshFloatSize))
    end
    floatToggle.Position = UDim2.new(0, 20, 0.5, -20)

    do
        local fDragging, fDragStart, fStartPos
        trackConn(floatToggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fDragging = true
                fDragStart = input.Position
                fStartPos = floatToggle.Position
            end
        end))
        trackConn(UIS.InputChanged:Connect(function(input)
            if fDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - fDragStart
                floatToggle.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
            end
        end))
        trackConn(UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fDragging = false
            end
        end))
    end

    floatToggle.MouseButton1Click:Connect(function()
        local cur = floatToggle.Size
        tw(floatToggle, {Size = UDim2.new(cur.X.Scale, cur.X.Offset - 2, cur.Y.Scale, cur.Y.Offset - 2)}, 0.1, Enum.EasingStyle.Sine)
        task.delay(0.1, function() tw(floatToggle, {Size = cur}, 0.1, Enum.EasingStyle.Sine) end)
        toggleUI()
    end)

    local function toggleFullscreen()
        if not fullscreen then
            savedSize = main.Size ; savedPos = main.Position
            tw(main, { Size = UDim2.new(1,0,1,0), Position = UDim2.new(0.5,0,0.5,0) }, 0.3, Enum.EasingStyle.Quint)
            fullscreen = true
        else
            tw(main, { Size = savedSize, Position = savedPos }, 0.3, Enum.EasingStyle.Quint)
            fullscreen = false
        end
    end
    maxBtn.MouseButton1Click:Connect(toggleFullscreen)

    trackConn(UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Enum.KeyCode.RightShift then toggleUI() end
    end))

    local tabList = {}
    local groupList = {}
    local groupCount = 0
    local CategoryColors = {
        Color3.fromRGB(235, 110, 155),
        Color3.fromRGB(100, 175, 240),
        Color3.fromRGB(110, 205, 150),
        Color3.fromRGB(235, 180, 90),
        Color3.fromRGB(175, 135, 230),
        Color3.fromRGB(230, 130, 130),
        Color3.fromRGB(100, 205, 205),
        Color3.fromRGB(230, 205, 100),
        Color3.fromRGB(230, 150, 200),
        Color3.fromRGB(135, 230, 175),
        Color3.fromRGB(140, 155, 230),
        Color3.fromRGB(230, 160, 115),
    }

    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        if not currentActiveTab then return end
        local q = string.lower(searchInput.Text)
        for _, item in ipairs(currentActiveTab.elements) do
            if q == "" then
                item.row.Visible = true
            elseif string.find(string.lower(item.title), q) then
                item.row.Visible = true
            else
                item.row.Visible = false
            end
        end
    end)

    local function selectTab(tabObj)
        if openDropdownClose then openDropdownClose() openDropdownClose = nil end
        currentActiveTab = tabObj
        searchInput.Text = ""
        for _, t in ipairs(tabList) do
            t.scroll.Visible = false
            tw(t.btn, { BackgroundTransparency = 1, BackgroundColor3 = Th.Active }, 0.12)
            t.btn.TextColor3 = Th.Sub
            if t.indicator then tw(t.indicator, { Size = UDim2.new(0,3,0,0) }, 0.12) end
        end
        tabObj.scroll.Visible = true
        tw(tabObj.btn, { BackgroundTransparency = 0, BackgroundColor3 = Th.Active }, 0.12)
        tabObj.btn.TextColor3 = Th.Accent
        if tabObj.indicator then tw(tabObj.indicator, { Size = UDim2.new(0,3,0,18) }, 0.14) end
        pageTitle.Text = tabObj.name
    end

    WindowAPI = {}
    WindowAPI.Flags = {}

    function WindowAPI.SaveConfig(name)
        if not (writefile and isfolder and makefolder) then
            WindowAPI.Notify({Title = "Save Config", Description = "Executor นี้ไม่รองรับ writefile", Duration = 3})
            return
        end
        local folder = "ZenithSoul/configs"
        if not isfolder(folder) then makefolder(folder) end
        local data = {}
        for flag, obj in pairs(WindowAPI.Flags) do
            local ok, v = pcall(function() return obj:Get() end)
            if ok then
                if typeof(v) == "Color3" then
                    data[flag] = {__color = true, r = v.R, g = v.G, b = v.B}
                elseif typeof(v) == "EnumItem" then
                    data[flag] = {__enum = true, name = v.Name}
                else
                    data[flag] = v
                end
            end
        end
        local ok2, encoded = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
        if ok2 then
            writefile(folder .. "/" .. name .. ".json", encoded)
            WindowAPI.Notify({Title = "Save Config", Description = "บันทึกค่าสำเร็จ: " .. name, Duration = 3})
        end
    end

    function WindowAPI.LoadConfig(name)
        if not (readfile and isfile) then
            WindowAPI.Notify({Title = "Load Config", Description = "Executor นี้ไม่รองรับ readfile", Duration = 3})
            return
        end
        local path = "ZenithSoul/configs/" .. name .. ".json"
        if not isfile(path) then
            WindowAPI.Notify({Title = "Load Config", Description = "ไม่พบไฟล์: " .. name, Duration = 3})
            return
        end
        local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(path)) end)
        if not ok then return end
        for flag, v in pairs(data) do
            local obj = WindowAPI.Flags[flag]
            if obj and obj.Set then
                if type(v) == "table" and v.__color then
                    obj:Set(Color3.new(v.r, v.g, v.b))
                elseif type(v) == "table" and v.__enum then
                    pcall(function() obj:Set(Enum.KeyCode[v.name]) end)
                else
                    obj:Set(v)
                end
            end
        end
        WindowAPI.Notify({Title = "Load Config", Description = "โหลดค่าสำเร็จ: " .. name, Duration = 3})
    end

    function WindowAPI.SetTransparency(val)
        windowTrans = math.clamp(val, 0, 0.95)
        tw(contentBG, {BackgroundTransparency = windowTrans}, 0.15)
        saveGuiState()
    end

    WindowAPI.SaveGuiState = saveGuiState
    function WindowAPI.LoadGuiState()
        local data = loadGuiState()
        if not data then
            WindowAPI.Notify({Title = "Load GUI", Description = "ยังไม่เคยเซฟสถานะ GUI ไว้", Duration = 3})
            return
        end
        if data.Theme and Themes[data.Theme] then WindowAPI.SetTheme(data.Theme) end
        if data.PosXS then main.Position = UDim2.new(data.PosXS, data.PosXO or 0, data.PosYS or 0.5, data.PosYO or 0) end
        if type(data.WindowTrans) == "number" then WindowAPI.SetTransparency(data.WindowTrans) end
        if type(data.CardTrans) == "number" then WindowAPI.SetCardTransparency(data.CardTrans) end
        WindowAPI.Notify({Title = "Load GUI", Description = "โหลดสถานะ GUI สำเร็จ", Duration = 3})
    end

    function WindowAPI.SetCardTransparency(val)
        cardTrans = math.clamp(val, 0, 0.9)
        for _, t in ipairs(tabList) do
            for _, item in ipairs(t.elements) do
                if item.type == "card" and item.row then
                    tw(item.row, {BackgroundTransparency = cardTrans}, 0.15)
                elseif item.type == "paragraph" and item.row then
                    tw(item.row, {BackgroundTransparency = math.clamp(cardTrans + 0.18, 0, 0.9)}, 0.15)
                end
            end
        end
        saveGuiState()
    end

    function WindowAPI.SetBackgroundImage(imageId, transparency)
        bgImage.Image = imageId or ""
        bgImage.Visible = imageId ~= nil and imageId ~= ""
        if transparency then bgImage.ImageTransparency = transparency end
    end

    function WindowAPI.SetIcon(imageId)
        profileIcon.Image = hasIcon(imageId) and imageId or ""
        profileIcon.Visible = hasIcon(imageId)
    end
    WindowAPI.SetIcon(ProfileIcon)

    function WindowAPI.Destroy()
        sg:Destroy()
    end

    function WindowAPI.SetTheme(themeName)
        local targetTheme = Themes[themeName]
        if not targetTheme then return end
        Th = targetTheme
        currentThemeName = themeName

        tw(main, {BackgroundColor3 = Th.BG}, 0.2)
        tw(mainStroke, {Color = Th.Border}, 0.2)
        tw(sidebar, {BackgroundColor3 = Th.Sidebar}, 0.2)
        tw(sbFix, {BackgroundColor3 = Th.Sidebar}, 0.2)
        tw(accentBar, {BackgroundColor3 = Th.Accent}, 0.2)
        tw(profileIcon, {BackgroundColor3 = Th.Active}, 0.2)
        tw(profileStroke, {Color = Th.Border}, 0.2)
        tw(floatToggle, {BackgroundColor3 = Th.Sidebar}, 0.2)
        tw(titleLbl, {TextColor3 = Th.Text}, 0.2)
        tw(subTitleLbl, {TextColor3 = Th.Accent}, 0.2)
        tw(headerLine, {BackgroundColor3 = Th.Border}, 0.2)
        tw(pageTitle, {TextColor3 = Th.Text}, 0.2)
        tw(topLine, {BackgroundColor3 = Th.Border}, 0.2)
        tw(searchWrap, {BackgroundColor3 = Th.Sidebar}, 0.2)
        tw(searchStroke, {Color = Th.Border}, 0.2)
        searchIcon.TextColor3 = Th.Sub
        tw(searchInput, {TextColor3 = Th.Text}, 0.2)

        for _, t in ipairs(tabList) do
            if t == currentActiveTab then
                t.btn.TextColor3 = Th.Accent
                t.btn.BackgroundColor3 = Th.Active
            else
                t.btn.TextColor3 = Th.Sub
            end

            for _, item in ipairs(t.elements) do
                if item.type == "section" then
                    item.label.TextColor3 = Th.Accent
                elseif item.type == "card" or item.type == "paragraph" then
                    item.row.BackgroundColor3 = Th.Card
                    if item.stroke then item.stroke.Color = Th.Border end
                    if item.titleLbl then item.titleLbl.TextColor3 = Th.Text end
                    if item.subLbl then item.subLbl.TextColor3 = Th.Sub end
                    if item.sw then item.sw.BackgroundColor3 = Th.Border end
                    if item.track then item.track.BackgroundColor3 = Th.Border end
                    if item.fill then item.fill.BackgroundColor3 = Th.Accent end
                    if item.valLbl then item.valLbl.TextColor3 = Th.Accent end
                    if item.box then
                        item.box.BackgroundColor3 = Th.Active
                        item.boxStroke.Color = Th.Border
                        item.boxLbl.TextColor3 = Th.Text
                    end
                    if item.inputWrap then
                        item.inputWrap.BackgroundColor3 = Th.BG
                        item.inputStroke.Color = Th.Border
                        item.inputField.TextColor3 = Th.Text
                    end
                    if item.btnText then item.btnText.TextColor3 = Th.Text end
                    if item.checkBox then
                        item.checkBox.BackgroundColor3 = Th.BG
                        item.checkStroke.Color = Th.Border
                    end
                    if item.keybindBox then
                        item.keybindBox.BackgroundColor3 = Th.BG
                        item.keybindStroke.Color = Th.Border
                        item.keybindLbl.TextColor3 = Th.Accent
                    end
                    if item.colorPreview then
                        item.colorStroke.Color = Th.Border
                    end
                    if item.progressTrack then
                        item.progressTrack.BackgroundColor3 = Th.Border
                        item.progressFill.BackgroundColor3 = Th.Accent
                    end
                    if item.refreshMulti then item.refreshMulti() end
                end
            end
        end
        saveGuiState()
    end

    local activeNotifs = {}
    local MAX_NOTIFS = 4

    function WindowAPI.Notify(params)
        params = params or {}
        local nTitle = params.Title or "Notification"
        local nDesc = params.Description or "Successfully updated."
        local nDur = params.Duration or 3

        while #activeNotifs >= MAX_NOTIFS do
            local oldest = table.remove(activeNotifs, 1)
            if oldest and oldest.Parent then
                tw(oldest, {Size = UDim2.new(1, 0, 0, 0)}, 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                task.delay(0.15, function() oldest:Destroy() end)
            end
        end

        local nBox = Instance.new("Frame")
        nBox.Size = UDim2.new(1, 0, 0, 0)
        nBox.BackgroundColor3 = Th.Card
        nBox.ClipsDescendants = true
        nBox.Parent = notifyList
        do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = nBox end
        local nStroke = Instance.new("UIStroke") nStroke.Color = Th.Accent nStroke.Transparency = 0.5 nStroke.Thickness = 1 nStroke.Parent = nBox

        local nT = Instance.new("TextLabel")
        nT.Size = UDim2.new(1, -20, 0, 16)
        nT.Position = UDim2.new(0, 10, 0, 6)
        nT.BackgroundTransparency = 1
        nT.Text = nTitle
        nT.TextSize = 12
        nT.TextColor3 = Th.Accent
        nT.Font = Enum.Font.GothamBold
        nT.TextXAlignment = Enum.TextXAlignment.Left
        nT.Parent = nBox

        local nD = Instance.new("TextLabel")
        nD.Size = UDim2.new(1, -20, 0, 24)
        nD.Position = UDim2.new(0, 10, 0, 22)
        nD.BackgroundTransparency = 1
        nD.Text = nDesc
        nD.TextSize = 11
        nD.TextColor3 = Th.Text
        nD.Font = Enum.Font.Gotham
        nD.TextXAlignment = Enum.TextXAlignment.Left
        nD.TextWrapped = true
        nD.Parent = nBox

        table.insert(activeNotifs, nBox)
        tw(nBox, {Size = UDim2.new(1, 0, 0, 52)}, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.delay(nDur, function()
            if not nBox.Parent then return end
            tw(nBox, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.wait(0.2)
            for i, v in ipairs(activeNotifs) do
                if v == nBox then table.remove(activeNotifs, i) break end
            end
            nBox:Destroy()
        end)
    end

    -- -------- 3.4 WindowAPI.AddTab --------
    function WindowAPI.AddTab(name, group)
        group = group or "MAIN"

        if not groupList[group] then
            groupCount = groupCount + 1
            local catColor = CategoryColors[((groupCount - 1) % #CategoryColors) + 1]

            local catBtn = Instance.new("TextButton")
            catBtn.Size = UDim2.new(1,0,0,32)
            catBtn.BackgroundColor3 = catColor
            catBtn.BackgroundTransparency = 0.85
            catBtn.AutoButtonColor = false
            catBtn.Text = ""
            catBtn.LayoutOrder = #tabList * 100
            catBtn.Parent = navScroll
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,6) c.Parent = catBtn end
            local catStroke = Instance.new("UIStroke") catStroke.Color = catColor catStroke.Transparency = 0.45 catStroke.Thickness = 1 catStroke.Parent = catBtn
            
            task.spawn(function()
                while catStroke.Parent do
                    tw(catStroke, {Transparency = 0.7}, 1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1.4)
                    if not catStroke.Parent then break end
                    tw(catStroke, {Transparency = 0.45}, 1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1.4)
                end
            end)
            local gp = Instance.new("UIPadding") ; gp.PaddingTop = UDim.new(0,3) ; gp.Parent = catBtn

            local catBar = Instance.new("Frame")
            catBar.Size = UDim2.new(0,3,1,-10)
            catBar.Position = UDim2.new(0,4,0,5)
            catBar.BackgroundColor3 = catColor
            catBar.BorderSizePixel = 0
            catBar.Parent = catBtn
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = catBar end

            local catLabel = Instance.new("TextLabel")
            catLabel.Size = UDim2.new(1,-36,1,0)
            catLabel.Position = UDim2.new(0,14,0,0)
            catLabel.BackgroundTransparency = 1
            catLabel.Text = string.upper(group)
            catLabel.TextSize = 13
            catLabel.TextColor3 = catColor
            catLabel.Font = Enum.Font.GothamBold
            catLabel.TextXAlignment = Enum.TextXAlignment.Left
            catLabel.Parent = catBtn

            local catIcon = Instance.new("TextLabel")
            catIcon.Size = UDim2.new(0,20,1,0)
            catIcon.Position = UDim2.new(1,-22,0,0)
            catIcon.BackgroundTransparency = 1
            catIcon.Text = "-"
            catIcon.TextColor3 = catColor
            catIcon.TextSize = 14
            catIcon.Font = Enum.Font.GothamBold
            catIcon.Parent = catBtn
            catIcon.Rotation = 180

            groupList[group] = { btn = catBtn, icon = catIcon, isOpen = false, tabs = {}, color = catColor }

            catBtn.MouseEnter:Connect(function() tw(catBtn, {BackgroundTransparency = 0.72}, 0.12) end)
            catBtn.MouseLeave:Connect(function() tw(catBtn, {BackgroundTransparency = 0.85}, 0.12) end)

            local groupBusy = false
            catBtn.MouseButton1Click:Connect(function()
                if groupBusy then return end
                groupBusy = true

                local g = groupList[group]
                g.isOpen = not g.isOpen
                tw(g.icon, {Rotation = g.isOpen and 0 or 180}, 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

                for _, t in ipairs(g.tabs) do
                    if g.isOpen then
                        t.btn.Visible = true
                        t.btn.Size = UDim2.new(1, 0, 0, 0)
                        t.btn.BackgroundTransparency = 1
                        tw(t.btn, {Size = UDim2.new(1, 0, 0, 34)}, 0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        tw(t.btn, {BackgroundTransparency = 1}, 0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    else
                        tw(t.btn, {Size = UDim2.new(1, 0, 0, 0)}, 0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    end
                end

                task.wait(0.12)
                if not g.isOpen then
                    for _, t in ipairs(g.tabs) do t.btn.Visible = false end
                end
                groupBusy = false
            end)
        end

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1,0,1,0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 0
        scroll.Visible = false
        scroll.Parent = contentFrame

        scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if openDropdownClose then openDropdownClose() openDropdownClose = nil end
        end)

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0,7)
        layout.Parent = scroll

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0,10)
        pad.PaddingRight = UDim.new(0,10)
        pad.PaddingTop = UDim.new(0,8)
        pad.PaddingBottom = UDim.new(0,20)
        pad.Parent = scroll

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
        end)

        local btn = Instance.new("TextButton")
        local groupIsOpen = groupList[group].isOpen
        btn.Size = groupIsOpen and UDim2.new(1,0,0,34) or UDim2.new(1,0,0,0)
        btn.Visible = groupIsOpen
        btn.BackgroundTransparency = 1
        btn.Text = "   " .. name
        btn.TextSize = 14
        btn.TextColor3 = Th.Sub
        btn.Font = Enum.Font.GothamBold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.LayoutOrder = groupList[group].btn.LayoutOrder + #groupList[group].tabs + 1
        btn.Parent = navScroll
        do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,10) c.Parent = btn end

        local tabIndicator = Instance.new("Frame")
        tabIndicator.Size = UDim2.new(0,3,0,0)
        tabIndicator.Position = UDim2.new(0,0,0.5,0)
        tabIndicator.AnchorPoint = Vector2.new(0,0.5)
        tabIndicator.BackgroundColor3 = groupList[group].color
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Parent = btn
        do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = tabIndicator end

        local tabObj = { scroll = scroll, btn = btn, indicator = tabIndicator, layout = layout, _order = 0, name = name, elements = {}, groupColor = groupList[group].color }

        btn.MouseButton1Click:Connect(function()
            selectTab(tabObj)
        end)

        btn.MouseEnter:Connect(function() if currentActiveTab ~= tabObj then tw(btn, {BackgroundTransparency = 0.7, BackgroundColor3 = Th.Active}) end end)
        btn.MouseLeave:Connect(function() if currentActiveTab ~= tabObj then tw(btn, {BackgroundTransparency = 1}) end end)

        table.insert(tabList, tabObj)
        table.insert(groupList[group].tabs, tabObj)
        if #tabList == 1 then selectTab(tabObj) end

        local function nextOrder() tabObj._order = tabObj._order + 1 return tabObj._order end

        local function newBox(height, title)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0, height or 44)
            row.BackgroundColor3 = Th.Card
            row.BackgroundTransparency = cardTrans
            row.BorderSizePixel = 0
            row.LayoutOrder = nextOrder()
            row.Parent = scroll
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,6) c.Parent = row end
            local stroke = Instance.new("UIStroke")
            stroke.Color = Th.Border
            stroke.Transparency = 0
            stroke.Thickness = 1.2
            stroke.Parent = row
            local pad2 = Instance.new("UIPadding") ; pad2.PaddingLeft = UDim.new(0,14) ; pad2.PaddingRight = UDim.new(0,14) ; pad2.Parent = row
            
            local sheen = Instance.new("UIGradient")
            sheen.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(210,210,210)),
            })
            sheen.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.94),
                NumberSequenceKeypoint.new(1, 1),
            })
            sheen.Rotation = 90
            sheen.Parent = row
            return row, stroke
        end

        -- ปรับระยะเว้นด้านขวาของ Text ให้กลับมาสมดุลกับความกว้างหน้าต่าง 740 ดั่งเดิม (-155 แทนที่จะเป็น -205)
        local function injectText(row, title, desc)
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1,-155,0, desc and 16 or 0)
            nameLbl.Position = UDim2.new(0,0, desc and 0.5, desc and -15 or 0)
            if not desc then nameLbl.Size = UDim2.new(1,-155,1,0) nameLbl.AnchorPoint = Vector2.new(0,0) end
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = title
            nameLbl.TextSize = 14
            nameLbl.TextColor3 = Th.Text
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextYAlignment = Enum.TextYAlignment.Center
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.Parent = row

            local descLbl = nil
            if desc then
                descLbl = Instance.new("TextLabel")
                descLbl.Size = UDim2.new(1,-155,0,13)
                descLbl.Position = UDim2.new(0,0,0.5,3)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.TextSize = 11
                descLbl.TextColor3 = Th.Sub
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.TextTruncate = Enum.TextTruncate.AtEnd
                descLbl.Parent = row
            end
            return nameLbl, descLbl
        end

        -- ============ COMPONENTS ============

        function tabObj:AddSection(title)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,22)
            row.BackgroundTransparency = 1
            row.LayoutOrder = nextOrder()
            row.Parent = scroll
            local pad2 = Instance.new("UIPadding") ; pad2.PaddingTop = UDim.new(0,4) ; pad2.Parent = row
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1,0,1,0)
            t.BackgroundTransparency = 1
            t.Text = title
            t.TextSize = 12
            t.TextColor3 = Th.Accent
            t.Font = Enum.Font.GothamBold
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = row
            table.insert(tabObj.elements, {row = row, title = title, type = "section", label = t})
        end

        function tabObj:AddDivider()
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,9)
            row.BackgroundTransparency = 1
            row.LayoutOrder = nextOrder()
            row.Parent = scroll
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1,0,0,1)
            line.Position = UDim2.new(0,0,0.5,0)
            line.BackgroundColor3 = Th.Border
            line.BorderSizePixel = 0
            line.Parent = row
            table.insert(tabObj.elements, {row = row, title = "", type = "card", stroke = nil})
        end

        function tabObj:AddParagraph(title, text)
            local row, stroke = newBox(0, title)
            row.AutomaticSize = Enum.AutomaticSize.Y
            row.BackgroundTransparency = 0
            local pad3 = Instance.new("UIPadding") pad3.PaddingTop = UDim.new(0,8) pad3.PaddingBottom = UDim.new(0,10) pad3.PaddingLeft = UDim.new(0,10) pad3.PaddingRight = UDim.new(0,10) pad3.Parent = row
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1,0,0,20)
            t.BackgroundTransparency = 1
            t.Text = title
            t.TextSize = 16
            t.TextColor3 = Th.Text
            t.Font = Enum.Font.GothamBold
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = row
            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1,0,0,0)
            d.Position = UDim2.new(0,0,0,22)
            d.AutomaticSize = Enum.AutomaticSize.Y
            d.BackgroundTransparency = 1
            d.Text = text
            d.TextSize = 14
            d.TextWrapped = true
            d.TextColor3 = Th.Sub
            d.Font = Enum.Font.Gotham
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = row
            table.insert(tabObj.elements, {row = row, stroke = stroke, title = title, type = "paragraph", titleLbl = t, subLbl = d})
        end

        function tabObj:AddToggle(title, desc, callback, flag)
            local row, stroke = newBox(desc and 52 or 42, title)
            local nameLbl, descLbl = injectText(row, title, desc)
            local state = false

            local sw = Instance.new("Frame")
            sw.Size = UDim2.new(0,40,0,22)
            sw.AnchorPoint = Vector2.new(1,0.5)
            sw.Position = UDim2.new(1,0,0.5,0)
            sw.BackgroundColor3 = Th.Border
            sw.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = sw end

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0,17,0,17)
            knob.Position = UDim2.new(0,3,0.5,-8)
            knob.BackgroundColor3 = Th.Sub
            knob.Parent = sw
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = knob end
            do local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(0,0,0) s.Transparency = 0.85 s.Thickness = 1 s.Parent = knob end

            local btnHit = Instance.new("TextButton")
            btnHit.Size = UDim2.new(1,0,1,0)
            btnHit.BackgroundTransparency = 1
            btnHit.Text = ""
            btnHit.ZIndex = 3
            btnHit.Parent = sw

            local rowHit = Instance.new("TextButton")
            rowHit.Size = UDim2.new(1,0,1,0)
            rowHit.BackgroundTransparency = 1
            rowHit.Text = ""
            rowHit.ZIndex = 1
            rowHit.Parent = row

            local function render()
                if state then
                    tw(sw, {BackgroundColor3 = Th.Accent}, 0.15)
                    tw(knob, {Position = UDim2.new(1,-20,0.5,-8), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.15)
                else
                    tw(sw, {BackgroundColor3 = Th.Border}, 0.15)
                    tw(knob, {Position = UDim2.new(0,3,0.5,-8), BackgroundColor3 = Th.Sub}, 0.15)
                end
            end

            local function doToggle()
                tw(sw, {Size = UDim2.new(0,36,0,20)}, 0.08)
                task.delay(0.08, function() tw(sw, {Size = UDim2.new(0,40,0,22)}, 0.08) end)
                state = not state ; render()
                if callback then pcall(callback, state) end
            end

            btnHit.MouseButton1Click:Connect(doToggle)
            rowHit.MouseButton1Click:Connect(doToggle)
            row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = Th.Active}, 0.1) end)
            row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = Th.Card}, 0.1) end)

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, subLbl = descLbl, sw = sw, knob = knob
            })

            local obj = {
                Set = function(_, v)
                    state = v
                    render()
                    if callback then pcall(callback, state) end
                end,
                Get = function() return state end,
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddCheckbox(title, desc, default, callback, flag)
            local row, stroke = newBox(desc and 52 or 42, title)
            local nameLbl, descLbl = injectText(row, title, desc)
            local state = false

            local checkBox = Instance.new("TextButton")
            checkBox.Size = UDim2.new(0,22,0,22)
            checkBox.AnchorPoint = Vector2.new(1,0.5)
            checkBox.Position = UDim2.new(1,0,0.5,0)
            checkBox.BackgroundColor3 = Th.BG
            checkBox.Text = ""
            checkBox.AutoButtonColor = false
            checkBox.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,5) c.Parent = checkBox end
            local checkStroke = Instance.new("UIStroke") checkStroke.Color = Th.Border checkStroke.Parent = checkBox

            local mark = Instance.new("TextLabel")
            mark.Size = UDim2.new(1,0,1,0)
            mark.BackgroundTransparency = 1
            mark.Text = "✓"
            mark.TextSize = 13
            mark.TextColor3 = Th.Accent
            mark.Font = Enum.Font.GothamBold
            mark.TextTransparency = state and 0 or 1
            mark.Parent = checkBox
            checkBox.ZIndex = 2

            local rowHit = Instance.new("TextButton")
            rowHit.Size = UDim2.new(1,0,1,0)
            rowHit.BackgroundTransparency = 1
            rowHit.Text = ""
            rowHit.ZIndex = 1
            rowHit.Parent = row

            local function doCheck()
                state = not state
                tw(mark, {TextTransparency = state and 0 or 1}, 0.1)
                if callback then pcall(callback, state) end
            end

            checkBox.MouseButton1Click:Connect(doCheck)
            rowHit.MouseButton1Click:Connect(doCheck)
            row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = Th.Active}, 0.1) end)
            row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = Th.Card}, 0.1) end)

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, subLbl = descLbl, checkBox = checkBox, checkStroke = checkStroke
            })
            local obj = {
                Set = function(_, v)
                    state = v
                    tw(mark, {TextTransparency = state and 0 or 1}, 0.1)
                    if callback then pcall(callback, state) end
                end,
                Get = function() return state end,
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddSlider(text, min, max, default, callback, flag)
            min, max = min or 0, max or 100
            local value = math.clamp(default or min, min, max)
            local isDragging = false
            local row, stroke = newBox(52, text)
            local nameLbl, descLbl = injectText(row, text)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0,35,0,14)
            valLbl.AnchorPoint = Vector2.new(1,0)
            valLbl.Position = UDim2.new(1,0,0,4)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(value)
            valLbl.TextSize = 11
            valLbl.TextColor3 = Th.Accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1,0,0,4)
            track.Position = UDim2.new(0,0,1,-10)
            track.BackgroundColor3 = Th.Border
            track.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = track end

            local trackHit = Instance.new("Frame")
            trackHit.Size = UDim2.new(1,0,0,24)
            trackHit.Position = UDim2.new(0,0,1,-22)
            trackHit.BackgroundTransparency = 1
            trackHit.Parent = row

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
            fill.BackgroundColor3 = Th.Accent
            fill.Parent = track
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = fill end

            local function updateVal(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X,1), 0, 1)
                value = math.floor(min + rel*(max-min))
                tw(fill, {Size = UDim2.new(rel,0,1,0)}, 0.08)
                valLbl.Text = tostring(value)
                if callback then pcall(callback, value) end
            end

            trackHit.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true ; updateVal(i.Position.X)
                end
            end)
            trackConn(UIS.InputChanged:Connect(function(i)
                if isDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    updateVal(i.Position.X)
                end
            end))
            trackConn(UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end))

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = text, type = "card",
                titleLbl = nameLbl, track = track, fill = fill, valLbl = valLbl
            })

            local obj = {
                Set = function(_, v)
                    value = math.clamp(v, min, max)
                    local rel = (value-min)/(max-min)
                    tw(fill, {Size = UDim2.new(rel,0,1,0)}, 0.1)
                    valLbl.Text = tostring(value)
                end,
                Get = function() return value end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddSpeedSlider(text, min, max, default, callback, flag)
            min, max = min or 1, max or 100
            local value = math.clamp(default or min, min, max)
            local isDragging = false
            local row, stroke = newBox(56, text)
            local nameLbl = injectText(row, text)

            local inputWrap = Instance.new("Frame")
            inputWrap.Size = UDim2.new(0,44,0,18)
            inputWrap.AnchorPoint = Vector2.new(1,0)
            inputWrap.Position = UDim2.new(1,0,0,2)
            inputWrap.BackgroundColor3 = Th.BG
            inputWrap.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,4) c.Parent = inputWrap end
            local inputStroke = Instance.new("UIStroke") inputStroke.Color = Th.Border inputStroke.Parent = inputWrap

            local numField = Instance.new("TextBox")
            numField.Size = UDim2.new(1,-6,1,0)
            numField.Position = UDim2.new(0,3,0,0)
            numField.BackgroundTransparency = 1
            numField.Text = tostring(value)
            numField.TextSize = 11
            numField.TextColor3 = Th.Accent
            numField.Font = Enum.Font.GothamBold
            numField.Parent = inputWrap

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1,0,0,4)
            track.Position = UDim2.new(0,0,1,-10)
            track.BackgroundColor3 = Th.Border
            track.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = track end

            local trackHit = Instance.new("Frame")
            trackHit.Size = UDim2.new(1,0,0,24)
            trackHit.Position = UDim2.new(0,0,1,-22)
            trackHit.BackgroundTransparency = 1
            trackHit.Parent = row

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
            fill.BackgroundColor3 = Th.Accent
            fill.Parent = track
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = fill end

            local function setValue(v, fromField)
                value = math.clamp(math.floor(v), min, max)
                local rel = (value-min)/(max-min)
                tw(fill, {Size = UDim2.new(rel,0,1,0)}, 0.08)
                if not fromField then numField.Text = tostring(value) end
                if callback then pcall(callback, value) end
            end

            local function updateVal(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X,1), 0, 1)
                setValue(min + rel*(max-min))
            end

            trackHit.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true ; updateVal(i.Position.X)
                end
            end)
            trackConn(UIS.InputChanged:Connect(function(i)
                if isDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    updateVal(i.Position.X)
                end
            end))
            trackConn(UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end))

            numField.FocusLost:Connect(function()
                local n = tonumber(numField.Text)
                if n then setValue(n, true) else numField.Text = tostring(value) end
            end)

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = text, type = "card",
                titleLbl = nameLbl, track = track, fill = fill,
                inputWrap = inputWrap, inputStroke = inputStroke, inputField = numField
            })

            local obj = {
                Set = function(_, v) setValue(v) end,
                Get = function() return value end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        -- ปรับระยะดรอปดาวน์และลิสต์กลับมาเป็นขนาด 150 ที่พอดีกับหน้าต่าง 740 ดั่งเดิม
        function tabObj:AddDropdown(title, desc, options, default, callback, flag)
            options = options or {}
            local selected = default or "None"
            local open = false
            local row, stroke = newBox(desc and 52 or 42, title)
            local nameLbl, descLbl = injectText(row, title, desc)

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0,150,0,28)
            box.AnchorPoint = Vector2.new(1,0.5)
            box.Position = UDim2.new(1,0,0.5,0)
            box.BackgroundColor3 = Th.Active
            box.Text = ""
            box.AutoButtonColor = false
            box.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,4) c.Parent = box end
            local boxStroke = Instance.new("UIStroke") boxStroke.Color = Th.Border boxStroke.Thickness = 1.3 boxStroke.Transparency = 0 boxStroke.Parent = box

            local boxLbl = Instance.new("TextLabel")
            boxLbl.Size = UDim2.new(1,-12,1,0)
            boxLbl.Position = UDim2.new(0,6,0,0)
            boxLbl.BackgroundTransparency = 1
            boxLbl.Text = tostring(selected)
            boxLbl.TextSize = 12
            boxLbl.TextColor3 = Th.Text
            boxLbl.Font = Enum.Font.GothamBold
            boxLbl.TextXAlignment = Enum.TextXAlignment.Center
            boxLbl.TextTruncate = Enum.TextTruncate.AtEnd
            boxLbl.Parent = box

            local list = Instance.new("Frame")
            list.Size = UDim2.new(0,150,0, math.min(#options, 6)*30 + 6)
            list.BackgroundColor3 = Th.Card
            list.Visible = false
            list.ZIndex = 200
            list.Parent = sg
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,6) c.Parent = list end
            local listStroke = Instance.new("UIStroke") listStroke.Color = Th.Border listStroke.Thickness = 1.5 listStroke.Parent = list
            local listUIScale = Instance.new("UIScale") listUIScale.Parent = list

            local listScroll = Instance.new("ScrollingFrame")
            listScroll.Size = UDim2.new(1,-4,1,-4)
            listScroll.Position = UDim2.new(0,2,0,2)
            listScroll.BackgroundTransparency = 1
            listScroll.BorderSizePixel = 0
            listScroll.ScrollBarThickness = 0
            listScroll.CanvasSize = UDim2.new(0,0,0,#options*28)
            listScroll.ZIndex = 201
            listScroll.Parent = list

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0,2)
            listLayout.Parent = listScroll

            local optBtns = {}

            local function closeList()
                list.Visible = false ; open = false
                tw(box, {BackgroundColor3 = Th.BG}, 0.1)
            end

            local function updateListStyle()
                for optVal, btnObj in pairs(optBtns) do
                    if optVal == selected then
                        btnObj.BackgroundColor3 = Th.Accent
                        btnObj.BackgroundTransparency = 0.7
                        btnObj.TextColor3 = Th.Text
                    else
                        btnObj.BackgroundColor3 = Th.Active
                        btnObj.BackgroundTransparency = 0.5
                        btnObj.TextColor3 = Th.Sub
                    end
                end
            end

            local listPad = Instance.new("UIPadding")
            listPad.PaddingLeft = UDim.new(0,4)
            listPad.PaddingRight = UDim.new(0,4)
            listPad.Parent = listScroll

            local function buildOptions(newOptions)
                options = newOptions or {}
                for _, b in pairs(optBtns) do b:Destroy() end
                optBtns = {}

                for index, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1,0,0,28)
                    optBtn.BackgroundTransparency = 0.5
                    optBtn.BackgroundColor3 = Th.Active
                    optBtn.Text = tostring(opt)
                    optBtn.TextSize = 12
                    optBtn.Font = Enum.Font.GothamBold
                    optBtn.LayoutOrder = index
                    optBtn.ZIndex = 202
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.Parent = listScroll
                    do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,5) c.Parent = optBtn end
                    local oPad = Instance.new("UIPadding") oPad.PaddingLeft = UDim.new(0,8) oPad.Parent = optBtn

                    optBtns[opt] = optBtn

                    optBtn.MouseEnter:Connect(function()
                        if selected ~= opt then tw(optBtn, {BackgroundTransparency=0.2, BackgroundColor3=Th.Active}, 0.1) end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if selected ~= opt then tw(optBtn, {BackgroundTransparency=0.5}, 0.1) end
                    end)

                    optBtn.MouseButton1Click:Connect(function()
                        tw(box, {Size = UDim2.new(0,144,0,28)}, 0.08)
                        task.delay(0.08, function() tw(box, {Size = UDim2.new(0,150,0,28)}, 0.08) end)
                        selected = opt
                        boxLbl.Text = tostring(opt)
                        updateListStyle()
                        closeList()
                        if callback then pcall(callback, opt) end
                    end)
                end

                list.Size = UDim2.new(0,150,0, math.min(#options, 6)*30 + 6)
                listScroll.CanvasSize = UDim2.new(0,0,0,#options*28)
                updateListStyle()
            end

            buildOptions(options)

            box.MouseButton1Click:Connect(function()
                if open then closeList() return end
                if openDropdownClose then openDropdownClose() end
                tw(box, {BackgroundColor3 = Th.Active}, 0.1)
                listUIScale.Scale = uiScale.Scale
                local absPos = box.AbsolutePosition
                local listVisualW = 150 * uiScale.Scale
                local boxVisualW = box.AbsoluteSize.X
                list.Position = UDim2.new(0, absPos.X + boxVisualW - listVisualW, 0, absPos.Y + box.AbsoluteSize.Y + 4)
                list.Visible = true ; open = true
                openDropdownClose = closeList
            end)

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, subLbl = descLbl, box = box, boxStroke = boxStroke, boxLbl = boxLbl
            })

            local obj = {
                Set = function(_, v) selected = v boxLbl.Text = tostring(v) updateListStyle() end,
                Get = function() return selected end,
                Refresh = function(_, newOptions, keepSelection)
                    local prevSelected = selected
                    buildOptions(newOptions)
                    if keepSelection then
                        local stillExists = false
                        for _, opt in ipairs(options) do
                            if opt == prevSelected then stillExists = true break end
                        end
                        if stillExists then
                            selected = prevSelected
                        else
                            selected = options[1] or "None"
                            boxLbl.Text = tostring(selected)
                            if callback then pcall(callback, selected) end
                        end
                    else
                        selected = options[1] or "None"
                    end
                    boxLbl.Text = tostring(selected)
                    updateListStyle()
                end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        -- ปรับระยะตัวเลือกแบบหลายรายการ (Multi-Select Dropdown) กลับมาเป็นขนาด 150 ที่สมมาตร
        function tabObj:AddMultiDropdown(title, desc, options, defaults, callback, flag)
            options = options or {}
            local selectedSet = {}
            for _, v in ipairs(defaults or {}) do selectedSet[v] = true end
            local open = false
            local row, stroke = newBox(desc and 52 or 42, title)
            local nameLbl, descLbl = injectText(row, title, desc)

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0,150,0,28)
            box.AnchorPoint = Vector2.new(1,0.5)
            box.Position = UDim2.new(1,0,0.5,0)
            box.BackgroundColor3 = Th.Active
            box.Text = ""
            box.AutoButtonColor = false
            box.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,4) c.Parent = box end
            local boxStroke = Instance.new("UIStroke") boxStroke.Color = Th.Border boxStroke.Thickness = 1.3 boxStroke.Transparency = 0 boxStroke.Parent = box

            local boxLbl = Instance.new("TextLabel")
            boxLbl.Size = UDim2.new(1,-12,1,0)
            boxLbl.Position = UDim2.new(0,6,0,0)
            boxLbl.BackgroundTransparency = 1
            boxLbl.TextSize = 12
            boxLbl.TextColor3 = Th.Text
            boxLbl.Font = Enum.Font.GothamBold
            boxLbl.TextXAlignment = Enum.TextXAlignment.Center
            boxLbl.TextTruncate = Enum.TextTruncate.AtEnd
            boxLbl.Parent = box

            local function labelText()
                local n = 0
                for _ in pairs(selectedSet) do n += 1 end
                if n == 0 then return "None"
                elseif n == 1 then for k in pairs(selectedSet) do return tostring(k) end
                else return n .. " selected" end
            end
            boxLbl.Text = labelText()

            local list = Instance.new("Frame")
            list.Size = UDim2.new(0,160,0, math.min(#options, 6)*32 + 8)
            list.BackgroundColor3 = Th.Card
            list.Visible = false
            list.ZIndex = 200
            list.Parent = sg
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,6) c.Parent = list end
            local listStroke = Instance.new("UIStroke") listStroke.Color = Th.Border listStroke.Thickness = 1.5 listStroke.Parent = list
            local listUIScale = Instance.new("UIScale") listUIScale.Parent = list

            local listScroll = Instance.new("ScrollingFrame")
            listScroll.Size = UDim2.new(1,-6,1,-6)
            listScroll.Position = UDim2.new(0,3,0,3)
            listScroll.BackgroundTransparency = 1
            listScroll.BorderSizePixel = 0
            listScroll.ScrollBarThickness = 2
            listScroll.ScrollBarImageColor3 = Th.Border
            listScroll.CanvasSize = UDim2.new(0,0,0,#options*32)
            listScroll.ZIndex = 201
            listScroll.Parent = list

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0,3)
            listLayout.Parent = listScroll

            local optBtns = {}
            local optStrokes = {}

            local function refreshStyle()
                for optVal, btnObj in pairs(optBtns) do
                    local isSelected = selectedSet[optVal]
                    if isSelected then
                        btnObj.BackgroundColor3 = Th.Accent
                        btnObj.BackgroundTransparency = 0.75
                        btnObj.TextColor3 = Th.Text
                        btnObj.Text = "✓  " .. tostring(optVal)
                        if optStrokes[optVal] then
                            optStrokes[optVal].Color = Th.Accent
                            optStrokes[optVal].Transparency = 0
                        end
                    else
                        btnObj.BackgroundColor3 = Th.Active
                        btnObj.BackgroundTransparency = 0.6
                        btnObj.TextColor3 = Th.Sub
                        btnObj.Text = "      " .. tostring(optVal)
                        if optStrokes[optVal] then
                            optStrokes[optVal].Transparency = 1
                        end
                    end
                end
                boxLbl.Text = labelText()
            end

            local function closeList() list.Visible = false ; open = false ; tw(box, {BackgroundColor3 = Th.BG}, 0.1) end

            for index, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1,0,0,28)
                optBtn.BackgroundTransparency = 0.6
                optBtn.BackgroundColor3 = Th.Active
                optBtn.TextSize = 12
                optBtn.Font = Enum.Font.GothamBold
                optBtn.LayoutOrder = index
                optBtn.ZIndex = 202
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.Parent = listScroll
                do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,5) c.Parent = optBtn end
                local optS = Instance.new("UIStroke") optS.Color = Th.Accent optS.Thickness = 1.2 optS.Transparency = 1 optS.Parent = optBtn
                local optPad = Instance.new("UIPadding") optPad.PaddingLeft = UDim.new(0,6) optPad.Parent = optBtn
                optBtns[opt] = optBtn
                optStrokes[opt] = optS

                optBtn.MouseEnter:Connect(function()
                    if not selectedSet[opt] then tw(optBtn, {BackgroundTransparency=0.3}, 0.1) end
                end)
                optBtn.MouseLeave:Connect(function()
                    if not selectedSet[opt] then tw(optBtn, {BackgroundTransparency=0.6}, 0.1) end
                end)

                optBtn.MouseButton1Click:Connect(function()
                    selectedSet[opt] = not selectedSet[opt] or nil
                    refreshStyle()
                    if callback then
                        local arr = {}
                        for k in pairs(selectedSet) do table.insert(arr, k) end
                        pcall(callback, arr)
                    end
                end)
            end
            refreshStyle()

            box.MouseButton1Click:Connect(function()
                if open then closeList() return end
                if openDropdownClose then openDropdownClose() end
                tw(box, {BackgroundColor3 = Th.Active}, 0.1)
                listUIScale.Scale = uiScale.Scale
                local absPos = box.AbsolutePosition
                local listVisualW = 160 * uiScale.Scale
                local boxVisualW = box.AbsoluteSize.X
                list.Position = UDim2.new(0, absPos.X + boxVisualW - listVisualW, 0, absPos.Y + box.AbsoluteSize.Y + 4)
                list.Visible = true ; open = true
                openDropdownClose = closeList
            end)

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, subLbl = descLbl, box = box, boxStroke = boxStroke, boxLbl = boxLbl,
                refreshMulti = refreshStyle
            })

            local obj = {
                Get = function()
                    local arr = {}
                    for k in pairs(selectedSet) do table.insert(arr, k) end
                    return arr
                end,
                Set = function(_, list)
                    selectedSet = {}
                    for _, v in ipairs(list or {}) do selectedSet[v] = true end
                    refreshStyle()
                end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddInput(title, placeholder, callback)
            local row, stroke = newBox(42, title)
            local nameLbl, descLbl = injectText(row, title)

            local inputWrap = Instance.new("Frame")
            inputWrap.Size = UDim2.new(0, 120, 0, 26)
            inputWrap.AnchorPoint = Vector2.new(1, 0.5)
            inputWrap.Position = UDim2.new(1, 0, 0.5, 0)
            inputWrap.BackgroundColor3 = Th.BG
            inputWrap.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,4) c.Parent = inputWrap end
            local inputStroke = Instance.new("UIStroke") inputStroke.Color = Th.Border inputStroke.Parent = inputWrap

            local inputField = Instance.new("TextBox")
            inputField.Size = UDim2.new(1, -10, 1, 0)
            inputField.Position = UDim2.new(0, 5, 0, 0)
            inputField.BackgroundTransparency = 1
            inputField.Text = ""
            inputField.PlaceholderText = placeholder or "Enter..."
            inputField.PlaceholderColor3 = Th.Sub
            inputField.TextSize = 11
            inputField.TextColor3 = Th.Text
            inputField.Font = Enum.Font.Gotham
            inputField.ClearTextOnFocus = false
            inputField.Parent = inputWrap

            inputField.Focused:Connect(function() tw(inputWrap, {BackgroundColor3 = Th.Active}, 0.1) end)
            inputField.FocusLost:Connect(function()
                tw(inputWrap, {BackgroundColor3 = Th.BG}, 0.1)
                if callback then pcall(callback, inputField.Text) end
            end)

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, inputWrap = inputWrap, inputStroke = inputStroke, inputField = inputField
            })
        end

        function tabObj:AddKeybind(title, desc, defaultKey, callback, flag)
            local row, stroke = newBox(desc and 52 or 42, title)
            local nameLbl, descLbl = injectText(row, title, desc)
            local currentKey = defaultKey or Enum.KeyCode.RightAlt
            local listening = false

            local keybindBox = Instance.new("TextButton")
            keybindBox.Size = UDim2.new(0,84,0,26)
            keybindBox.AnchorPoint = Vector2.new(1,0.5)
            keybindBox.Position = UDim2.new(1,0,0.5,0)
            keybindBox.BackgroundColor3 = Th.BG
            keybindBox.Text = ""
            keybindBox.AutoButtonColor = false
            keybindBox.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,4) c.Parent = keybindBox end
            local keybindStroke = Instance.new("UIStroke") keybindStroke.Color = Th.Border keybindStroke.Parent = keybindBox

            local keybindLbl = Instance.new("TextLabel")
            keybindLbl.Size = UDim2.new(1,0,1,0)
            keybindLbl.BackgroundTransparency = 1
            keybindLbl.Text = currentKey.Name
            keybindLbl.TextSize = 11
            keybindLbl.TextColor3 = Th.Accent
            keybindLbl.Font = Enum.Font.GothamBold
            keybindLbl.Parent = keybindBox

            keybindBox.MouseButton1Click:Connect(function()
                listening = true
                keybindLbl.Text = "..."
                tw(keybindBox, {BackgroundColor3 = Th.Active}, 0.1)
            end)

            trackConn(UIS.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keybindLbl.Text = currentKey.Name
                    listening = false
                    tw(keybindBox, {BackgroundColor3 = Th.BG}, 0.1)
                    if callback then pcall(callback, currentKey) end
                end
            end))

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, subLbl = descLbl, keybindBox = keybindBox,
                keybindStroke = keybindStroke, keybindLbl = keybindLbl
            })
            local obj = {
                Get = function() return currentKey end,
                Set = function(_, key) currentKey = key keybindLbl.Text = currentKey.Name end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddColorPicker(title, desc, defaultColor, callback, flag)
            defaultColor = defaultColor or Color3.fromRGB(255,255,255)
            local row, stroke = newBox(desc and 52 or 42, title)
            local nameLbl, descLbl = injectText(row, title, desc)

            local colorPreview = Instance.new("TextButton")
            colorPreview.Size = UDim2.new(0,34,0,22)
            colorPreview.AnchorPoint = Vector2.new(1,0.5)
            colorPreview.Position = UDim2.new(1,0,0.5,0)
            colorPreview.BackgroundColor3 = defaultColor
            colorPreview.Text = ""
            colorPreview.AutoButtonColor = false
            colorPreview.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,4) c.Parent = colorPreview end
            local colorStroke = Instance.new("UIStroke") colorStroke.Color = Th.Border colorStroke.Parent = colorPreview

            local panel = Instance.new("Frame")
            panel.Size = UDim2.new(0,140,0,90)
            panel.BackgroundColor3 = Th.BG
            panel.Visible = false
            panel.ZIndex = 200
            panel.Parent = sg
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,6) c.Parent = panel end
            do local s = Instance.new("UIStroke") s.Color = Th.Border s.Parent = panel end
            local ppad = Instance.new("UIPadding") ppad.PaddingLeft=UDim.new(0,8) ppad.PaddingRight=UDim.new(0,8) ppad.PaddingTop=UDim.new(0,8) ppad.Parent = panel

            local r,g,b = defaultColor.R*255, defaultColor.G*255, defaultColor.B*255
            local sliders = {}
            local names = {"R","G","B"}
            local vals = {r,g,b}
            local open = false

            local function closePanel() panel.Visible = false open = false end

            for i, chan in ipairs(names) do
                local sRow = Instance.new("Frame")
                sRow.Size = UDim2.new(1,0,0,22)
                sRow.Position = UDim2.new(0,0,0,(i-1)*26)
                sRow.BackgroundTransparency = 1
                sRow.Parent = panel

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0,14,1,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = chan
                lbl.TextColor3 = Th.Sub
                lbl.TextSize = 10
                lbl.Font = Enum.Font.GothamBold
                lbl.Parent = sRow

                local track = Instance.new("Frame")
                track.Size = UDim2.new(1,-20,0,4)
                track.Position = UDim2.new(0,16,0.5,-2)
                track.BackgroundColor3 = Th.Border
                track.Parent = sRow
                do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = track end

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(vals[i]/255,0,1,0)
                fill.BackgroundColor3 = Color3.fromRGB(255,80,80)
                if chan == "G" then fill.BackgroundColor3 = Color3.fromRGB(80,255,80) end
                if chan == "B" then fill.BackgroundColor3 = Color3.fromRGB(80,140,255) end
                fill.Parent = track
                do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = fill end

                local dragging = false
                local function upd(x)
                    local rel = math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
                    vals[i] = rel*255
                    fill.Size = UDim2.new(rel,0,1,0)
                    local col = Color3.fromRGB(math.floor(vals[1]), math.floor(vals[2]), math.floor(vals[3]))
                    colorPreview.BackgroundColor3 = col
                    if callback then pcall(callback, col) end
                end
                track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = true upd(inp.Position.X)
                    end
                end)
                trackConn(UIS.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        upd(inp.Position.X)
                    end
                end))
                trackConn(UIS.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
                end))
            end

            colorPreview.MouseButton1Click:Connect(function()
                if open then closePanel() return end
                if openDropdownClose then openDropdownClose() end
                local absPos = colorPreview.AbsolutePosition
                panel.Position = UDim2.new(0, absPos.X - 110, 0, absPos.Y + 22)
                panel.Visible = true open = true
                openDropdownClose = closePanel
            end)

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, subLbl = descLbl, colorPreview = colorPreview, colorStroke = colorStroke
            })
            local obj = {
                Get = function() return colorPreview.BackgroundColor3 end,
                Set = function(_, col) colorPreview.BackgroundColor3 = col end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddProgressBar(title, initial)
            local row, stroke = newBox(50, title)
            local nameLbl = injectText(row, title)
            initial = math.clamp(initial or 0, 0, 100)

            local progressTrack = Instance.new("Frame")
            progressTrack.Size = UDim2.new(1,0,0,6)
            progressTrack.Position = UDim2.new(0,0,1,-12)
            progressTrack.BackgroundColor3 = Th.Border
            progressTrack.Parent = row
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = progressTrack end

            local progressFill = Instance.new("Frame")
            progressFill.Size = UDim2.new(initial/100,0,1,0)
            progressFill.BackgroundColor3 = Th.Accent
            progressFill.Parent = progressTrack
            do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = progressFill end

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, progressTrack = progressTrack, progressFill = progressFill
            })

            return {
                Set = function(_, pct)
                    pct = math.clamp(pct, 0, 100)
                    tw(progressFill, {Size = UDim2.new(pct/100,0,1,0)}, 0.2)
                end
            }
        end

        function tabObj:AddButton(text, callback)
            local btnRow, stroke = newBox(42, text)
            local btn2 = Instance.new("TextButton")
            btn2.Size = UDim2.new(1,0,1,0)
            btn2.BackgroundTransparency = 1
            btn2.Text = text
            btn2.TextSize = 12
            btn2.TextColor3 = Th.Text
            btn2.Font = Enum.Font.GothamBold
            btn2.AutoButtonColor = false
            btn2.Parent = btnRow

            btn2.MouseEnter:Connect(function() tw(btnRow, {BackgroundColor3 = Th.Active}, 0.1) end)
            btn2.MouseLeave:Connect(function() tw(btnRow, {BackgroundColor3 = Th.Card}, 0.1) end)

            btn2.MouseButton1Click:Connect(function()
                tw(btnRow, {BackgroundColor3 = Th.Accent, BackgroundTransparency = 0.6}, 0.06)
                task.delay(0.06, function() tw(btnRow, {BackgroundColor3 = Th.Card, BackgroundTransparency = cardTrans}, 0.12) end)
                if callback then pcall(callback) end
            end)

            table.insert(tabObj.elements, {
                row = btnRow, stroke = stroke, title = text, type = "card", btnText = btn2
            })
        end

        function tabObj:AddStatus(title, value)
            local row, stroke = newBox(42, title)
            local nameLbl, descLbl = injectText(row, title)
            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0,80,1,0)
            valLbl.AnchorPoint = Vector2.new(1,0)
            valLbl.Position = UDim2.new(1,0,0,0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(value)
            valLbl.TextSize = 11
            valLbl.TextColor3 = Th.Accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row

            table.insert(tabObj.elements, {
                row = row, stroke = stroke, title = title, type = "card",
                titleLbl = nameLbl, valLbl = valLbl
            })
            return { Set = function(_, v) valLbl.Text = tostring(v) end }
        end

        function tabObj:AddLabel(text)
            local row, stroke = newBox(34, text)
            row.BackgroundTransparency = 1
            stroke:Destroy()
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1,0,1,0)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextSize = 11
            l.TextColor3 = Th.Sub
            l.Font = Enum.Font.GothamBold
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = row

            table.insert(tabObj.elements, {
                row = row, title = text, type = "card", btnText = l
            })
        end

        return tabObj
    end

    return WindowAPI
end

return Library
