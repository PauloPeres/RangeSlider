-- Copyright © 2013 Corona Labs Inc. All Rights Reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of the company nor the names of its contributors
--      may be used to endorse or promote products derived from this software
--      without specific prior written permission.
--    * Redistributions in any form whatsoever must retain the following
--      acknowledgment visually in the program (e.g. the credits of the program): 
--      'This product includes software developed by Corona Labs Inc. (http://www.coronalabs.com).'
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL CORONA LABS INC. BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
-- EDIT BY PAULO PERES JR JAN 10 2014
-- NUOFFER

local M = 
{
	_options = {},
	_widgetName = "widget.newRangeSlider",
}


-- Require needed widget files
local _widget = require( "widget" )

local isGraphicsV1 = ( 1 == display.getDefault( "graphicsCompatibility" ) )

-- Localize math functions
local mRound = math.round


-- Creates a new horizontal slider from an imageSheet
local function createHorizontalSlider( slider, options )
	-- Create a local reference to our options table
	local opt = options
	local isDoubleSlider = opt.doubleSlider;

	-- Forward references
	local imageSheet, view, viewLeft, viewRight, viewMiddle, viewFill, viewFillMax, viewHandle,viewHandlemax
		
		
	-- Create the view
	if opt.sheet then
		imageSheet = opt.sheet
	else
		local themeData = require( opt.themeData )
		imageSheet = graphics.newImageSheet( opt.themeSheetFile, themeData:getSheet() )
	end
	
	-- The view is the slider (group)
	view = slider
	
	-- The slider's left frame
	viewLeft = display.newImageRect( slider, imageSheet, opt.leftFrame, opt.frameWidth, opt.frameHeight )
	
	-- The slider's middle frame
	viewMiddle = display.newImageRect( slider, imageSheet, opt.middleFrame, opt.frameWidth, opt.frameHeight )
	
	-- The slider's right frame
	if isDoubleSlider == true then
		viewRight = display.newImageRect( slider, imageSheet, opt.leftFrame, opt.frameWidth, opt.frameHeight )
		viewRight.rotation = 180;
	else
		viewRight = display.newImageRect( slider, imageSheet, opt.rightFrame, opt.frameWidth, opt.frameHeight )
	end
	-- The slider's fill
	viewFill = display.newImageRect( slider, imageSheet, opt.fillFrame, opt.frameWidth, opt.frameHeight )
	
	if isDoubleSlider == true then
		viewFillMax = display.newImageRect( slider, imageSheet, opt.fillFrame, opt.frameWidth, opt.frameHeight )
	end

	-- The slider's handle
	viewHandle = display.newImageRect( slider, imageSheet, opt.handleFrame, opt.handleWidth, opt.handleHeight )
	if isDoubleSlider == true then
		viewHandlemax = display.newImageRect( slider, imageSheet, opt.handleFrame, opt.handleWidth, opt.handleHeight );
	end
	
	-------------------------------------------------------
	-- Positioning
	-------------------------------------------------------
	
	-- Position the slider's left frame
	viewLeft.x = slider.x + ( viewLeft.contentWidth * 0.5 )
	viewLeft.y = slider.y + ( viewLeft.contentHeight * 0.5 )
	
	-- Position the slider's middle frame & set it's width
	viewMiddle.width = opt.width - ( viewLeft.contentWidth + viewRight.contentWidth )
	viewMiddle.x = viewLeft.x + ( viewLeft.contentWidth * 0.5 ) + ( viewMiddle.contentWidth * 0.5 )
	viewMiddle.y = viewLeft.y
	
	-- Position the slider's fill	
	viewFill.width = ( viewMiddle.width / 100 ) * opt.defaultValue
	viewFill.x = viewLeft.x + ( viewLeft.contentWidth * 0.5 ) + ( viewFill.contentWidth * 0.5 )
	viewFill.y = viewLeft.y

	
	
	-- Position the slider's right frame
	viewRight.x = viewMiddle.x + ( viewMiddle.contentWidth * 0.5 ) + ( viewRight.contentWidth * 0.5 )
	viewRight.y = viewLeft.y
	
	-- Position the slider's Fill doubleSlider
	if viewFillMax then
		viewFillMax.width = ( viewMiddle.width / 100 ) * (100 - opt.valueMax)
		viewFillMax.x = viewRight.x - ( viewRight.contentWidth * 0.5 ) - ( viewFillMax.contentWidth * 0.5 )
		viewFillMax.y = viewRight.y
	end

	-- Position the slider's handle
	if opt.defaultValue < 1 then
		viewHandle.x = viewLeft.x + ( viewLeft.contentWidth * 0.5 )
	else
		viewHandle.x = viewFill.x + ( viewFill.contentWidth * 0.5 )
	end
	viewHandle.y = viewLeft.y

	-- Position the slider's handle doubleSLider
	if viewHandlemax then
		if opt.valueMax < 1 then
			viewHandlemax.x = viewRight.x + ( viewRight.contentWidth * 0.5 )
		else
			viewHandlemax.x = viewFillMax.x - ( viewFillMax.contentWidth * 0.5 )
		end
		viewHandlemax.y = viewRight.y
	end
	
	-------------------------------------------------------
	-- Assign properties to the view
	-------------------------------------------------------
	
	-- We need to assign these properties to the object
	view._left = viewLeft
	view._right = viewRight
	view._fill = viewFill
	view._middle = viewMiddle
	view._handle = viewHandle
	view._currentPercent = opt.defaultValue
	view._currentPercentMax = opt.valueMax;
	view._width = opt.width
	view._listener = opt.listener

	view._fillMax = viewFillMax;
	view._handleMax = viewHandlemax;

	
	-------------------------------------------------------
	-- Assign properties/objects to the slider
	-------------------------------------------------------
	
	-- Assign objects to the slider
	slider._imageSheet = imageSheet
	slider._view = view	
	slider.value = view._currentPercent
	slider.valueMax = view._currentPercentMax;
	
	----------------------------------------------------------
	--	PUBLIC METHODS	
	----------------------------------------------------------
	
	-- Function to set the slider's value
	function slider:setValue( value )
		self.value = value
		return self._view:_setValue( value )
	end
	
	----------------------------------------------------------
	--	PRIVATE METHODS	
	----------------------------------------------------------

	-- Touch listener for our slider
	function view.touch( event )
		local phase = event.phase
		local _slider = event.target.parent.parent
		-- Set the target to the handle
		local self = view;
		local t = event.target;
		local isHandleMin = t == self._handle;

		if "began" == phase then
			-- Did the touch begin on the Handle?			
			local touchBeganOnHandle = false
			
			-- The content bounds of our handle
			local bounds = t.contentBounds
			
			-- If the touch event is within the boundary of the handle
			if event.x > bounds.xMin and event.x < bounds.xMax then
				touchBeganOnHandle = true
			end
			
			-- If the touch began on the handle
			if touchBeganOnHandle then
				display.getCurrentStage():setFocus( event.target, event.id )
				self._isFocus = true
			
				-- Store the initial position
				t.x0 = event.x - t.x
			end
			
		elseif self._isFocus then
			if "moved" == phase then
				-- Update the position
				t.x = event.x - t.x0

				-- Limit the handle to stop at either end of the slider		
				
				if isDoubleSlider == true then
					if isHandleMin == true then
						if t.x <= self._left.x + ( self._left.contentWidth * 0.5 ) then
							t.x = self._left.x + ( self._left.contentWidth * 0.5 )
						elseif t.x >= self._handleMax.x - ( self._handleMax.contentWidth * 0.5 ) then
							t.x = self._handleMax.x - ( self._handleMax.contentWidth * 0.5 )
						end
					else
						if t.x <= self._handle.x + ( self._handle.contentWidth * 0.5 ) then
							t.x = self._handle.x + ( self._handle.contentWidth * 0.5 )
						elseif t.x >= self._right.x - ( self._right.contentWidth * 0.5 ) then
							t.x = self._right.x - ( self._right.contentWidth * 0.5 )
						end

					end
				else
					if t.x <= self._left.x + ( self._left.contentWidth * 0.5 ) then
						t.x = self._left.x + ( self._left.contentWidth * 0.5 )
					elseif t.x >= self._right.x - ( self._right.contentWidth * 0.5 ) then
						t.x = self._right.x - ( self._right.contentWidth * 0.5 )
					end
				end						
				-- Get handle position
				local handlePosition = ( t.x - self._left.x - self._left.contentWidth * 0.5 ) 
				
				-- Get the fills new horizontal position
				local fillXPos = self._left.x + ( handlePosition * 0.5 )

				-- Calculate the current percent
				if isHandleMin == true then
					self._currentPercent = ( handlePosition * 100 ) / ( ( self._width - self._left.contentWidth ) - ( self._right.contentWidth ) )
				else
					self._currentPercentMax = ( handlePosition * 100 ) / ( ( self._width - self._left.contentWidth ) - ( self._right.contentWidth ) )
				end
				
				-- Set the fill's width & position
				if isHandleMin == true then
					self._fill.width = handlePosition
					self._fill.x = fillXPos
				else
					self._fillMax.width = ( view._middle.width / 100 ) * (100 - self._currentPercentMax)
					self._fillMax.x = view._right.x - ( view._right.contentWidth * 0.5 ) - ( view._fillMax.contentWidth * 0.5 )
					
				end
			
			elseif "ended" == phase or "cancelled" == phase then
				-- Remove focus
				display.getCurrentStage():setFocus( nil )
				self._isFocus = false
			end
			
		end
		
		-- Execute the listener ( if any )
		if self._listener then
			local newEvent = 
			{ 
				name = event.name,
				phase = event.phase,
				value = mRound( self._currentPercent ),
				valueMax =self._currentPercentMax~= nil and mRound( self._currentPercentMax ) or 0,
				target = self,
			}
			self._listener( newEvent )
		end
		
		return true
	end
	
	view._handle:addEventListener( "touch" ,view.touch);
	if view._handleMax then
		view._handleMax:addEventListener( "touch" ,view.touch);
	end
	
	-- Function to set the sliders value
	function view:_setValue( value )
		self._fill.width = ( self._middle.contentWidth / 100 ) * value
		self._fill.x = self._left.x + ( self._left.contentWidth * 0.5 ) + ( self._fill.contentWidth * 0.5 )
		self._fill.y = self._left.y
		if value < 1 then
			self._handle.x = self._left.x + ( self._left.contentWidth * 0.5 )
			self._fill.width = 1
			self._fill.x = self._left.x + ( self._left.contentWidth * 0.5 ) + ( self._fill.contentWidth * 0.5 )
		else
			self._handle.x = self._fill.x + ( self._fill.contentWidth * 0.5 )
		end
		
		self._currentPercent = value

	end
	function view:_setValueMax(value)
		

		self._fillMax.width = ( view._middle.width / 100 ) * (100 - value)
		self._fillMax.x = view._right.x - ( view._right.contentWidth * 0.5 ) - ( view._fillMax.contentWidth * 0.5 )
					
		if value < 1 then
			view._handleMax.x = view._right.x + ( view._right.contentWidth * 0.5 )
			self._fillMax.width = 1
			self._fillMax.x = view._right.x - ( view._right.contentWidth * 0.5 ) - ( view._fillMax.contentWidth * 0.5 )
		else

			view._handleMax.x = view._fillMax.x - ( view._fillMax.contentWidth * 0.5 )
		end
		view._handleMax.y = view._right.y;

		self._currentPercentMax = value;
	end
	
	-- Finalize function for the slider
	function slider:_finalize()
		-- Set the ImageSheet to nil
		self._imageSheet = nil
	end
			
	return slider
