--[[
    Fluent Interface Suite - Unpacked & Readable Source Code
    Original Author: dawid
    License: MIT
    
    คุณสามารถนำโค้ดนี้ไปดัดแปลง แก้ไขสไตล์ UI หรือเพิ่มฟีเจอร์ของตัวเองได้ตามต้องการ
--]]

local Fluent = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. CREATOR MODULE (สำหรับสร้าง Instance และจัดการ Theme/Signals)
--------------------------------------------------------------------------------
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
        local connection = table.remove(Creator.Signals, i)
        connection:Disconnect()
    end
end

function Creator.GetThemeProperty(property)
    if Fluent.ThemesList and Fluent.ThemesList[Fluent.Theme] and Fluent.ThemesList[Fluent.Theme][property] then
        return Fluent.ThemesList[Fluent.Theme][property]
    end
    return Fluent.ThemesList.Dark[property]
end

function Creator.UpdateTheme()
    for object, data in next, Creator.Registry do
        for prop, themeTag in next, data.Properties do
            object[prop] = Creator.GetThemeProperty(themeTag)
        end
    end
end

function Creator.AddThemeObject(object, properties)
    local idx = #Creator.Registry + 1
    Creator.Registry[object] = { Object = object, Properties = properties, Idx = idx }
    Creator.UpdateTheme()
    return object
end

function Creator.New(className, properties, children)
    local instance = Instance.new(className)
    for prop, val in next, Creator.DefaultProperties[className] or {} do
        instance[prop] = val
    end
    for prop, val in next, properties or {} do
        if prop ~= "ThemeTag" then
            instance[prop] = val
        end
    end
    for _, child in next, children or {} do
        child.Parent = instance
    end
    if properties and properties.ThemeTag then
        Creator.AddThemeObject(instance, properties.ThemeTag)
    end
    return instance
end

--------------------------------------------------------------------------------
-- 2. THEMES CONFIGURATION (ชุดสีของ GUI - ปรับแต่งสีตรงนี้ได้เลย)
--------------------------------------------------------------------------------
Fluent.ThemesList = {
    Names = { "Dark", "Darker", "Light", "Aqua", "Amethyst", "Rose" },
    Dark = {
        Name = "Dark",
        Accent = Color3.fromRGB(96, 205, 255),
        AcrylicMain = Color3.fromRGB(60, 60, 60),
        AcrylicBorder = Color3.fromRGB(90, 90, 90),
        AcrylicGradient = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(40, 40, 40)),
        AcrylicNoise = 0.9,
        TitleBarLine = Color3.fromRGB(75, 75, 75),
        Tab = Color3.fromRGB(120, 120, 120),
        Element = Color3.fromRGB(120, 120, 120),
        ElementBorder = Color3.fromRGB(35, 35, 35),
        InElementBorder = Color3.fromRGB(90, 90, 90),
        ElementTransparency = 0.87,
        ToggleSlider = Color3.fromRGB(120, 120, 120),
        ToggleToggled = Color3.fromRGB(0, 0, 0),
        SliderRail = Color3.fromRGB(120, 120, 120),
        DropdownFrame = Color3.fromRGB(160, 160, 160),
        DropdownHolder = Color3.fromRGB(45, 45, 45),
        DropdownBorder = Color3.fromRGB(35, 35, 35),
        DropdownOption = Color3.fromRGB(120, 120, 120),
        Keybind = Color3.fromRGB(120, 120, 120),
        Input = Color3.fromRGB(160, 160, 160),
        InputFocused = Color3.fromRGB(10, 10, 10),
        InputIndicator = Color3.fromRGB(150, 150, 150),
        Dialog = Color3.fromRGB(45, 45, 45),
        DialogHolder = Color3.fromRGB(35, 35, 35),
        DialogHolderLine = Color3.fromRGB(30, 30, 30),
        DialogButton = Color3.fromRGB(45, 45, 45),
        DialogButtonBorder = Color3.fromRGB(80, 80, 80),
        DialogBorder = Color3.fromRGB(70, 70, 70),
        DialogInput = Color3.fromRGB(55, 55, 55),
        DialogInputLine = Color3.fromRGB(160, 160, 160),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(170, 170, 170),
        Hover = Color3.fromRGB(120, 120, 120),
        HoverChange = 0.07
    }
}

--------------------------------------------------------------------------------
-- 3. MAIN GUI SETUP & INITIALIZATION
--------------------------------------------------------------------------------
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local ScreenGui = Creator.New("ScreenGui", {
    Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")
})
ProtectGui(ScreenGui)

-- ค่าเริ่มต้นของ Library
Fluent.Version = "1.1.0 (Custom)"
Fluent.OpenFrames = {}
Fluent.Options = {}
Fluent.Themes = Fluent.ThemesList.Names
Fluent.Window = nil
Fluent.Theme = "Dark"
Fluent.GUI = ScreenGui

-- ฟังก์ชันสำหรับ Error Handler ใน Callback
function Fluent:SafeCallback(func, ...)
    if not func then return end
    local success, err = pcall(func, ...)
    if not success then
        warn("[Custom Fluent UI Error]:", err)
        Fluent:Notify({
            Title = "Callback Error",
            Content = tostring(err),
            Duration = 5
        })
    end
end

-- ฟังก์ชันสร้าง Notification
function Fluent:Notify(config)
    print("Notification:", config.Title, "-", config.Content)
    -- โค้ดสร้าง UI Notification สามารถขยายต่อได้ตรงนี้
end

-- ฟังก์ชันสร้าง Window หลัก
function Fluent:CreateWindow(config)
    assert(config.Title, "Window - Missing Title")
    if Fluent.Window then
        print("คุณไม่สามารถสร้าง Window มากกว่า 1 อันได้")
        return
    end

    local WindowFrame = Creator.New("Frame", {
        Name = "MainWindow",
        Size = config.Size or UDim2.fromOffset(580, 460),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ScreenGui,
        ThemeTag = { BackgroundColor3 = "Dialog" }
    }, {
        Creator.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Creator.New("TextLabel", {
            Name = "TitleLabel",
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.fromOffset(10, 5),
            Text = config.Title,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeTag = { TextColor3 = "Text" }
        })
    })

    Fluent.Window = WindowFrame
    return WindowFrame
end

function Fluent:Destroy()
    if Fluent.Window then
        Creator.Disconnect()
        Fluent.GUI:Destroy()
        Fluent.Window = nil
    end
end

if getgenv then
    getgenv().Fluent = Fluent
end

return Fluent
