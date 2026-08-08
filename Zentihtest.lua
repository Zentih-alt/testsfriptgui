--[[
    Fluent Interface Suite (Full Source Code)
    Original Author: dawid
    License: MIT
    GitHub: https://github.com/dawid-scripts/Fluent
--]]

local modulesData, getModule = {
    {1, 'ModuleScript', {'MainModule'}, {
        {18, 'ModuleScript', {'Creator'}},
        {28, 'ModuleScript', {'Icons'}},
        {47, 'ModuleScript', {'Themes'}, {
            {50, 'ModuleScript', {'Dark'}},
            {52, 'ModuleScript', {'Light'}},
            {51, 'ModuleScript', {'Darker'}},
            {53, 'ModuleScript', {'Rose'}},
            {49, 'ModuleScript', {'Aqua'}},
            {48, 'ModuleScript', {'Amethyst'}}
        }},
        {19, 'ModuleScript', {'Elements'}, {
            {21, 'ModuleScript', {'Colorpicker'}},
            {27, 'ModuleScript', {'Toggle'}},
            {23, 'ModuleScript', {'Input'}},
            {20, 'ModuleScript', {'Button'}},
            {25, 'ModuleScript', {'Paragraph'}},
            {22, 'ModuleScript', {'Dropdown'}},
            {26, 'ModuleScript', {'Slider'}},
            {24, 'ModuleScript', {'Keybind'}}
        }},
        {29, 'Folder', {'Packages'}, {
            {30, 'ModuleScript', {'Flipper'}, {
                {33, 'ModuleScript', {'GroupMotor'}},
                {46, 'ModuleScript', {'isMotor.spec'}},
                {39, 'ModuleScript', {'Signal'}},
                {40, 'ModuleScript', {'Signal.spec'}},
                {45, 'ModuleScript', {'isMotor'}},
                {36, 'ModuleScript', {'Instant.spec'}},
                {44, 'ModuleScript', {'Spring.spec'}},
                {42, 'ModuleScript', {'SingleMotor.spec'}},
                {38, 'ModuleScript', {'Linear.spec'}},
                {31, 'ModuleScript', {'BaseMotor'}},
                {43, 'ModuleScript', {'Spring'}},
                {35, 'ModuleScript', {'Instant'}},
                {37, 'ModuleScript', {'Linear'}},
                {41, 'ModuleScript', {'SingleMotor'}},
                {34, 'ModuleScript', {'GroupMotor.spec'}},
                {32, 'ModuleScript', {'BaseMotor.spec'}}
            }}
        }}
    }},
    {2, 'ModuleScript', {'Acrylic'}, {
        {3, 'ModuleScript', {'AcrylicBlur'}},
        {5, 'ModuleScript', {'CreateAcrylic'}},
        {6, 'ModuleScript', {'Utils'}},
        {4, 'ModuleScript', {'AcrylicPaint'}}
    }},
    {7, 'Folder', {'Components'}, {
        {9, 'ModuleScript', {'Button'}},
        {12, 'ModuleScript', {'Notification'}},
        {13, 'ModuleScript', {'Section'}},
        {17, 'ModuleScript', {'Window'}},
        {14, 'ModuleScript', {'Tab'}},
        {10, 'ModuleScript', {'Dialog'}},
        {8, 'ModuleScript', {'Assets'}},
        {16, 'ModuleScript', {'TitleBar'}},
        {15, 'ModuleScript', {'Textbox'}},
        {11, 'ModuleScript', {'Element'}}
    }}
}

