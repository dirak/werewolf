function set_team()
	--
	Ready = vgui.Create( "DFrame" ) --Define ready as a "DFrame"
	Ready:SetPos( ScrW() / 2, ScrH() / 2 ) --Set the position. Half the screen height and half the screen width. This will result in being bottom right of the middle of the screen.
	Ready:SetSize( 175, 75 ) --The size, in pixels of the Frame
	Ready:SetTitle( "Test" ) --The title; It's at the top.
	Ready:SetVisible( true ) -- Should it be seen?
	Ready:SetDraggable( false ) -- Can people drag it around?
	Ready:ShowCloseButton( false ) --Show the little X top right? I chose no, because I have no alternative, meaning people would roam around with no weapons
	Ready:MakePopup() --Make it popup. Of course.

	ready1 = vgui.Create( "DButton", Ready ) -- Define ready1 as a "DButton" with its parent the Ready frame we just created above.
	ready1:SetPos( 20, 25 ) --Set position, relative to the frame (If you didn't parent it, it would be relative to the screen
	ready1:SetSize( 140, 40 ) -- How big it should be, again in pixels
	ready1:SetText( "Button" ) --What should the button say?
	ready1.DoClick = function() --ready1.doclick = function, we just defined it as a function
		RunConsoleCommand( "ww_team_villager" ) --When it clicks, which function does it run? sb_team1, which is defined in init.lua
		Ready:Close()--Close it after we join a team
	end
end
