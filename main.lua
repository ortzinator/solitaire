--Glossary of Solitaire terms:
--
--Stock: The stack of extra cards placed face-down in the upper left corner.
--Waste: The stack where cards from the Stock are placed face-up to be played.
--Foundations: The top row of card stacks where cards are placed starting with the Ace.
--Tableau: The bottom row of cards, each fanned downward, where cards are placed in 
--	alternating color and descending face value.

vector = require "hump.vector"
Gamestate = require "hump.gamestate"
require "cards"

debug = true

mainFont = love.graphics.newFont(20)

stock = Deck(vector(50, 50), true)
waste = Deck(vector(180, 50), true)

foundation = {}
foundation[1] = Deck(vector(500, 50), true)
foundation[2] = Deck(vector(650, 50), true)
foundation[3] = Deck(vector(800, 50), true)
foundation[4] = Deck(vector(950, 50), true)

tableaux = {}

moves = 0

victory = true

local game = Gamestate.new()

function lerp(x, a, b)
	x = math.max(0, x)
	x = math.min(1, x)
	return (a * x) + (b * (1 - x))
end

function love.load()
	Gamestate.registerEvents()
    Gamestate.switch(game)
end

function game:init()
	love.graphics.setBackgroundColor(0, 156, 29)

	stock:Init()
	stock:Shuffle()
	
	for i=1, 7, 1 do
		tableaux[i] = Deck(vector(150 * i, 250), false)
		fillDeck(stock, tableaux[i], i)
		tableaux[i]:HideAll()
		tableaux[i]:Peek().visible = true
	end
	
	stock:HideAll()
end

function game:draw()
	stock:Draw()
	waste:Draw()
	
	for i=1, 7, 1 do
		tableaux[i]:Draw()
	end
	
	foundation[1]:Draw()
	foundation[2]:Draw()
	foundation[3]:Draw()
	foundation[4]:Draw()
	
	if selectBox ~= nil then
		love.graphics.setColor(255, 0, 0)
		love.graphics.setLineWidth(3)
		love.graphics.rectangle("line", selectBox.x, selectBox.y, selectBox.width, selectBox.height)
		love.graphics.setLineWidth(1)
	end
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.print("Moves: " .. moves, 0, 0)
	
	if victory then
		
	end

	drawDebug()
end

function game:update(dt)
	
end

function game:mousepressed(x, y, mb)

	--stock click
	if isIn(vector(x, y), stock:GetBounds()) then
		if #stock.cards == 0 then
			flipStock()
			deselect()
		else
			card = stock:Pop()
			card.visible = true
			waste:Push(card)
			deselect()
		end
		return
	end
	
	--tableaux click
	for k,t in ipairs(tableaux) do
		if isIn(vector(x, y), t:GetBounds()) then
			if stackIsSelected() then
				if selectedStack:GetUpmostSelected():CanMoveTo(t:Peek()) then
					local toMove = selectedStack:PopSelection()
					for kk,vv in ipairs(toMove) do
						t:Push(vv)
					end
					if #selectedStack.cards > 0 then selectedStack:Peek().visible = true end
					moves = moves + 1
					deselect()
					return
				end
			end
			if #t.cards ~= 0 then
				deselect()
				local num = t:Click()
				t:Select(num)
				selectBox = t:GetSelectBox()
				selectedStack = t
				return
			end
		end
	end
	
	--waste click
	if isIn(vector(x, y), waste:GetBounds()) then
		if #waste.cards > 0 then
			selectBox = waste:GetBounds()
			waste:Select(#waste.cards)
			selectedStack = waste
		end
		return
	end
	
	--foundation click
	for k,f in ipairs(foundation) do
		if isIn(vector(x, y), f:GetBounds()) then
			if stackIsSelected() then --a stack is selected
				if selectedStack:GetNumSelected() ~= 1 then break end --can't move more than one card
				if #f.cards == 0 then
					if selectedStack:Peek().value == 1 then
						f:Push(selectedStack:Pop())
						if #selectedStack.cards > 0 then selectedStack:Peek().visible = true end
						moves = moves + 1
						deselect()
					end
				elseif f:Peek().value == selectedStack:Peek().value - 1 then
					if f:Peek().suit == selectedStack:Peek().suit then
						f:Push(selectedStack:Pop())
						if #selectedStack.cards > 0 then selectedStack:Peek().visible = true end
						moves = moves + 1
						deselect()
					end
				end
			elseif #f.cards ~= 0 then
				f:Select(#f.cards)
				selectBox = f:GetBounds()
				selectedStack = f
				return
			end
		end
	end
	
	deselect()
end

function stackIsSelected()
	return selectedStack ~= nil
end

function deselect()
	if stackIsSelected() then
		selectedStack:Deselect()
		selectBox = nil
		selectedStack = nil
	end
end

function flipStock()
	for i=1, #waste.cards, 1 do
		local card = waste:Pop()
		card.visible = false
		stock:Push(card)
	end
end

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function drawDebug()
	--love.graphics.print(love.timer.getFPS(), 0, 0)
end

function isIn(pos, rect)
	return pos.x > rect.x 
		and pos.y > rect.y
		and pos.x < rect.x + rect.width
		and pos.y < rect.y + rect.height
end

function fillDeck(source, destination, count)
	for i=1, count, 1 do
		destination:Push(source:Pop())
	end
end