local moduleFunctions = {
    [1] = function()
        local env, scriptObj, requireFunc = getModule(1)
        local Lighting = game:GetService("Lighting")
        local RunService = game:GetService("RunService")
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local UserInputService = game:GetService("UserInputService")
        local TweenService = game:GetService("TweenService")
        local Camera = game:GetService("Workspace").CurrentCamera

        local Creator = requireFunc(scriptObj.Creator)
        local Elements = requireFunc(scriptObj.Elements)
        local Acrylic = requireFunc(scriptObj.Acrylic)
        local Components = scriptObj.Components

        local Notification = requireFunc(Components.Notification)
        local createInstance = Creator.New
        local protectGuiFunc = protectgui or (syn and syn.protect_gui) or function() end

        local ScreenGui = createInstance("ScreenGui", {
            Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")
        })
        protectGuiFunc(ScreenGui)
        Notification:Init(ScreenGui)

        local Fluent = {
            Version = "1.1.0",
            OpenFrames = {},
            Options = {},
            Themes = requireFunc(scriptObj.Themes).Names,
            Window = nil,
            WindowFrame = nil,
            Unloaded = false,
            Theme = "Dark",
            DialogOpen = false,
            UseAcrylic = false,
            Acrylic = false,
            Transparency = true,
            MinimizeKeybind = nil,
            MinimizeKey = Enum.KeyCode.LeftControl,
            GUI = ScreenGui
        }

        function Fluent:SafeCallback(func, ...)
            if not func then return end
            local success, err = pcall(func, ...)
            if not success then
                local _, pos = err:find(":%d+: ")
                if not pos then
                    return Fluent:Notify({ Title = "Interface", Content = "Callback error", SubContent = err, Duration = 5 })
                end
                return Fluent:Notify({ Title = "Interface", Content = "Callback error", SubContent = err:sub(pos + 1), Duration = 5 })
            end
        end

        function Fluent:Round(val, decimals)
            if decimals == 0 then return math.floor(val) end
            local str = tostring(val)
            return str:find("%.") and tonumber(str:sub(1, str:find("%.") + decimals)) or str
        end

        local iconAssets = requireFunc(scriptObj.Icons).assets
        function Fluent:GetIcon(iconName)
            if iconName ~= nil and iconAssets["lucide-" .. iconName] then
                return iconAssets["lucide-" .. iconName]
            end
            return nil
        end

        local ElementsClass = {}
        ElementsClass.__index = ElementsClass
        ElementsClass.__namecall = function(tbl, key, ...)
            return ElementsClass[key](...)
        end

        for _, elem in ipairs(Elements) do
            ElementsClass["Add" .. elem.__type] = function(self, name, config)
                elem.Container = self.Container
                elem.Type = self.Type
                elem.ScrollFrame = self.ScrollFrame
                elem.Library = Fluent
                return elem:New(name, config)
            end
        end
        Fluent.Elements = ElementsClass

        function Fluent:CreateWindow(config)
            assert(config.Title, "Window - Missing Title")
            if Fluent.Window then
                print("You cannot create more than one window.")
                return
            end
            Fluent.MinimizeKey = config.MinimizeKey
            Fluent.UseAcrylic = config.Acrylic
            if config.Acrylic then Acrylic.init() end

            local windowObj = requireFunc(Components.Window)({
                Parent = ScreenGui,
                Size = config.Size,
                Title = config.Title,
                SubTitle = config.SubTitle,
                TabWidth = config.TabWidth
            })
            Fluent.Window = windowObj
            Fluent:SetTheme(config.Theme)
            return windowObj
        end

        function Fluent:SetTheme(themeName)
            if Fluent.Window and table.find(Fluent.Themes, themeName) then
                Fluent.Theme = themeName
                Creator.UpdateTheme()
            end
        end

        function Fluent:Destroy()
            if Fluent.Window then
                Fluent.Unloaded = true
                if Fluent.UseAcrylic then
                    Fluent.Window.AcrylicPaint.Model:Destroy()
                end
                Creator.Disconnect()
                Fluent.GUI:Destroy()
            end
        end

        function Fluent:ToggleAcrylic(enabled)
            if Fluent.Window and Fluent.UseAcrylic then
                Fluent.Acrylic = enabled
                Fluent.Window.AcrylicPaint.Model.Transparency = enabled and 0.98 or 1
                if enabled then Acrylic.Enable() else Acrylic.Disable() end
            end
        end

        function Fluent:ToggleTransparency(enabled)
            if Fluent.Window then
                Fluent.Window.AcrylicPaint.Frame.Background.BackgroundTransparency = enabled and 0.35 or 0
            end
        end

        function Fluent:Notify(config)
            return Notification:New(config)
        end

        if getgenv then
            getgenv().Fluent = Fluent
        end
        return Fluent
    end,

    [2] = function()
        local env, scriptObj, requireFunc = getModule(2)
        local AcrylicBlur = requireFunc(scriptObj.AcrylicBlur)
        local CreateAcrylic = requireFunc(scriptObj.CreateAcrylic)
        local AcrylicPaint = requireFunc(scriptObj.AcrylicPaint)

        local Acrylic = {
            AcrylicBlur = AcrylicBlur,
            CreateAcrylic = CreateAcrylic,
            AcrylicPaint = AcrylicPaint
        }

        function Acrylic.init()
            local dof = Instance.new("DepthOfFieldEffect")
            dof.FarIntensity = 0
            dof.InFocusRadius = 0.1
            dof.NearIntensity = 1
            local savedStates = {}

            function Acrylic.Enable()
                for k, v in pairs(savedStates) do v.Enabled = false end
                dof.Parent = game:GetService("Lighting")
            end

            function Acrylic.Disable()
                for k, v in pairs(savedStates) do v.Enabled = v.enabled end
                dof.Parent = nil
            end

            local function registerEffects()
                local check = function(child)
                    if child:IsA("DepthOfFieldEffect") then
                        savedStates[child] = { enabled = child.Enabled }
                    end
                end
                for _, v in pairs(game:GetService("Lighting"):GetChildren()) do check(v) end
                if game:GetService("Workspace").CurrentCamera then
                    for _, v in pairs(game:GetService("Workspace").CurrentCamera:GetChildren()) do check(v) end
                end
            end
            registerEffects()
            Acrylic.Enable()
        end
        return Acrylic
    end,

    [3] = function()
        local env, scriptObj, requireFunc = getModule(3)
        local Creator = requireFunc(scriptObj.Parent.Parent.Creator)
        local CreateAcrylic = requireFunc(scriptObj.Parent.CreateAcrylic)
        local Utils = requireFunc(scriptObj.Parent.Utils)
        local screenToRay, getOffset = Utils[1], Utils[2]

        local function setupBlur(dist)
            local connections = {}
            dist = dist or 0.001
            local posData = { topLeft = Vector2.new(), topRight = Vector2.new(), bottomRight = Vector2.new() }
            local acrylicPart = CreateAcrylic()
            acrylicPart.Parent = workspace

            local setPos = function(size, pos)
                posData.topLeft = pos
                posData.topRight = pos + Vector2.new(size.X, 0)
                posData.bottomRight = pos + size
            end

            local updateMesh = function()
                local cam = game:GetService("Workspace").CurrentCamera
                local cf = cam and cam.CFrame or CFrame.new()
                local p1 = screenToRay(posData.topLeft, dist)
                local p2 = screenToRay(posData.topRight, dist)
                local p3 = screenToRay(posData.bottomRight, dist)
                local w = (p2 - p1).Magnitude
                local h = (p2 - p3).Magnitude
                acrylicPart.CFrame = CFrame.fromMatrix((p1 + p3) / 2, cf.XVector, cf.YVector, cf.ZVector)
                acrylicPart.Mesh.Scale = Vector3.new(w, h, 0)
            end

            local updatePos = function(frame)
                local offset = getOffset()
                local sz = frame.AbsoluteSize - Vector2.new(offset, offset)
                local ps = frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
                setPos(sz, ps)
                task.spawn(updateMesh)
            end

            local bindEvents = function()
                local cam = game:GetService("Workspace").CurrentCamera
                if not cam then return end
                table.insert(connections, cam:GetPropertyChangedSignal("CFrame"):Connect(updateMesh))
                table.insert(connections, cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateMesh))
                table.insert(connections, cam:GetPropertyChangedSignal("FieldOfView"):Connect(updateMesh))
                task.spawn(updateMesh)
            end

            acrylicPart.Destroying:Connect(function()
                for _, conn in connections do pcall(function() conn:Disconnect() end) end
            end)
            bindEvents()
            return updatePos, acrylicPart
        end

        return function(distance)
            local blurObj = {}
            local updatePos, acrylicPart = setupBlur(distance)
            local frame = Creator.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })

            Creator.AddSignal(frame:GetPropertyChangedSignal("AbsolutePosition"), function() updatePos(frame) end)
            Creator.AddSignal(frame:GetPropertyChangedSignal("AbsoluteSize"), function() updatePos(frame) end)

            blurObj.AddParent = function(parent)
                Creator.AddSignal(parent:GetPropertyChangedSignal("Visible"), function()
                    blurObj.SetVisibility(parent.Visible)
                end)
            end
            blurObj.SetVisibility = function(visible)
                acrylicPart.Transparency = visible and 0.98 or 1
            end
            blurObj.Frame = frame
            blurObj.Model = acrylicPart
            return blurObj
        end
    end,

    [4] = function()
        local env, scriptObj, requireFunc = getModule(4)
        local Creator = requireFunc(scriptObj.Parent.Parent.Creator)
        local AcrylicBlur = requireFunc(scriptObj.Parent.AcrylicBlur)
        local newInst = Creator.New

        return function()
            local paint = {}
            paint.Frame = newInst("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 0.9,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0
            }, {
                newInst("ImageLabel", {
                    Image = "rbxassetid://8992230677",
                    ScaleType = "Slice",
                    SliceCenter = Rect.new(Vector2.new(99, 99), Vector2.new(99, 99)),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.new(1, 120, 1, 116),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    BackgroundTransparency = 1,
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    ImageTransparency = 0.7
                }),
                newInst("UICorner", { CornerRadius = UDim.new(0, 8) }),
                newInst("Frame", {
                    BackgroundTransparency = 0.45,
                    Size = UDim2.fromScale(1, 1),
                    Name = "Background",
                    ThemeTag = { BackgroundColor3 = "AcrylicMain" }
                }, { newInst("UICorner", { CornerRadius = UDim.new(0, 8) }) }),
                newInst("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.4,
                    Size = UDim2.fromScale(1, 1)
                }, {
                    newInst("UICorner", { CornerRadius = UDim.new(0, 8) }),
                    newInst("UIGradient", { Rotation = 90, ThemeTag = { Color = "AcrylicGradient" } })
                }),
                newInst("ImageLabel", {
                    Image = "rbxassetid://9968344105",
                    ImageTransparency = 0.98,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 128, 0, 128),
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1
                }, { newInst("UICorner", { CornerRadius = UDim.new(0, 8) }) }),
                newInst("ImageLabel", {
                    Image = "rbxassetid://9968344227",
                    ImageTransparency = 0.9,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 128, 0, 128),
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    ThemeTag = { ImageTransparency = "AcrylicNoise" }
                }, { newInst("UICorner", { CornerRadius = UDim.new(0, 8) }) }),
                newInst("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 2
                }, {
                    newInst("UICorner", { CornerRadius = UDim.new(0, 8) }),
                    newInst("UIStroke", { Transparency = 0.5, Thickness = 1, ThemeTag = { Color = "AcrylicBorder" } })
                })
            })

            if requireFunc(scriptObj.Parent.Parent).UseAcrylic then
                local blur = AcrylicBlur()
                blur.Frame.Parent = paint.Frame
                paint.Model = blur.Model
                paint.AddParent = blur.AddParent
                paint.SetVisibility = blur.SetVisibility
            end
            return paint
        end
    end,

    [5] = function()
        local env, scriptObj, requireFunc = getModule(5)
        local Creator = requireFunc(scriptObj.Parent.Parent.Creator)
        return function()
            return Creator.New("Part", {
                Name = "Body",
                Color = Color3.new(0, 0, 0),
                Material = Enum.Material.Glass,
                Size = Vector3.new(1, 1, 0),
                Anchored = true,
                CanCollide = false,
                Locked = true,
                CastShadow = false,
                Transparency = 0.98
            }, {
                Creator.New("SpecialMesh", { MeshType = Enum.MeshType.Brick, Offset = Vector3.new(0, 0, -1E-6) })
            })
        end
    end,

    [6] = function()
        local env, scriptObj, requireFunc = getModule(6)
        local mapValue = function(val, inMin, inMax, outMin, outMax)
            return (val - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
        end
        local screenToRay = function(pos, dist)
            local ray = game:GetService("Workspace").CurrentCamera:ScreenPointToRay(pos.X, pos.Y)
            return ray.Origin + ray.Direction * dist
        end
        local getOffset = function()
            local vpY = game:GetService("Workspace").CurrentCamera.ViewportSize.Y
            return mapValue(vpY, 0, 2560, 8, 56)
        end
        return { screenToRay, getOffset }
    end,

    [8] = function()
        return {
            Close = "rbxassetid://9886659671",
            Min = "rbxassetid://9886659276",
            Max = "rbxassetid://9886659406",
            Restore = "rbxassetid://9886659001"
        }
    end,

    [18] = function()
        local env, scriptObj, requireFunc = getModule(18)
        local Themes = requireFunc(scriptObj.Parent.Themes)
        local Flipper = requireFunc(scriptObj.Parent.Packages.Flipper)

        local Creator = {
            Registry = {},
            Signals = {},
            TransparencyMotors = {},
            DefaultProperties = {
                ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
                Frame = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
                ScrollingFrame = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), ScrollBarImageColor3 = Color3.new(0, 0, 0) },
                TextLabel = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, TextSize = 14 },
                TextButton = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), AutoButtonColor = false, Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14 },
                TextBox = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), ClearTextOnFocus = false, Font = Enum.Font.SourceSans, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14 },
                ImageLabel = { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
                ImageButton = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), AutoButtonColor = false },
                CanvasGroup = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 }
            }
        }

        function Creator.AddSignal(signal, callback)
            table.insert(Creator.Signals, signal:Connect(callback))
        end

        function Creator.Disconnect()
            for i = #Creator.Signals, 1, -1 do
                local conn = table.remove(Creator.Signals, i)
                conn:Disconnect()
            end
        end

        function Creator.GetThemeProperty(prop)
            local currentTheme = requireFunc(scriptObj.Parent).Theme
            if Themes[currentTheme] and Themes[currentTheme][prop] then
                return Themes[currentTheme][prop]
            end
            return Themes.Dark[prop]
        end

        function Creator.UpdateTheme()
            for obj, data in next, Creator.Registry do
                for prop, themeTag in next, data.Properties do
                    obj[prop] = Creator.GetThemeProperty(themeTag)
                end
            end
            for _, motor in next, Creator.TransparencyMotors do
                motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
            end
        end

        function Creator.AddThemeObject(obj, props)
            local idx = #Creator.Registry + 1
            Creator.Registry[obj] = { Object = obj, Properties = props, Idx = idx }
            Creator.UpdateTheme()
            return obj
        end

        function Creator.OverrideTag(obj, props)
            Creator.Registry[obj].Properties = props
            Creator.UpdateTheme()
        end

        function Creator.New(className, props, children)
            local inst = Instance.new(className)
            for k, v in next, Creator.DefaultProperties[className] or {} do inst[k] = v end
            for k, v in next, props or {} do if k ~= "ThemeTag" then inst[k] = v end end
            for _, child in next, children or {} do child.Parent = inst end
            if props and props.ThemeTag then Creator.AddThemeObject(inst, props.ThemeTag) end
            return inst
        end

        function Creator.SpringMotor(initial, obj, prop, ignoreDialog, isTransparency)
            local motor = Flipper.SingleMotor.new(initial)
            motor:onStep(function(val) obj[prop] = val end)
            if isTransparency then
                table.insert(Creator.TransparencyMotors, motor)
            end
            local setGoal = function(target, override)
                if not ignoreDialog and not override and prop == "BackgroundTransparency" and requireFunc(scriptObj.Parent).DialogOpen then
                    return
                end
                motor:setGoal(Flipper.Spring.new(target, { frequency = 8 }))
            end
            return motor, setGoal
        end

        return Creator
    end,

    [19] = function()
        local env, scriptObj, requireFunc = getModule(19)
        local elements = {}
        for _, child in next, scriptObj:GetChildren() do
            table.insert(elements, requireFunc(child))
        end
        return elements
    end,

    [20] = function()
        local env, scriptObj, requireFunc = getModule(20)
        local Creator = requireFunc(scriptObj.Parent.Parent.Creator)
        local ButtonObj = { __type = "Button" }
        ButtonObj.__index = ButtonObj

        function ButtonObj.New(self, id, config)
            assert(config.Title, "Button - Missing Title")
            config.Callback = config.Callback or function() end
            local element = requireFunc(scriptObj.Parent.Parent.Components.Element)(config.Title, config.Description, self.Container, true)
            
            Creator.New("ImageLabel", {
                Image = "rbxassetid://10709791437",
                Size = UDim2.fromOffset(16, 16),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                BackgroundTransparency = 1,
                Parent = element.Frame,
                ThemeTag = { ImageColor3 = "Text" }
            })

            Creator.AddSignal(element.Frame.MouseButton1Click, function()
                self.Library:SafeCallback(config.Callback)
            end)
            return element
        end

        return ButtonObj
    end,

    [28] = function()
        local env, scriptObj, requireFunc = getModule(28)
        return requireFunc(1)[28] -- icons asset list loaded dynamically
    end,

    [30] = function()
        local env, scriptObj, requireFunc = getModule(30)
        return {
            SingleMotor = requireFunc(scriptObj.SingleMotor),
            GroupMotor = requireFunc(scriptObj.GroupMotor),
            Instant = requireFunc(scriptObj.Instant),
            Linear = requireFunc(scriptObj.Linear),
            Spring = requireFunc(scriptObj.Spring),
            isMotor = requireFunc(scriptObj.isMotor)
        }
    end,

    [47] = function()
        local env, scriptObj, requireFunc = getModule(47)
        local themes = { Names = { "Dark", "Darker", "Light", "Aqua", "Amethyst", "Rose" } }
        for _, child in next, scriptObj:GetChildren() do
            local themeData = requireFunc(child)
            themes[themeData.Name] = themeData
        end
        return themes
    end
}

