--!native

--[[
	FastCanvas is a simple, but very fast and efficent 
	drawing canvas with per pixel methods via EditableImage.
	
	This module was designed to be intergrated with CanvasDraw. 
	A real-time roblox pixel graphics engine.
	
	This can be used on normal GUI Frames AND Decals, Textures, MeshParts, etc

	Written by @Ethanthegrand14
	
	Created: 9/11/2023
	Last Updated: 20/09/2024
]]

local FastCanvas = {}

type ParentType = GuiObject | Decal | Texture | SurfaceAppearance | MeshPart

function FastCanvas.new(Width: number, Height: number, CanvasParent: ParentType, Blur: boolean?)
	local IsUiParent = CanvasParent:IsA("GuiObject")
	
	local Canvas = {} -- The canvas object
	local Grid = buffer.create(Width * Height * 4) -- Local pixel grid containing RGBA values
	local CurrentClearRGBA = buffer.create(4)
	local ClearingGrid = buffer.create(Width * Height * 4) -- For Canvas:Clear()
	
	local Origin = Vector2.zero
	local Resolution = Vector2.new(Width, Height)
	
	-- Local functions
	local function GetGridIndex(X, Y)
		return (X + (Y - 1) * Width) * 4 - 4
	end
	
	-- Initialise buffers
	
	local Index = 0
	for _ = 1, Width * Height do
		
		buffer.writeu8(Grid, Index, 255)
		buffer.writeu8(Grid, Index + 1, 255)
		buffer.writeu8(Grid, Index + 2, 255)
		buffer.writeu8(Grid, Index + 3, 255)
		
		buffer.writeu8(ClearingGrid, Index, 255)
		buffer.writeu8(ClearingGrid, Index + 1, 255)
		buffer.writeu8(ClearingGrid, Index + 2, 255)
		buffer.writeu8(ClearingGrid, Index + 3, 255)
		
		Index += 4
	end
	
	buffer.writeu8(CurrentClearRGBA, 0, 255)
	buffer.writeu8(CurrentClearRGBA, 1, 255)
	buffer.writeu8(CurrentClearRGBA, 2, 255)
	buffer.writeu8(CurrentClearRGBA, 3, 255)
	
	-- Create gui objects
	
	local EditableImage = Instance.new("EditableImage")
	EditableImage.Size = Resolution
	
	local CanvasFrame
	local AspectRatio
	
	if IsUiParent then
		CanvasFrame = Instance.new("ImageLabel")
		CanvasFrame.Name = "FastCanvas"
		CanvasFrame.BackgroundTransparency = 1
		CanvasFrame.ClipsDescendants = true
		CanvasFrame.Size = UDim2.fromScale(1, 1)
		CanvasFrame.Position = UDim2.fromScale(0.5, 0.5)
		CanvasFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		
		if not Blur then
			CanvasFrame.ResampleMode = Enum.ResamplerMode.Pixelated
		end
		
		AspectRatio = Instance.new("UIAspectRatioConstraint")
		AspectRatio.AspectRatio = Width / Height
		AspectRatio.Parent = CanvasFrame
		
		EditableImage.Parent = CanvasFrame
		CanvasFrame.Parent = CanvasParent
	else
		EditableImage.Parent = CanvasParent
	end
	
	-- Properties [READ ONLY]
	Canvas.Image = EditableImage
	Canvas.Width, Canvas.Height = Width, Height
	
	
	-- Pixel methods
	
	function Canvas:SetColor3(X: number, Y: number, Colour: Color3)
		local Index = GetGridIndex(X, Y)
		buffer.writeu8(Grid, Index, Colour.R * 255)
		buffer.writeu8(Grid, Index + 1, Colour.G * 255)
		buffer.writeu8(Grid, Index + 2, Colour.B * 255)
	end
	
	function Canvas:SetRGB(X: number, Y: number, R: number, G: number, B: number)
		local Index = GetGridIndex(X, Y)
		buffer.writeu8(Grid, Index, R * 255)
		buffer.writeu8(Grid, Index + 1, G * 255)
		buffer.writeu8(Grid, Index + 2, B * 255)
	end
	
	function Canvas:SetRGBA(X: number, Y: number, R: number, G: number, B: number, A: number)
		local Index = GetGridIndex(X, Y)
		buffer.writeu8(Grid, Index, R * 255)
		buffer.writeu8(Grid, Index + 1, G * 255)
		buffer.writeu8(Grid, Index + 2, B * 255)
		buffer.writeu8(Grid, Index + 3, A * 255)
	end
	
	function Canvas:SetAlpha(X: number, Y: number, Alpha: number)
		buffer.writeu8(Grid, GetGridIndex(X, Y) + 3, Alpha * 255)
	end
	
	-- Pixel fetch methods
	
	function Canvas:GetRGB(X: number, Y: number): (number, number, number)
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255
	end

	function Canvas:GetRGBA(X: number, Y: number): (number, number, number, number)
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255, buffer.readu8(Grid, Index + 3) / 255
	end
	
	function Canvas:GetColor3(X: number, Y: number): Color3
		local Index = GetGridIndex(X, Y)
		
		return Color3.new(buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255)
	end
	
	function Canvas:GetAlpha(X: number, Y: number): number
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index + 3) / 255
	end
	
	-- Canvas methods
	
	function Canvas:SetGrid(PixelArray)
		for i, Value in pairs(PixelArray) do
			buffer.writeu8(Grid, i - 1, Value * 255)
		end
	end

	function Canvas:GetGrid()
		local ReturnArray = {}
		
		for i = 1, Width * Height * 4 do
			ReturnArray[i] = buffer.readu8(Grid, i - 1) / 255
		end
		
		return ReturnArray
	end
	
	function Canvas:SetClearRGBA(R, G, B, A)
		for i = 1, Width * Height * 4, 4 do
			i -= 1
			buffer.writeu8(ClearingGrid, i, R * 255)
			buffer.writeu8(ClearingGrid, i + 1, G * 255)
			buffer.writeu8(ClearingGrid, i + 2, B * 255)
			buffer.writeu8(ClearingGrid, i + 3, A * 255)
		end
	end
	
	function Canvas:Clear()
		buffer.copy(Grid, 0, ClearingGrid, 0)
	end
	
	function Canvas:Render()
		EditableImage:WritePixelsBuffer(Origin, Resolution, Grid)
	end

	function Canvas:Resize(NewWidth, NewHeight)	
		Width, Height = NewWidth, NewHeight
		Resolution = Vector2.new(NewWidth, NewHeight)
		EditableImage.Size = Resolution
		
		Canvas.Width, Canvas.Height = NewWidth, NewHeight
		
		if AspectRatio then
			AspectRatio.AspectRatio = NewWidth / NewHeight
		end
		
		-- Initialise buffers
		
		Grid = buffer.create(NewWidth * NewHeight * 4)
		ClearingGrid = buffer.create(NewWidth * NewHeight * 4)

		local Index = 0
		for _ = 1, NewWidth * NewHeight do
			buffer.writeu8(Grid, Index, 255)
			buffer.writeu8(Grid, Index + 1, 255)
			buffer.writeu8(Grid, Index + 2, 255)
			buffer.writeu8(Grid, Index + 3, 255)

			Index += 4
		end
		
		self:SetClearRGBA(
			buffer.readu8(CurrentClearRGBA, 0) / 255,
			buffer.readu8(CurrentClearRGBA, 1) / 255,
			buffer.readu8(CurrentClearRGBA, 2) / 255,
			buffer.readu8(CurrentClearRGBA, 3) / 255
		)
		
		self:Clear()
	end
	
	function Canvas:Destroy()
		if CanvasFrame then
			CanvasFrame:Destroy()
		end
		Grid = nil
		Canvas = nil
	end
	
	return Canvas
end

return FastCanvas