end


-- Creates a new vertical slider from an imageSheet
local function createVerticalSlider( slider, options )
	-- Create a local reference to our options table
	local opt = options
	local isDoubleSlider = opt.doubleSlider;

	-- Forward references
	local imageSheet, view, viewTop, viewBottom, viewMiddle, viewFill, viewFillMax, viewHandle,viewHandlemax
		
	-- Create the view
	if opt.sheet then
		imageSheet = opt.sheet
	else
		local themeData = require( opt.themeData )
		imageSheet = graphics.newImageSheet( opt.themeSheetFile, themeData:getSheet() )
	end
	
	-- The view is the slider (group)
	view = slider
	
	-- The slider's left frame
	if isDoubleSlider==true then
		viewTop = display.newImageRect( slider, imageSheet, opt.bottomFrame, opt.frameWidth, opt.frameHeight )	
		viewTop.rotation = 180;
	else
		viewTop = display.newImageRect( slider, imageSheet, opt.topFrame, opt.frameWidth, opt.frameHeight )
	
	end
	-- The slider's middle frame
	viewMiddle = display.newImageRect( slider, imageSheet, opt.middleVerticalFrame, opt.frameWidth, opt.frameHeight )
	
	-- The slider's right frame
	viewBottom = display.newImageRect( slider, imageSheet, opt.bottomFrame, opt.frameWidth, opt.frameHeight )
	
	-- The slider's fill
	viewFill = display.newImageRect( slider, imageSheet, opt.fillVerticalFrame, opt.frameWidth, opt.frameHeight )
	-- EDIT BY PAULO
	if isDoubleSlider==true then

		viewFillMax = display.newImageRect( slider, imageSheet, opt.fillVerticalFrame, opt.frameWidth, opt.frameHeight )
	end
	-- The slider's handle
	viewHandle = display.newImageRect( slider, imageSheet, opt.handleFrame, opt.handleWidth, opt.handleHeight )	
	-- EDIT BY PAULO
	if isDoubleSlider==true then

		viewHandlemax = display.newImageRect( slider, imageSheet, opt.handleFrame, opt.handleWidth, opt.handleHeight );
		
	end

	-------------------------------------------------------
	-- Positioning
	-------------------------------------------------------
	
	-- Position the slider's left frame
	viewTop.x = slider.x + ( viewTop.contentWidth * 0.5 )
	viewTop.y = slider.y + ( viewTop.contentHeight * 0.5 )
	
	-- Position the slider's middle frame & set it's width
	viewMiddle.height = opt.height - ( viewTop.contentHeight + viewBottom.contentHeight )
	viewMiddle.x = viewTop.x
	viewMiddle.y = viewTop.y + ( viewTop.contentHeight * 0.5 ) + ( viewMiddle.contentHeight * 0.5 )
	
	-- Position the slider's bottom frame
	viewBottom.x = viewTop.x
	viewBottom.y = viewMiddle.y + ( viewMiddle.contentHeight * 0.5 ) + ( viewBottom.contentHeight * 0.5 )
	
	-- Position the slider's fill	
	viewFill.height = ( viewMiddle.contentHeight / 100 ) * opt.defaultValue
	viewFill.x = viewTop.x
	viewFill.y = viewBottom.y - ( viewFill.contentHeight * 0.5 ) - ( viewBottom.contentHeight * 0.5 )
	
	-- Edit by paulo
	
	if viewFillMax then
		viewFillMax.height = ( viewMiddle.contentHeight / 100 ) * (100- opt.valueMax )
		
		viewFillMax.x = viewTop.x
		viewFillMax.y = viewTop.y + ( viewFillMax.contentHeight * 0.5 ) + ( viewTop.contentHeight * 0.5 )
	end


	-- Position the slider's handle
	viewHandle.x = viewTop.x
	
	if opt.defaultValue < 1 then
		viewHandle.y = viewBottom.y - ( viewBottom.contentHeight * 0.5 )
	else
		viewHandle.y = viewFill.y - ( viewFill.contentHeight * 0.5 )
	end
	
	-- Edit by paulo
	if viewHandlemax then
		viewHandlemax.x = viewTop.x;
		
		if opt.valueMax < 1 then
			viewHandlemax.y = viewTop.y - ( viewTop.contentHeight * 0.5 )
		else
			viewHandlemax.y = viewFillMax.y + ( viewFillMax.contentHeight * 0.5 )
		end
	end
	-------------------------------------------------------
	-- Assign properties to the view
	-------------------------------------------------------
	
	-- We need to assign these properties to the object
	view._top = viewTop
	view._bottom = viewBottom
	view._fill = viewFill
	view._middle = viewMiddle
	view._handle = viewHandle
	view._currentPercent = opt.defaultValue
	view._currentPercentMax = opt.valueMax;

	view._width = opt.width
	view._height = opt.height
	view._listener = opt.listener
	-- Edit by Paulo
	view._handleMax = viewHandlemax;
	view._fillMax = viewFillMax;

	-------------------------------------------------------
	-- Assign properties/objects to the slider
	-------------------------------------------------------
	
	-- Assign objects to the slider
	slider._imageSheet = imageSheet
	slider._view = view	
	slider.value = view._currentPercent;
	slider.valueMax = view._currentPercentMax;
	
	----------------------------------------------------------
	--	PUBLIC METHODS	
	----------------------------------------------------------
	
	-- Function to set the slider's value
	function slider:setValue( value )
		self.value = value
		return self._view:_setValue( value )
	end
	function slider:setValueMax( value )
		self.valueMax = value
		return self._view:setValueMax( value )
	end
	----------------------------------------------------------
	--	PRIVATE METHODS	
	----------------------------------------------------------

	-- Touch listener for our slider
	function view.touch( event )
		local phase = event.phase
		local _slider = event.target.parent.parent
		-- Set the target to the handle
		local self = view;
		local t = event.target;
		local isHandleMin = t == self._handle;

		
		if "began" == phase then
			-- The content bounds of our handle
			local bounds = t.contentBounds
			
			-- If the touch event is within the boundary of the handle
			if event.y > bounds.yMin and event.y < bounds.yMax then
				touchBeganOnHandle = true
			end
			
			-- If the touch began on the handle
			if touchBeganOnHandle then
				display.getCurrentStage():setFocus( t, event.id )
				self._isFocus = true
			
				-- Store the initial position
				t.y0 = event.y - t.y
			end
			
		elseif self._isFocus then
			if "moved" == phase then
				-- Update the position
				t.y = event.y - t.y0
				-- Limit the handle to stop at either end of the slider
				if isDoubleSlider == true then
					if isHandleMin == true then
						if t.y <= self._handleMax.y + self._handleMax.height*0.5  then
							t.y = self._handleMax.y + self._handleMax.height*0.5
						elseif t.y >= self._bottom.y - ( self._bottom.contentHeight * 0.5 ) then
							t.y = self._bottom.y - ( self._bottom.contentHeight * 0.5 )
						end
					else
						if t.y <= self._top.y + ( self._top.contentHeight * 0.5 ) then
							t.y = self._top.y + ( self._top.contentHeight * 0.5 )
						elseif t.y >= self._handle.y - self._handle.height*0.5 then
							t.y = self._handle.y - self._handle.height*0.5
						end

					end
				else
					if t.y <= self._top.y + ( self._top.contentHeight * 0.5 ) then
						t.y = self._top.y + ( self._top.contentHeight * 0.5 )
					elseif t.y >= self._bottom.y - ( self._bottom.contentHeight * 0.5 ) then
						t.y = self._bottom.y - ( self._bottom.contentHeight * 0.5 )
					end
				end


				
				-- Get handle position
				local handlePosition = ( t.y - self._top.y - self._top.contentHeight * 0.5 ) 

				-- Calculate the current percent
				
				if isHandleMin == true then
					self._currentPercent = 100 - ( ( handlePosition * 100 ) / ( ( self._height - self._top.contentHeight ) - ( self._bottom.contentHeight ) ) )
				else
					self._currentPercentMax = 100 - ( ( handlePosition * 100 ) / ( ( self._height - self._top.contentHeight ) - ( self._bottom.contentHeight ) ) )
				end

				-- Set the fill's height
				if isHandleMin == true then
					self._fill.height = self._height - self._top.contentHeight - ( self._bottom.contentHeight ) - handlePosition
					-- Get the fills new vertical position
					local fillYPos = t.y + ( self._fill.contentHeight * 0.5 )
					
					-- Set the fill's position
					self._fill.y = fillYPos		
				else

					self._fillMax.height = ( self._middle.contentHeight / 100 ) * (100- self._currentPercentMax )
		
					self._fillMax.y = self._top.y + ( self._fillMax.contentHeight * 0.5 ) + ( self._top.contentHeight * 0.5 )

					
				end

						
			
			elseif "ended" == phase or "cancelled" == phase then
				-- Remove focus
				display.getCurrentStage():setFocus( nil )
				self._isFocus = false
			end
			
		end
		
		-- Execute the listener ( if any )
		if self._listener then
			local newEvent = 
			{ 
				name = event.name,
				phase = event.phase,
				value = mRound( self._currentPercent ),
				valueMax = self._currentPercentMax~= nil and mRound( self._currentPercentMax ) or 0,
				target = self,
			}
			self._listener( newEvent )
		end
		
		return true
	end
	
	view._handle:addEventListener( "touch" ,view.touch);
	if view._handleMax then
		view._handleMax:addEventListener( "touch" ,view.touch);
	end
	
	-- Function to set the sliders value
	function view:_setValue( value )
		self._fill.height = ( self._middle.contentHeight / 100 ) * value
		self._fill.x = self._top.x
		self._fill.y = self._bottom.y - ( self._fill.contentHeight * 0.5 ) - ( self._bottom.contentHeight * 0.5 )
		
		self._handle.x = self._top.x
		
		if value < 1 then
			self._fill.height = 1
			self._fill.y = self._bottom.y - ( self._fill.contentHeight * 0.5 ) - ( self._bottom.contentHeight * 0.5 )
			self._handle.y = self._bottom.y - ( self._bottom.contentHeight * 0.5 )
		else
			self._handle.y = self._fill.y - ( self._fill.contentHeight * 0.5 )
		end
		
		self._currentPercent = value
	end
	-- Function to set the sliders value
	function view:_setValueMax( value )
		self._fillMax.height = ( self._middle.contentHeight / 100 ) * (100- value )
		
		self._fillMax.y = self._top.y + ( self._fillMax.contentHeight * 0.5 ) + ( self._top.contentHeight * 0.5 )
		if opt.valueMax < 1 then
			view._handleMax.y = view._top.y - ( view._top.contentHeight * 0.5 )
		else
			view._handleMax.y = self._fillMax.y + ( self._fillMax.contentHeight * 0.5 )
		end

		self._currentPercentMax = value
	end
	-- Finalize function for the slider
	function slider:_finalize()
		-- Set slider's ImageSheet to nil
		self._imageSheet = nil
	end
			
	return slider
