local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local isChatSpyEnabled = true -- Toggle state
local toggleKey = Enum.KeyCode.F8 -- Default toggle key

local chatFrame = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local chatBox = Instance.new("Frame", chatFrame)
chatBox.Position = UDim2.new(0, 0, 0.5, -125) -- Adjust as needed
chatBox.Size = UDim2.new(0.3, 0, 0, 250)
chatBox.BackgroundTransparency = 0.5
chatBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
chatBox.ClipsDescendants = true
chatBox.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner", chatBox)
uiCorner.CornerRadius = UDim.new(0, 10)

-- Drag handle at the very top
local dragHandle = Instance.new("Frame", chatBox)
dragHandle.Size = UDim2.new(1, 0, 0, 25)
dragHandle.BackgroundTransparency = 0.3
dragHandle.BackgroundColor3 = Color3.new(0, 0, 0)

local dragHandleCorner = Instance.new("UICorner", dragHandle)
dragHandleCorner.CornerRadius = UDim.new(0, 10)

-- Add rounded X button to the top-right corner
local closeButton = Instance.new("TextButton", dragHandle)
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 0.3
closeButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) -- Dark grey color
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14
closeButton.Text = "X"

-- Add corner radius to the close button for rounded effect
local closeButtonCorner = Instance.new("UICorner", closeButton)
closeButtonCorner.CornerRadius = UDim.new(0, 10)

-- Function to destroy the chatFrame when X button is clicked
closeButton.MouseButton1Click:Connect(function()
    chatFrame:Destroy()
end)

local setKeybindButton = Instance.new("TextButton", chatBox)
setKeybindButton.Size = UDim2.new(1, 0, 0, 25)
setKeybindButton.Position = UDim2.new(0, 0, 1, -25)
setKeybindButton.BackgroundTransparency = 0.3
setKeybindButton.BackgroundColor3 = Color3.new(0, 0, 0)
setKeybindButton.TextColor3 = Color3.new(1, 1, 1)
setKeybindButton.Font = Enum.Font.SourceSansBold
setKeybindButton.TextSize = 14
setKeybindButton.Text = "Set Toggle Key (Current: F8)"

local setKeybindButtonCorner = Instance.new("UICorner", setKeybindButton)
setKeybindButtonCorner.CornerRadius = UDim.new(0, 10)

-- Create a padding object to ensure text doesn't go over the drag handle
local chatScrollingFrame = Instance.new("ScrollingFrame", chatBox)
chatScrollingFrame.Size = UDim2.new(1, 0, 0.85, -25) -- Make sure the chat starts under the drag bar
chatScrollingFrame.Position = UDim2.new(0, 0, 0, 25) -- Start right below the drag handle
chatScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatScrollingFrame.ScrollBarThickness = 4
chatScrollingFrame.BackgroundTransparency = 1
chatScrollingFrame.ClipsDescendants = true

local chatLayout = Instance.new("UIListLayout", chatScrollingFrame)
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Padding = UDim.new(0, 5)

-- Table to keep track of players that have been connected
local connectedPlayers = {}

local function createChatLabel(player, message)
    local chatLabel = Instance.new("TextLabel")
    chatLabel.Size = UDim2.new(1, 0, 0, 25)
    chatLabel.BackgroundTransparency = 1
    chatLabel.TextColor3 = Color3.new(1, 1, 1)
    chatLabel.Font = Enum.Font.SourceSansBold
    chatLabel.TextSize = 18
    chatLabel.TextXAlignment = Enum.TextXAlignment.Left -- Align text to the left
    chatLabel.Text = "[" .. player.DisplayName .. "]: " .. message
    chatLabel.Parent = chatScrollingFrame

    -- Auto-scroll to bottom
    chatScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y)
    chatScrollingFrame.CanvasPosition = Vector2.new(0, chatScrollingFrame.AbsoluteCanvasSize.Y)

    -- Fade away and remove the label after 30 seconds
    delay(30, function()
        local fadeOut = TweenService:Create(chatLabel, TweenInfo.new(1), {TextTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            chatLabel:Destroy()
        end)
    end)
end

local function onPlayerChatted(player, message)
    if isChatSpyEnabled then
        createChatLabel(player, message)
    end
end

local function connectPlayer(player)
    if not connectedPlayers[player] then
        connectedPlayers[player] = true
        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    connectPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    connectPlayer(player)
end)

chatFrame.Name = "ChatSpy"
chatFrame.ResetOnSpawn = false
chatFrame.Enabled = true

-- Make the chat box draggable
local dragging = false
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    chatBox.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = chatBox.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        update(input)
    end
end)

-- Toggle functionality
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == toggleKey then
        isChatSpyEnabled = not isChatSpyEnabled
        chatFrame.Enabled = isChatSpyEnabled
    end
end)

-- Set new keybind functionality
setKeybindButton.MouseButton1Click:Connect(function()
    setKeybindButton.Text = "Press a key..."
    local keyConnection
    keyConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            toggleKey = input.KeyCode
            setKeybindButton.Text = "Set Toggle Key (Current: " .. input.KeyCode.Name .. ")"
            keyConnection:Disconnect()
        end
    end)
end)
