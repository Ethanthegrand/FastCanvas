--!native

--[[

	FastCanvas is a simple, but very fast and efficent 
	drawing canvas with per pixel methods via EditableImage

	Written by @Ethanthegrand14
	
	Created: 9/11/2023
	Last Updated: 15/12/2023
	
	Copyright © 2023
	Do not redistribute!
]]

local FastCanvas = {}

function FastCanvas.new(Width: number, Height: number, Object: Instance, Blur: boolean?)
	
	local Canvas = {} -- The canvas object
	local Grid = table.create(Width * Height * 4, 1) -- Local pixel grid containing RGBA values

	local Origin = Vector2.zero
	local Resolution = Vector2.new(Width, Height)
	
	-- Local functions
	local function GetGridIndex(X, Y)
		return (X + (Y - 1) * Width) * 4 - 3
	end
	
	-- Create gui objects
	local CanvasFrame = Instance.new("ImageLabel")
	CanvasFrame.Name = "FastCanvas"
	CanvasFrame.BackgroundTransparency = 1
	CanvasFrame.ClipsDescendants = true
	CanvasFrame.Size = UDim2.fromScale(1, 1)
	CanvasFrame.Position = UDim2.fromScale(0.5, 0.5)
	CanvasFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	
	if not Blur then
		CanvasFrame.ResampleMode = Enum.ResamplerMode.Pixelated
	end

	local AspectRatio = Instance.new("UIAspectRatioConstraint")
	AspectRatio.AspectRatio = Width / Height
	AspectRatio.Parent = CanvasFrame
	
	local EditableImage = Instance.new("EditableImage")
	EditableImage.Size = Resolution
	EditableImage.Parent = CanvasFrame
	
	CanvasFrame.Parent = Object
	
	-- Canvas properties
	
	Canvas.Image = EditableImage
	
	-- Pixel set methods
	
	function Canvas:SetColor3(X: number, Y: number, Colour: Color3)
		local Index = GetGridIndex(X, Y)
		Grid[Index] = Colour.R
		Grid[Index + 1] = Colour.G
		Grid[Index + 2] = Colour.B
	end
	
	function Canvas:SetRGB(X: number, Y: number, R: number, G: number, B: number)
		local Index = GetGridIndex(X, Y)
		Grid[Index] = R
		Grid[Index + 1] = G
		Grid[Index + 2] = B
	end
	
	function Canvas:SetAlpha(X: number, Y: number, Alpha: number)
		Grid[GetGridIndex(X, Y) + 3] = Alpha
	end
	
	-- Pixel fetch methods
	
	function Canvas:GetColor3(X: number, Y: number): Color3
		local Index = GetGridIndex(X, Y)
		
		return Color3.new(Grid[Index], Grid[Index + 1], Grid[Index + 2])
	end
	
	function Canvas:GetRGB(X: number, Y: number): (number, number, number)
		local Index = GetGridIndex(X, Y)
		
		return Grid[Index], Grid[Index + 1], Grid[Index + 2]
	end
	
	function Canvas:GetAlpha(X: number, Y: number): number
		local Index = GetGridIndex(X, Y)

		return Grid[Index + 3]
	end
	
	-- Canvas methods
	
	function Canvas:Render()
		EditableImage:WritePixels(Origin, Resolution, Grid)
	end
	
	function Canvas:Destroy()
		Canvas = nil
		Grid = nil
		CanvasFrame:Destroy()
	end
	
	return Canvas
end

return FastCanvas