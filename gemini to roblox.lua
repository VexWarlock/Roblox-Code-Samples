--ServerScriptService -> Script
local HttpService = game:GetService("HttpService")
local RemoteEvent = game.ReplicatedStorage:WaitForChild("AIEvent")

local NPC = workspace:WaitForChild("npc")
local Head = NPC:WaitForChild("Head")

local URL = "https://wallet-arkansas-throwing-away.trycloudflare.com/ai" --CloudFlared link

local cooldown = {}
local currentBubble

local function createChatBubble(text)
	if currentBubble then
		currentBubble:Destroy()
		currentBubble = nil
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AIChatBubble"
	billboard.Adornee = Head
	billboard.Size = UDim2.new(0, 300, 0, 100)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 1, -16)
	label.Position = UDim2.new(0, 8, 0, 8)
	label.BackgroundTransparency = 1
	label.TextWrapped = true
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 18
	label.Text = text
	label.Parent = frame

	billboard.Parent = Head
	currentBubble = billboard

	task.delay(6, function()
		if billboard then
			billboard:Destroy()
			if currentBubble == billboard then
				currentBubble = nil
			end
		end
	end)
end

RemoteEvent.OnServerEvent:Connect(function(player, text)
	if cooldown[player] then return end
	cooldown[player] = true

	local success, response = pcall(function()
		return HttpService:PostAsync(
			URL,
			HttpService:JSONEncode({ message = text }),
			Enum.HttpContentType.ApplicationJson
		)
	end)

	if success then
		local data = HttpService:JSONDecode(response)
		createChatBubble(data.reply)
	else
		warn("AI HTTP error:", response)
		createChatBubble("...")
	end

	task.delay(3, function()
		cooldown[player] = nil
	end)
end)



--StarterPlayerScripts -> Localscript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local RemoteEvent = ReplicatedStorage:WaitForChild("AIEvent")

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "AIInputGui"
gui.Parent = player:WaitForChild("PlayerGui")

local box = Instance.new("TextBox")
box.Size = UDim2.new(0, 300, 0, 40)
box.Position = UDim2.new(0.5, -150, 0.85, 0)
box.PlaceholderText = "Vorbește cu NPC..."
box.ClearTextOnFocus = false
box.Text = ""
box.Parent = gui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 40)
button.Position = UDim2.new(0.5, -50, 0.92, 0)
button.Text = "Trimite"
button.Parent = gui

-- Trimite mesajul către server
button.MouseButton1Click:Connect(function()
	local text = box.Text
	if text ~= "" then
		RemoteEvent:FireServer(text)
		box.Text = ""
	end
end)



--Node.js Server
import express from "express";
import { GoogleGenerativeAI } from "@google/generative-ai";

const app = express();
app.use(express.json());

const GEMINI_API_KEY = "zaSyCVPKP0klMDnERbCEh6Yp09wU3lBvJtPeg"; --AI Studio API key

const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

const model = genAI.getGenerativeModel({
    model: "gemini-2.5-flash"
});

const SYSTEM_PROMPT = `
You are an NPC in a Roblox game.
Answer briefly.
Stay in character.
`;

app.post("/ai", async (req, res) => {
    try {
        const message = req.body.message;
        console.log("Received message:", message);

        if (!message || message.length > 200) {
            return res.status(400).json({ error: "Invalid message" });
        }

        const result = await model.generateContent([
            SYSTEM_PROMPT,
            message
        ]);

        const reply = result.response.text();
        console.log("Reply:", reply);

        res.json({ reply });

    } catch (err) {
        console.error("Gemini error:", err);
        res.status(500).json({ error: "Gemini error" });
    }
});

app.listen(3000, "0.0.0.0", () => {
    console.log("Gemini AI server running on port 3000 (hardcoded key)");
});

--Cloudflared tunnel (Optional): cloudflared tunnel -url http://localhost:3000
