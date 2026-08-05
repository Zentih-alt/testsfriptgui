--[[
========================================================
 Solar.lua — Zenith Soul UI (V2 — โครงใหม่ทั้งหมด)
========================================================
เปลี่ยนโครงสร้างทั้งหมดจากเดิม (sidebar ซ้าย + list tab)
มาเป็น "แถบแท็บโค้งด้านบน" แบบหน้า Settings ของ Windows 11 / Groupy
ตามรูปที่อ้างอิง — ไม่มีโครงเก่าหลงเหลือ

วิธีใช้:
    local Solar = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Zentih-alt/Zentih-Soul-hub/refs/heads/main/Solar.lua"
    ))()

    local Window = Solar.CreateWindow({
        Title = "Zenith Soul",
        Subtitle = "HUB",
        Icon = "rbxassetid://0",
    })

    local Tab = Window.AddTab("Main")
    Tab:AddToggle("เปิดออโต้ฟาร์ม", "รายละเอียด", function(state) end)
    Tab:AddButton("กดฉัน", function() end)
    Tab:AddSegmented("โหมด", {"A","B","C","D"}, "A", function(choice) end)
========================================================
]]

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local function tw(obj, props, t, style, dir)
    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = inst
    return c
end

local function stroke(inst, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = inst
    return s
end

local function hasIcon(id)
    if not id or id == "" then return false end
    local n = tostring(id):match("rbxassetid://(%d+)")
    if n and tonumber(n) == 0 then return false end
    return true
end

local Th = {
    BG        = Color3.fromRGB(246, 246, 249),
    TabBarBG  = Color3.fromRGB(236, 236, 241),
    Card      = Color3.fromRGB(255, 255, 255),
    Border    = Color3.fromRGB(226, 226, 232),
    Text      = Color3.fromRGB(28, 28, 32),
    Sub       = Color3.fromRGB(112, 112, 124),
    Accent    = Color3.fromRGB(0, 103, 224),
    AccentBg  = Color3.fromRGB(222, 235, 253),
    TabActive = Color3.fromRGB(255, 255, 255),
    Shadow    = Color3.fromRGB(0, 0, 0),
}

local Library = {}

function Library.CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "Zenith Soul"
    local SubText = config.Subtitle or "HUB"
    local ProfileIcon = config.Icon

    local old = game:GetService("CoreGui"):FindFirstChild("ZenithSoul_V2")
        or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ZenithSoul_V2")
    if old then old:Destroy() end
    if _G.__ZenithSoul_Conns then
        for _, c in ipairs(_G.__ZenithSoul_Conns) do pcall(function() c:Disconnect() end) end
    end
    _G.__ZenithSoul_Conns = {}
    local function track(c) table.insert(_G.__ZenithSoul_Conns, c) return c end

    local sg = Instance.new("ScreenGui")
    sg.Name = "ZenithSoul_V2"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local WIN_W, WIN_H = 640, 480
    local openDropdownClose = nil
    local currentTab = nil

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    main.BackgroundColor3 = Th.BG
    main.ClipsDescendants = true
    main.Active = true
    main.Parent = sg
    corner(main, 18)
    stroke(main, Th.Border, 1)

    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Size = UDim2.new(1, 70, 1, 70)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Th.Shadow
    shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = -1
    shadow.Parent = main

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = main
    local function applyScale()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
        if not vp then return end
        local fit = math.min((vp.X - 30) / WIN_W, (vp.Y - 30) / WIN_H)
        uiScale.Scale = math.clamp(fit, 0.55, 1)
    end
    applyScale()
    if workspace.CurrentCamera then
        track(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale))
    end

    local headerBar = Instance.new("Frame")
    headerBar.Size = UDim2.new(1, 0, 0, 46)
    headerBar.BackgroundTransparency = 1
    headerBar.Parent = main
    headerBar.Active = true

    local profileIcon = Instance.new("ImageLabel")
    profileIcon.Size = UDim2.new(0, 28, 0, 28)
    profileIcon.Position = UDim2.new(0, 16, 0, 9)
    profileIcon.BackgroundColor3 = Th.AccentBg
    profileIcon.Image = hasIcon(ProfileIcon) and ProfileIcon or ""
    profileIcon.Visible = hasIcon(ProfileIcon)
    profileIcon.ScaleType = Enum.ScaleType.Crop
    profileIcon.Parent = headerBar
    corner(profileIcon, 9)

    local titleOffset = profileIcon.Visible and 54 or 16
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 0, 16)
    titleLbl.Position = UDim2.new(0, titleOffset, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = TitleText
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = Th.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBar

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(0.5, 0, 0, 12)
    subLbl.Position = UDim2.new(0, titleOffset, 0, 24)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = SubText
    subLbl.TextSize = 11
    subLbl.TextColor3 = Th.Sub
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.Parent = headerBar

    local closeDot = Instance.new("TextButton")
    closeDot.Size = UDim2.new(0, 26, 0, 26)
    closeDot.AnchorPoint = Vector2.new(1, 0)
    closeDot.Position = UDim2.new(1, -12, 0, 10)
    closeDot.BackgroundColor3 = Th.Card
    closeDot.Text = "×"
    closeDot.TextSize = 16
    closeDot.TextColor3 = Th.Sub
    closeDot.Font = Enum.Font.GothamBold
    closeDot.AutoButtonColor = false
    closeDot.Parent = headerBar
    corner(closeDot, 13)
    stroke(closeDot, Th.Border, 1)

    local tabBarWrap = Instance.new("Frame")
    tabBarWrap.Size = UDim2.new(1, -24, 0, 40)
    tabBarWrap.Position = UDim2.new(0, 12, 0, 48)
    tabBarWrap.BackgroundColor3 = Th.TabBarBG
    tabBarWrap.Parent = main
    corner(tabBarWrap, 14)

    local tabBarScroll = Instance.new("ScrollingFrame")
    tabBarScroll.Size = UDim2.new(1, -8, 1, -8)
    tabBarScroll.Position = UDim2.new(0, 4, 0, 4)
    tabBarScroll.BackgroundTransparency = 1
    tabBarScroll.BorderSizePixel = 0
    tabBarScroll.ScrollBarThickness = 0
    tabBarScroll.ScrollingDirection = Enum.ScrollingDirection.X
    tabBarScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabBarScroll.CanvasSize = UDim2.new(0,0,0,0)
    tabBarScroll.Parent = tabBarWrap

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding = UDim.new(0, 4)
    tabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabBarLayout.Parent = tabBarScroll

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -24, 1, -104)
    contentArea.Position = UDim2.new(0, 12, 0, 96)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true
    contentArea.Parent = main

    local dragging, dragStart, startPos
    local function beginDrag(input)
        if openDropdownClose then openDropdownClose() openDropdownClose = nil end
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
    headerBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then beginDrag(i) end
    end)
    tabBarWrap.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then beginDrag(i) end
    end)
    track(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))

    local uiVisible = true
    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 46, 0, 46)
    floatBtn.Position = UDim2.new(0, 20, 0.5, -23)
    floatBtn.BackgroundColor3 = Th.Card
    floatBtn.Text = "☰"
    floatBtn.TextSize = 18
    floatBtn.TextColor3 = Th.Accent
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.AutoButtonColor = false
    floatBtn.ZIndex = 500
    floatBtn.Parent = sg
    corner(floatBtn, 15)
    stroke(floatBtn, Th.Border, 1)

    local function toggleUI()
        uiVisible = not uiVisible
        if uiVisible then
            main.Visible = true
            main.Size = UDim2.new(0, 0, 0, 0)
            tw(main, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.18)
        else
            tw(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.16, function() main.Visible = false end)
        end
        if openDropdownClose then openDropdownClose() openDropdownClose = nil end
    end
    closeDot.MouseButton1Click:Connect(toggleUI)
    floatBtn.MouseButton1Click:Connect(toggleUI)
    track(UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Enum.KeyCode.RightShift then toggleUI() end
    end))

    local WindowAPI = {}
    WindowAPI.Flags = {}
    local tabList = {}

    function WindowAPI.Notify(p)
        p = p or {}
        local box = Instance.new("Frame")
        box.AnchorPoint = Vector2.new(1, 1)
        box.Position = UDim2.new(1, -14, 1, -14)
        box.Size = UDim2.new(0, 240, 0, 0)
        box.BackgroundColor3 = Th.Card
        box.ClipsDescendants = true
        box.ZIndex = 999
        box.Parent = sg
        corner(box, 12)
        stroke(box, Th.Accent, 1, 0.5)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -20, 0, 16)
        t.Position = UDim2.new(0, 10, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = p.Title or "Notification"
        t.TextSize = 12
        t.TextColor3 = Th.Accent
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = box
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -20, 0, 24)
        d.Position = UDim2.new(0, 10, 0, 24)
        d.BackgroundTransparency = 1
        d.Text = p.Description or ""
        d.TextSize = 11
        d.TextColor3 = Th.Sub
        d.TextWrapped = true
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = box
        tw(box, {Size = UDim2.new(0, 240, 0, 56)}, 0.22, Enum.EasingStyle.Back)
        task.delay(p.Duration or 3, function()
            if not box.Parent then return end
            tw(box, {Size = UDim2.new(0, 240, 0, 0)}, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.wait(0.16)
            box:Destroy()
        end)
    end

    function WindowAPI.Destroy() sg:Destroy() end

    local function selectTab(tabObj)
        if openDropdownClose then openDropdownClose() openDropdownClose = nil end
        currentTab = tabObj
        for _, t in ipairs(tabList) do
            tw(t.pill, {BackgroundColor3 = Th.TabBarBG}, 0.14)
            t.label.TextColor3 = Th.Sub
            t.scroll.Visible = false
        end
        tw(tabObj.pill, {BackgroundColor3 = Th.TabActive}, 0.14)
        tabObj.label.TextColor3 = Th.Accent
        tabObj.scroll.Visible = true
    end

    function WindowAPI.AddTab(name)
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, math.max(70, #name * 8 + 34), 1, 0)
        pill.BackgroundColor3 = Th.TabBarBG
        pill.AutoButtonColor = false
        pill.Text = ""
        pill.LayoutOrder = #tabList + 1
        pill.Parent = tabBarScroll
        corner(pill, 11)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextSize = 13
        label.TextColor3 = Th.Sub
        label.Font = Enum.Font.GothamBold
        label.Parent = pill

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = Th.Border
        scroll.Visible = false
        scroll.Parent = contentArea

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = scroll
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        local tabObj = { pill = pill, label = label, scroll = scroll, layout = layout, order = 0, elements = {} }
        local function nextOrder() tabObj.order = tabObj.order + 1 return tabObj.order end

        pill.MouseButton1Click:Connect(function() selectTab(tabObj) end)
        pill.MouseEnter:Connect(function() if currentTab ~= tabObj then tw(pill, {BackgroundColor3 = Color3.fromRGB(228,228,235)}, 0.1) end end)
        pill.MouseLeave:Connect(function() if currentTab ~= tabObj then tw(pill, {BackgroundColor3 = Th.TabBarBG}, 0.1) end end)

        table.insert(tabList, tabObj)
        if #tabList == 1 then selectTab(tabObj) end

        local function newCard(height)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, height or 60)
            row.BackgroundColor3 = Th.Card
            row.LayoutOrder = nextOrder()
            row.Parent = scroll
            corner(row, 14)
            stroke(row, Th.Border, 1)
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 16)
            pad.PaddingRight = UDim.new(0, 16)
            pad.Parent = row
            return row
        end

        local function textBlock(row, title, desc)
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -140, 0, desc and 16 or 0)
            nameLbl.Position = UDim2.new(0, 0, desc and 0.5 or 0, desc and -16 or 0)
            if not desc then nameLbl.Size = UDim2.new(1, -140, 1, 0) end
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = title
            nameLbl.TextSize = 14
            nameLbl.TextColor3 = Th.Text
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.Parent = row

            if desc then
                local descLbl = Instance.new("TextLabel")
                descLbl.Size = UDim2.new(1, -140, 0, 14)
                descLbl.Position = UDim2.new(0, 0, 0.5, 2)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.TextSize = 11
                descLbl.TextColor3 = Th.Sub
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.TextWrapped = true
                descLbl.Parent = row
            end
        end

        function tabObj:AddSection(title)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 24)
            row.BackgroundTransparency = 1
            row.LayoutOrder = nextOrder()
            row.Parent = scroll
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, 0, 1, 0)
            t.Position = UDim2.new(0, 2, 0, 0)
            t.BackgroundTransparency = 1
            t.Text = title
            t.TextSize = 13
            t.TextColor3 = Th.Sub
            t.Font = Enum.Font.GothamBold
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = row
        end

        function tabObj:AddToggle(title, desc, callback, flag)
            local row = newCard(desc and 64 or 52)
            textBlock(row, title, desc)
            local state = false

            local sw = Instance.new("Frame")
            sw.Size = UDim2.new(0, 44, 0, 24)
            sw.AnchorPoint = Vector2.new(1, 0.5)
            sw.Position = UDim2.new(1, 0, 0.5, 0)
            sw.BackgroundColor3 = Color3.fromRGB(210, 210, 218)
            sw.Parent = row
            corner(sw, 12)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.Position = UDim2.new(0, 3, 0.5, -9)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.Parent = sw
            corner(knob, 9)

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.Parent = row

            local function render()
                if state then
                    tw(sw, {BackgroundColor3 = Th.Accent}, 0.14)
                    tw(knob, {Position = UDim2.new(1, -21, 0.5, -9)}, 0.14)
                else
                    tw(sw, {BackgroundColor3 = Color3.fromRGB(210,210,218)}, 0.14)
                    tw(knob, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.14)
                end
            end

            hit.MouseButton1Click:Connect(function()
                state = not state
                render()
                if callback then pcall(callback, state) end
            end)

            local obj = {
                Set = function(_, v) state = v render() if callback then pcall(callback, state) end end,
                Get = function() return state end,
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddButton(text, callback)
            local row = newCard(48)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextSize = 13
            lbl.TextColor3 = Th.Accent
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row
            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.Parent = row
            hit.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = Th.AccentBg}, 0.1) end)
            hit.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = Th.Card}, 0.1) end)
            hit.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
        end

        function tabObj:AddLabel(text)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 26)
            row.BackgroundTransparency = 1
            row.LayoutOrder = nextOrder()
            row.Parent = scroll
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextSize = 12
            l.TextColor3 = Th.Sub
            l.Font = Enum.Font.Gotham
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = row
        end

        function tabObj:AddStatus(title, value)
            local row = newCard(52)
            textBlock(row, title)
            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 100, 1, 0)
            valLbl.AnchorPoint = Vector2.new(1, 0)
            valLbl.Position = UDim2.new(1, 0, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(value)
            valLbl.TextSize = 12
            valLbl.TextColor3 = Th.Accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row
            return { Set = function(_, v) valLbl.Text = tostring(v) end }
        end

        function tabObj:AddSegmented(title, options, default, callback, flag)
            tabObj:AddSection(title)
            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, 0, 0, 64)
            wrap.BackgroundTransparency = 1
            wrap.LayoutOrder = nextOrder()
            wrap.Parent = scroll

            local grid = Instance.new("UIListLayout")
            grid.FillDirection = Enum.FillDirection.Horizontal
            grid.Padding = UDim.new(0, 8)
            grid.Parent = wrap

            local selected = default or options[1]
            local cards = {}
            for _, opt in ipairs(options) do
                local w = (1 / #options)
                local card = Instance.new("TextButton")
                card.Size = UDim2.new(w, -6, 1, 0)
                card.BackgroundColor3 = Th.Card
                card.AutoButtonColor = false
                card.Text = ""
                card.Parent = wrap
                corner(card, 12)
                local cs = stroke(card, opt == selected and Th.Accent or Th.Border, opt == selected and 2 or 1)

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -8, 1, 0)
                lbl.Position = UDim2.new(0, 4, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = opt
                lbl.TextSize = 12
                lbl.TextWrapped = true
                lbl.TextColor3 = opt == selected and Th.Accent or Th.Sub
                lbl.Font = Enum.Font.GothamBold
                lbl.Parent = card

                cards[opt] = {card = card, stroke = cs, lbl = lbl}

                card.MouseButton1Click:Connect(function()
                    selected = opt
                    for o, c in pairs(cards) do
                        local isSel = o == selected
                        c.stroke.Color = isSel and Th.Accent or Th.Border
                        c.stroke.Thickness = isSel and 2 or 1
                        c.lbl.TextColor3 = isSel and Th.Accent or Th.Sub
                    end
                    if callback then pcall(callback, selected) end
                end)
            end

            local obj = {
                Get = function() return selected end,
                Set = function(_, v)
                    selected = v
                    for o, c in pairs(cards) do
                        local isSel = o == selected
                        c.stroke.Color = isSel and Th.Accent or Th.Border
                        c.stroke.Thickness = isSel and 2 or 1
                        c.lbl.TextColor3 = isSel and Th.Accent or Th.Sub
                    end
                end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddDropdown(title, desc, options, default, callback, flag)
            local row = newCard(desc and 64 or 52)
            textBlock(row, title, desc)
            local selected = default or options[1] or "None"
            local open = false

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0, 120, 0, 30)
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.Position = UDim2.new(1, 0, 0.5, 0)
            box.BackgroundColor3 = Th.AccentBg
            box.Text = ""
            box.AutoButtonColor = false
            box.Parent = row
            corner(box, 9)

            local boxLbl = Instance.new("TextLabel")
            boxLbl.Size = UDim2.new(1, -10, 1, 0)
            boxLbl.Position = UDim2.new(0, 5, 0, 0)
            boxLbl.BackgroundTransparency = 1
            boxLbl.Text = tostring(selected)
            boxLbl.TextSize = 12
            boxLbl.TextColor3 = Th.Accent
            boxLbl.Font = Enum.Font.GothamBold
            boxLbl.TextTruncate = Enum.TextTruncate.AtEnd
            boxLbl.Parent = box

            local list = Instance.new("Frame")
            list.Size = UDim2.new(0, 140, 0, math.min(#options, 6) * 30 + 8)
            list.BackgroundColor3 = Th.Card
            list.Visible = false
            list.ZIndex = 300
            list.Parent = sg
            corner(list, 12)
            stroke(list, Th.Border, 1)

            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 2)
            listLayout.Parent = list
            local listPad = Instance.new("UIPadding")
            listPad.PaddingLeft = UDim.new(0, 4) listPad.PaddingRight = UDim.new(0, 4)
            listPad.PaddingTop = UDim.new(0, 4) listPad.PaddingBottom = UDim.new(0, 4)
            listPad.Parent = list

            local function closeList() list.Visible = false open = false end

            for _, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, 0, 0, 28)
                ob.BackgroundTransparency = 1
                ob.Text = tostring(opt)
                ob.TextSize = 12
                ob.TextColor3 = Th.Text
                ob.Font = Enum.Font.Gotham
                ob.Parent = list
                corner(ob, 8)
                ob.MouseEnter:Connect(function() ob.BackgroundColor3 = Th.AccentBg tw(ob, {BackgroundTransparency = 0}, 0.1) end)
                ob.MouseLeave:Connect(function() tw(ob, {BackgroundTransparency = 1}, 0.1) end)
                ob.MouseButton1Click:Connect(function()
                    selected = opt
                    boxLbl.Text = tostring(opt)
                    closeList()
                    if callback then pcall(callback, opt) end
                end)
            end

            box.MouseButton1Click:Connect(function()
                if open then closeList() return end
                if openDropdownClose then openDropdownClose() end
                local pos = box.AbsolutePosition
                list.Position = UDim2.new(0, pos.X + box.AbsoluteSize.X - 140, 0, pos.Y + box.AbsoluteSize.Y + 6)
                list.Visible = true open = true
                openDropdownClose = closeList
            end)

            local obj = {
                Get = function() return selected end,
                Set = function(_, v) selected = v boxLbl.Text = tostring(v) end,
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        function tabObj:AddSlider(title, min, max, default, callback, flag)
            min, max = min or 0, max or 100
            local value = math.clamp(default or min, min, max)
            local row = newCard(64)
            textBlock(row, title)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 40, 0, 14)
            valLbl.AnchorPoint = Vector2.new(1, 0)
            valLbl.Position = UDim2.new(1, 0, 0, 4)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(value)
            valLbl.TextSize = 11
            valLbl.TextColor3 = Th.Accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row

            local track_ = Instance.new("Frame")
            track_.Size = UDim2.new(1, 0, 0, 6)
            track_.Position = UDim2.new(0, 0, 1, -14)
            track_.BackgroundColor3 = Color3.fromRGB(224, 224, 230)
            track_.Parent = row
            corner(track_, 3)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Th.Accent
            fill.Parent = track_
            corner(fill, 3)

            local hitBar = Instance.new("Frame")
            hitBar.Size = UDim2.new(1, 0, 0, 26)
            hitBar.Position = UDim2.new(0, 0, 1, -26)
            hitBar.BackgroundTransparency = 1
            hitBar.Parent = row

            local dragging_ = false
            local function upd(x)
                local rel = math.clamp((x - track_.AbsolutePosition.X) / math.max(track_.AbsoluteSize.X, 1), 0, 1)
                value = math.floor(min + rel * (max - min))
                tw(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.06)
                valLbl.Text = tostring(value)
                if callback then pcall(callback, value) end
            end
            hitBar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging_ = true upd(i.Position.X)
                end
            end)
            track(UIS.InputChanged:Connect(function(i)
                if dragging_ and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
            end))
            track(UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging_ = false end
            end))

            local obj = {
                Get = function() return value end,
                Set = function(_, v)
                    value = math.clamp(v, min, max)
                    tw(fill, {Size = UDim2.new((value-min)/(max-min), 0, 1, 0)}, 0.1)
                    valLbl.Text = tostring(value)
                end
            }
            if flag then WindowAPI.Flags[flag] = obj end
            return obj
        end

        return tabObj
    end

    return WindowAPI
end

return Library
