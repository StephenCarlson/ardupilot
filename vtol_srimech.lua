-- RoboWork Lab MiniHawk-VTOL Anti-Turtle Script
-- Steve Carlson July 2023

-- mavproxy.py --master=/dev/serial/by-id/usb-mRo_mRoPixracerPro_400049000951303035343937-if00 NosyNikki
-- mavproxy.py --master=/dev/serial/by-id/usb-mRo_mRoPixracerPro_42004B000951303035343937-if00 SunnyGoldy
-- mavproxy.py --master=/dev/serial/by-id/usb-mRo_mRoPixracerPro_3C0048000451303334323636-if00 MellowYellow
-- ftp put vtol_srimech.lua APM/scripts/vtol_srimech.lua
-- status SERVO_OUTPUT_RAW
-- ftp list APM/scripts
-- ftp get APM/scripts/srimech.lua
-- ftp rm APM/scripts/srimech.lua


-- R/C Control Channels
local rc_switch_trigger = assert(rc:find_channel_for_option(300), 'RCn_OPTION=300 for SriMech Flip Trigger')
local prev_trigger_sw = rc_switch_trigger:get_aux_switch_pos()
local prev_arming_state = arming:is_armed()

-- local channel_map = {33, 34, 0, 36, 75, 76, 77, 78} 
local tailMotor = 3 -- SRV_Channels:find_channel(36)

function init()

  return update, 0
end


function update()
  -- now = millis()

  local trigger_sw = rc_switch_trigger:get_aux_switch_pos()
  local arming_state = arming:is_armed()
  -- if (not arming_state) then
  if (rc:has_valid_input() == true) and (trigger_sw == 2) and (not vehicle:get_likely_flying()) then
    if prev_trigger_sw ~= trigger_sw then
      gcs:send_text(0,"---- SriMech Mode Active"..tailMotor)

      -- if(not util:get_soft_armed()) then
      motors:set_spoolup_block(false)
      rcout:disable_channel_mask_updates()
      rcout:send_dshot_command(21, tailMotor, 0, 10, true)
      motors:armed(true)
      util:set_soft_armed(true)
      -- end
    end

    throttle_requested = rc:get_pwm(3)
    -- gcs:send_text(0, "THR: "..throttle_requested)
    SRV_Channels:set_output_pwm_chan_timeout(tailMotor, throttle_requested, 200)
    -- for i = 0, #channel_map-1, 1 do
    --   SRV_Channels:set_output_pwm_chan_timeout(i, decoded[i], 200)
    -- end
  else
    if prev_trigger_sw ~= trigger_sw then
      gcs:send_text(0,"---- Normal Operation")

      -- if(util:get_soft_armed()) then
      motors:armed(false)
      util:set_soft_armed(false)
      rcout:send_dshot_command(20, tailMotor, 0, 10, true)
      rcout:enable_channel_mask_updates()
      -- end
    end
  end
  -- else
  --   -- Check if vehicle just armed and apply correct rotation
  --   if prev_arming_state ~= arming_state then
  --     gcs:send_text(0,"---- Normal Mode")
  --     -- if(util:get_soft_armed()) then
  --     motors:armed(false)
  --     rcout:send_dshot_command(20, tailMotor, 0, 10, true)
  --     util:enable_channel_mask_updates()
  --     -- end
  --   end
  -- end


  prev_trigger_sw = trigger_sw
  prev_arming_state = arming_state


  return update, 50 -- Loop
end
  
-- First-run Initialization
gcs:send_text(0, "Anti-Turtle Script")
return init, 1000