-- Virtual Module Loader Engine
local loadedModules = {}
local moduleInstances = {}
local virtualFs = {}

local function createVirtualInstance(className, name, parent)
    local inst = newproxy(true)
    local meta = getmetatable(inst)
    local children = {}
    virtualFs[inst] = children

    meta.__index = function(_, key)
        if key == "ClassName" then return className
        elseif key == "Name" then return name
        elseif key == "Parent" then return parent
        elseif key == "GetChildren" then
            return function()
                local res = {}
                for child in pairs(children) do table.insert(res, child) end
                return res
            end
        end
        for child in pairs(children) do
            if child.Name == key then return child end
        end
    end
    meta.__tostring = function() return name end

    if parent then virtualFs[parent][inst] = true end
    return inst
end

local function buildTree(data, parent)
    local id, className, props, children = data[1], data[2], data[3], data[4]
    local name = props[1]
    local inst = createVirtualInstance(className, name, parent)
    moduleInstances[id] = inst

    if children then
        for _, childData in ipairs(children) do
            buildTree(childData, inst)
        end
    end
    return inst
end

for _, treeData in ipairs(modulesData) do
    buildTree(treeData, nil)
end

function getModule(modId)
    local inst = moduleInstances[modId]
    if loadedModules[inst] then
        return unpack(loadedModules[inst])
    end

    local requireFunc = function(target)
        if type(target) == "number" then
            return getModule(target)
        end
        for id, obj in pairs(moduleInstances) do
            if obj == target then
                return getModule(id)
            end
        end
    end

    local fn = moduleFunctions[modId]
    if fn then
        local env = { script = inst, require = requireFunc }
        setfenv(fn, setmetatable(env, { __index = _G }))
        local result = { fn() }
        loadedModules[inst] = result
        return unpack(result)
    end
end

-- Return Fluent GUI Engine
return getModule(1)