end


-- Function to create a new Slider object ( widget.newSlider )
function M.new( options, theme )	

	local customOptions = options or {}
	local themeOptions = theme or {}
	
	-- Create a local reference to our options table
	local opt = M._options
	
	-- Check if the requirements for creating a widget has been met (throws an error if not)
	_widget._checkRequirements( customOptions, themeOptions, M._widgetName )
	
	-------------------------------------------------------
	-- Properties
	-------------------------------------------------------
	-- EDIT BY PAULO
	opt.doubleSlider = customOptions.doubleSlider or false;
	opt.valueMax = customOptions.valueMax or 100;
	
	-- Positioning & properties
	opt.left = customOptions.left or 0
	opt.top = customOptions.top or 0
	opt.x = customOptions.x or nil
	opt.y = customOptions.y or nil
	if customOptions.x and customOptions.y then
		opt.left = 0
		opt.top = 0
	end
	opt.width = customOptions.width or themeOptions.width or 200 -- from the sheet file
	opt.height = customOptions.height or themeOptions.height or 10 -- from the sheet file
	opt.id = customOptions.id
	opt.baseDir = customOptions.baseDir or system.ResourceDirectory
	opt.defaultValue = customOptions.value or 1;
	opt.orientation = customOptions.orientation or "horizontal"
	opt.listener = customOptions.listener
	
	-- Frames & Images
	opt.sheet = customOptions.sheet
	opt.themeSheetFile = themeOptions.sheet
	opt.themeData = themeOptions.data
	
	opt.leftFrame = customOptions.leftFrame or _widget._getFrameIndex( themeOptions, themeOptions.leftFrame )
	opt.rightFrame = customOptions.rightFrame or _widget._getFrameIndex( themeOptions, themeOptions.rightFrame )
	opt.middleFrame = customOptions.middleFrame or _widget._getFrameIndex( themeOptions, themeOptions.middleFrame )
	opt.fillFrame = customOptions.fillFrame or _widget._getFrameIndex( themeOptions, themeOptions.fillFrame )
	opt.frameWidth = customOptions.frameWidth or themeOptions.frameWidth
	opt.frameHeight = customOptions.frameHeight or themeOptions.frameHeight
	opt.handleFrame = customOptions.handleFrame or _widget._getFrameIndex( themeOptions, themeOptions.handleFrame )
	opt.handleWidth = customOptions.handleWidth or theme.handleWidth
	opt.handleHeight = customOptions.handleHeight or theme.handleHeight
	
	opt.topFrame = customOptions.topFrame or _widget._getFrameIndex( themeOptions, themeOptions.topFrame )
	opt.bottomFrame = customOptions.bottomFrame or _widget._getFrameIndex( themeOptions, themeOptions.bottomFrame )
	opt.middleVerticalFrame = customOptions.middleVerticalFrame or _widget._getFrameIndex( themeOptions, themeOptions.middleVerticalFrame )
	opt.fillVerticalFrame = customOptions.fillVerticalFrame or _widget._getFrameIndex( themeOptions, themeOptions.fillVerticalFrame )
	
	-- Throw an error if the user hasn't passed in a width or height (depending on orientation)
	if "horizontal" == opt.orientation then
		if not opt.width then
			error( "ERROR: " .. M._widgetName .. ": width expected, got nil", 3 )
		end
	elseif "vertical" == opt.orientation then
		if not opt.height then
			error( "ERROR: " .. M._widgetName .. ": height expected, got nil", 3 )
		end
	else
		error( "ERROR: " .. M._widgetName .. ": Unexpected orientation" .. M._widgetName .. " supports either 'horizonal' or 'vertical' for the orientation", 3 )
	end
	
	-------------------------------------------------------
	-- Create the slider
	-------------------------------------------------------
		
	-- Create the slider object
	local slider = _widget._new
	{
		left = opt.left,
		top = opt.top,
		id = opt.id or "widget_slider",
		baseDir = opt.baseDir,
		doubleSlider = options.doubleSlider,
	}

	-- Create the slider
	if "horizontal" == opt.orientation then
		createHorizontalSlider( slider, opt ,options.doubleSlider)
	else
		createVerticalSlider( slider, opt ,options.doubleSlider)
	end
	
	-- Set the slider's position ( set the reference point to center, just to be sure )
	
	if ( isGraphicsV1 ) then
		slider:setReferencePoint( display.CenterReferencePoint )
	end
	-- CHANGED BY PAULO
	--local x, y = _widget._calculatePosition( slider, opt )

	slider.x, slider.y = 0, 0;
		
	return slider
end

return M