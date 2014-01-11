-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local widget = require("widget");
local function doubleSliderListener(event)
	
	print("Val Min ",event.value);
	print("Val Max ",event.valueMax);
end
_W = display.contentWidth;
_H = display.contentHeight;
local s_h = require("rangeSlider").new(
   {
        top = 0,
        left = 0,
        width = _W*0.9,
        height = _H*0.5,
        value = 10,
        valueMax = 80,
        listener = doubleSliderListener,
        orientation = "horizontal",
        doubleSlider = true,
    },widget.theme["slider"]

)
s_h.x = _W*0.5;
s_h.y = _H*0.05;

local s_v = require("rangeSlider").new(
   {
        top = 0,
        left = 0,
        width = _W*0.9,
        height = _H*0.5,
        value = 10,
        valueMax = 80,
        listener = doubleSliderListener,
        orientation = "vertical",
        doubleSlider = true,
    },widget.theme["slider"]

)
s_v.x = _W*0.5;
s_v.y = _H*0.6;