Class = require 'hump.class'

cardHeight = 150
cardWidth = 103

spacing = 20

cardFont = love.graphics.newFont(20)
cardTiles = love.graphics.newImage('cards.png')

tileW, tileH = 103,150
tilesetW, tilesetH = cardTiles:getWidth(), cardTiles:getHeight()

suits = {"H", "S", "C", "D"}

quads = {C = {}, D = {}, H = {}, S = {}}

blankQuad = love.graphics.newQuad(206,  600, tileW, tileH, tilesetW, tilesetH)

for k,v in ipairs(suits) do
	for i=0, 13, 1 do
		quads[v][i + 1] = love.graphics.newQuad(tileW * i,  tileH * (k - 1), tileW, tileH, tilesetW, tilesetH)
	end
end

--Card
Card = Class(function(self, suit, value)
	self.suit = suit
	self.value = value
	self.visible = true
end)

function Card:Draw(pos)
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		-- love.graphics.rectangle("fill", pos.x, pos.y, cardWidth, cardHeight)
		-- love.graphics.setColor(0, 0, 0)
		-- love.graphics.rectangle("line", pos.x-1, pos.y-1, cardWidth+2, cardHeight+2)
		
		-- if(suitColor(self.suit) == "R") then
			-- love.graphics.setColor(255, 50, 50)
		-- else
			-- love.graphics.setColor(0, 0, 0)
		-- end
		-- love.graphics.setFont(cardFont)
		-- love.graphics.print(self.value .. self.suit, pos.x + 10, pos.y + 10)
		love.graphics.drawq(cardTiles, quads[self.suit][self.value], pos.x, pos.y)
	else
		-- love.graphics.setColor(0, 0, 156)
		-- love.graphics.rectangle("fill", pos.x-1, pos.y-1, cardWidth+2, cardHeight+2)
		-- love.graphics.setColor(0, 0, 0)
		-- love.graphics.rectangle("line", pos.x, pos.y, cardWidth, cardHeight)
		love.graphics.setColor(255, 255, 255)
		love.graphics.drawq(cardTiles, blankQuad, pos.x, pos.y)
	end
end

function Card:CanMoveTo(card)
	if(card == nil) then
		if(self.value == 13) then
			return true
		else
			return false
		end
	end
		
	if(suitColor(self.suit) ~= suitColor(card.suit) and self.value == card.value - 1) then
		return true
	end
	
	return false
end

function Card:Print()
	print(self.value .. self.suit)
end

--Deck
Deck = Class(function(self, position, flat)
	self.cards = {}
	self.position = position
	self.flat = flat
	self.selected = nil
end)

function Deck:Push(card)
	table.insert(self.cards, card)
end

function Deck:Init()
	for k,v in ipairs(suits) do
		for i=1, 13 do
			self:Push(Card(v, i))
		end
	end
end

function Deck:Pop()
	local card = self.cards[#self.cards]
	table.remove(self.cards)
	return card
end

function Deck:Peek()
	return self.cards[#self.cards]
end

function Deck:Shuffle()
	math.randomseed(os.time())
	
	local n = #self.cards
	while n > 2 do
		local k = math.random(n)
		self.cards[n], self.cards[k] = self.cards[k], self.cards[n]
		n = n - 1
	end
end

function Deck:Draw()
	if #self.cards == 0 then
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", self.position.x, self.position.y, cardWidth, cardHeight)
	else
		if self.flat then
			self:Peek():Draw(self.position)
		else
			for k,v in ipairs(self.cards) do
				v:Draw(vector(self.position.x, self.position.y + spacing * k - spacing))
			end
		end
	end
end

function Deck:Click()
	pos = love.mouse.getY() - self.position.y
	return math.min(math.ceil(pos / spacing), #self.cards)
end

function Deck:Select(num)
	local high = #self.cards - self:GetNumberVisible() + 1
	self.selected = math.max(num, high)
end

function Deck:Deselect()
	self.selected = nil
end

function Deck:GetSelectBox()
	local numSelected = self:GetNumSelected()
	rect = {}
	rect.x = self.position.x
	rect.y = self.position.y + (self.selected - 1) * spacing
	rect.width = cardWidth
	rect.height = cardHeight + (spacing * (numSelected - 1))
	return rect
end

function Deck:GetNumSelected()
	return #self.cards - self.selected + 1
end

function Deck:PopSelection()
	return self:Break(self.selected)
end

function Deck:Break(num)
	local sliced_array = {}
	removed = 0
	num = math.max(num, 1)
	for i=num, #self.cards do
		sliced_array[#sliced_array+1] = self.cards[i]
		removed = removed + 1
	end
	for i=1, removed, 1 do
		self:Pop()
	end
	return sliced_array
end

function Deck:GetUpmostSelected()
	return self.cards[self.selected]
end

function Deck:GetNumberVisible()
	local num = 0
	for k,v in ipairs(self.cards) do
		if v.visible then
			num = num + 1
		end
	end
	return num
end

function Deck:GetBounds()
	rect = {}
	rect.x = self.position.x
	rect.y = self.position.y
	rect.width = cardWidth
	if self.flat then
		rect.height = cardHeight
	else
		rect.height = cardHeight + (spacing * (#self.cards - 1))
	end
	return rect
end

function Deck:HideAll()
	for k,v in ipairs(self.cards) do
		v.visible = false
	end
end

function suitColor(suit)
	if(suit == "D" or suit == "H") then
		return "R"
	else
		return "B"
	end
end