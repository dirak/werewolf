function player_vote()
    --
    local players = player.GetAll()
    local players_count = #player.GetAll()
    local debug = false
    if debug then
        players_count = 15
        players = {"dirak1", "dirak2", "dirak3","dirak4", "dirak5", "dirak6","dirak7", "dirak8", "dirak","dirak", "dirak", "dirak","dirak", "dirak", "diffffrak"}
    end
    local player_icon_size_w = 64
    local player_icon_size_h = 32
    local vertical_padding = 30
    local horizontal_padding = 2
    local players_per_row = 4
    --calculate how many rows

    local rows = math.ceil(players_count / players_per_row)--we want to overshoot
    print(rows * player_icon_size_h)
    Ready = vgui.Create( "DFrame" ) --Define ready as a "DFrame"
    Ready:SetPos( ScrW() / 2, ScrH() / 2 ) --Set the position. Half the screen height and half the screen width. This will result in being bottom right of the middle of the screen.
    Ready:SetSize( player_icon_size_w * players_per_row + horizontal_padding * (players_per_row-1), vertical_padding + rows * (player_icon_size_h) ) --The size, in pixels of the Frame
    Ready:SetTitle("Vote on who to exile" ) --The title; It's at the top.
    Ready:SetVisible( true ) -- Should it be seen?
    Ready:SetDraggable( true ) -- Can people drag it around?
    Ready:ShowCloseButton( false ) --Show the little X top right? I chose no, because I have no alternative, meaning people would roam around with no weapons
    Ready:MakePopup() --Make it popup. Of course.
    local position_y = 0
    for k,v in pairs(players) do
        local cur_player = v
        tmp_player = vgui.Create( "DButton", Ready ) -- Define ready1 as a "DButton" with its parent the Ready frame we just created above.
        local position_x = math.fmod(k, players_per_row)
        if position_x == 0 then
            position_x = players_per_row
        elseif position_x == 1 then
            position_y = position_y + 1
        end
        print(k, position_x)
        tmp_player:SetPos( (position_x-1) * player_icon_size_w + horizontal_padding, position_y * vertical_padding ) --Set position, relative to the frame (If you didn't parent it, it would be relative to the screen
        tmp_player:SetSize( player_icon_size_w , player_icon_size_h ) -- How big it should be, again in pixels
        if debug then
            tmp_player:SetText( v )
        else
            tmp_player:SetText( v:Name() )
        end
        tmp_player.DoClick = function()
            RunConsoleCommand("ww_day_pick", v)
            Ready:Close()
        end
    end
end

concommand.Add( "sb_test", player_vote )
