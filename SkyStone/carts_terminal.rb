require_relative 'orientation'
require_relative 'vehicle_move_event'
require_relative 'block'
require 'java'

module SkyStone

  class RunnableProc
    include java.lang.Runnable
    def initialize &block
      @block = block
    end
    def run
      @block.call
    end
  end

  class CartsTerminal

    include Orientation

    def initialize(plugin)
      @plugin = plugin

      plugin.event(:vehicle_move) do |event|
        event.moved_a_whole_block? do |from, to|
          check(to.get_block, event.get_vehicle, from.get_block, get_direction(from, to))
        end
      end

      plugin.event(:player_interact) do |event|
        if event.respond_to?(:get_clicked_block) && event.get_clicked_block
          if event.get_clicked_block.is?(:stone_button)
            button = event.get_clicked_block.get_state.get_data
            attached = event.get_clicked_block.get_relative(button.get_attached_face)
            facing = face_to_wind(button.get_attached_face)

            if attached.block_at_side_for(facing, :left).block_at_real(:down).is?(:dispenser)
              dispenser = attached.block_at_side_for(facing, :left).block_at_real(:down)
              direction = :right
            end

            if attached.block_at_side_for(facing, :right).block_at_real(:down).is?(:dispenser)
              dispenser = attached.block_at_side_for(facing, :right).block_at_real(:down)
              direction = :left
            end

            if dispenser
              if control_block = find_and_return(:lapis_block, dispenser.block_at_real(:down))

                if control_block.block_at_real(:up).is?(:powered_rail)
                  powered_rail = control_block.block_at_real(:up)

                  normal_rail = powered_rail.block_at_side_for(facing, opposite_of(direction))

                  # TODO: Can we find out whether there is a vehicle on the rails, if not dispense?

                  normal_rail.change_type :sandstone
                  powered_rail.set_data powered_rail.get_data + 8

                  p=RunnableProc.new do
                    powered_rail.set_data powered_rail.get_data - 8
                    normal_rail.change_type :rails
                  end

                  schedule_task(p, 20)
                end

              end
            end
          end
        end
      end

      # plugin.event(:vehicle_exit) do |event|
      #   player = event.get_vehicle.get_passenger
      #   if player_route[player.name] != default_route
      #     player.msg "Reset your route to #{destination_name(default_route)}/'#{destination_name(default_route, true)}' (was: #{destination_name(player_route[player.name])}/'#{destination_name(player_route[player.name], true)}')"
      #     player_route.delete(player.name)
      #   end
      # end

    end

    def check(block, cart, from, moving_direction)
      # base is event's base block (likely a powered rails)
      # for balancing it could be better to have a detector rails in front of the powered and have that trigger it?

      if block.is?(:powered_rail)
        #debug "Powered rail detected - player moving #{moving_direction}"
        base = block

        if control_block = find_and_return(:lapis_block, base)
          #debug "Controlblock detected - player moving #{moving_direction}"

          if dispenser_block = find_and_return(:dispenser, base)
            dispenser = dispenser_block.get_state
            #debug "Dispenser detected - we have a terminal"
            #dispenser.dispense

            if control_block.block_at_real(:up).is?(:powered_rail)
              powered_rail = control_block.block_at_real(:up)

              normal_rail = powered_rail.block_at_real(opposite_of(moving_direction))

              cleanup=RunnableProc.new do
                powered_rail.set_data powered_rail.get_data - 8
                normal_rail.change_type :rails
              end

              get_player_moving=RunnableProc.new do
                normal_rail.change_type :sandstone
                powered_rail.set_data powered_rail.get_data + 8
                schedule_task(cleanup, 20)
              end

              # Hardcoded delay - 5 seconds to get out
              schedule_task(get_player_moving, 100)
            end

          end
        end
      end

    end

    def find_and_return(type, block)
      case
      when block.block_at_real(:north) && block.block_at_real(:north).is?(type)
        block.block_at_real(:north)
      when block.block_at_real(:east) && block.block_at_real(:east).is?(type)
        block.block_at_real(:east)
      when block.block_at_real(:south) && block.block_at_real(:south).is?(type)
        block.block_at_real(:south)
      when block.block_at_real(:west) && block.block_at_real(:west).is?(type)
        block.block_at_real(:west)
      when block.block_at_real(:up) && block.block_at_real(:up).is?(type)
        block.block_at_real(:up)
      when block.block_at_real(:down) && block.block_at_real(:down).is?(type)
        block.block_at_real(:down)
      end
    end

    def debug(text)
      plugin.server.broadcast_message "CartRoutes: #{text}"
    end

    def plugin
      @plugin
    end

    def scheduler
      plugin.server.get_scheduler
    end

    # 1 sec = 20 ticks
    def schedule_task(proc, delay = 20)
      scheduler.schedule_async_delayed_task(plugin, proc, delay)
    end

  end
end