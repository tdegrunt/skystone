require_relative 'orientation'

module SkyStone
  class CartsRouter

    include Orientation

    def initialize(plugin)
      @plugin = plugin

      plugin.event(:vehicle_move) do |event|
        moved_a_whole_block?(event) do |from, to|
          check(to.get_block, event.get_vehicle, from.get_block, get_direction(from, to))
        end
      end

      plugin.event(:player_interact) do |event|
        if event.respond_to?(:get_clicked_block) && event.get_clicked_block
          if event.get_clicked_block.is?(:stone_button)
            button = event.get_clicked_block.get_state.get_data
            attached = event.get_clicked_block.get_relative(button.get_attached_face)

            #if there's a lapis_block adjacent the attached block
            #if attached.block_at_real(:down).is?(:lapis_block)
            if find_and_return(:lapis_block, attached)
              destination = string_from_block(attached)
              player_route[event.player.name] = destination
              event.player.msg "You've selected destination: #{destination_name(destination)}/'#{destination_name(destination, true)}'"
            end
          end
        end
      end

      plugin.event(:vehicle_exit) do |event|
        player = event.get_vehicle.get_passenger
        if player_route[player.name] != default_route
          player.msg "Reset your route to #{destination_name(default_route)}/'#{destination_name(default_route, true)}' (was: #{destination_name(player_route[player.name])}/'#{destination_name(player_route[player.name], true)}')"
          player_route.delete(player.name)
        end
      end

    end

    def get_direction(from, to)
      case
      when to.get_z.to_i < from.get_z.to_i
        :north
      when to.get_z.to_i > from.get_z.to_i
        :south
      when to.get_x.to_i < from.get_x.to_i
        :west
      when to.get_x.to_i > from.get_x.to_i
        :east
      end
    end

    def check(block, cart, from, moving_direction)
      # base is event's base block (likely a powered rails)
      # for balancing it could be better to have a detector rails in front of the powered and have that trigger it?

      if block.is?(:detector_rail)
        #debug "Detector rail detected - player moving #{moving_direction}"
        base = block.block_at_real(:down)

        # find the control block - the block of lapis
        if control_block = find_and_return_control_block(:lapis_block, base)
          #debug "Controlblock detected"

          if player = cart.get_passenger
            player_holds_item = string_from_block(player.get_item_in_hand.get_data)

            # FIXME: Needs to be abstracted in a single routine and always return a destination.
            # Possibly eject + message player if it can't find a destination?
            direction_hint = find_and_return_direction(moving_direction, control_block, player_holds_item)
            unless direction_hint
              direction_hint = find_and_return_direction(moving_direction, control_block, player_route[player.name])
            end
            unless direction_hint
              direction_hint = moving_direction
            end
            #player.msg "Routing, going #{get_direction(control_block, control_block.block_at_real(wind, pos))}"


            # Array locations are:
            # 32
            # 41
            # and x y z per sub-array.
            rails_positions = {}
            rails_positions[:north] = [[0, 0, -2], [0, 0, -4], [-2, 0, -4], [-2, 0, -2]]
            rails_positions[:south] = [[0, 0, 2], [0, 0, 4], [2, 0, 4], [2, 0, 2]]
            rails_positions[:east] = [[2, 0, 0], [4, 0, 0], [4, 0, -2], [2, 0, -2]]
            rails_positions[:west] = [[-2, 0, 0], [-4, 0, 0], [-4, 0, 2], [-2, 0, 2]]

            moves = {}
            # moving north
            moves[[:north, :north]] = [0, 0]
            moves[[:north, :east]] = [6]
            moves[[:north, :west]] = [0, 7, 1]
            moves[[:north, :south]] = [0, 7, 6, 0]

            # moving east
            moves[[:east, :east]] = [1, 1]
            moves[[:east, :north]] = [1, 8, 0]
            moves[[:east, :west]] = [1, 8, 7, 1]
            moves[[:east, :south]] = [7]

            # moving south
            moves[[:south, :east]] = [0, 9, 1]
            moves[[:south, :north]] = [0, 9, 8, 0]
            moves[[:south, :west]] = [8]
            moves[[:south, :south]] = [0, 0]

            # moving west
            moves[[:west, :east]] = [1, 6, 9, 1]
            moves[[:west, :north]] = [9]
            moves[[:west, :west]] = [1, 1]
            moves[[:west, :south]] = [1, 6, 0]

            changes = moves[[moving_direction, direction_hint]]
            block_pos = rails_positions[moving_direction]

            (0..3).each do |pos|
              if changes[pos]
                #debug "setting rail #{pos}"
                set_dir(block.get_relative(block_pos[pos][0], block_pos[pos][1], block_pos[pos][2]), changes[pos])
              end
            end

          end
        end
      end
    end

    def set_dir(rails, direction)
      if rails.is?(:rails)
        set_rails_direction(rails, direction)
      else
        debug "Not rails #{rails.get_x} #{rails.get_y} #{rails.get_z}"
      end
    end

    def set_rails_direction(rails, direction)
      rails.set_data direction
    end

    def find_and_return_direction(moving_direction, control_block, selected_destination)
      (2..25).each do |pos|
        wind_rotations_for(moving_direction).each do |wind|
          # prevent errors in case of no block
          possible_routing_block = control_block.block_at_real(wind, pos)
          if possible_routing_block
            routing = string_from_block(possible_routing_block)

            if all_destinations(:value).include?(routing) && routing == selected_destination
              return get_direction(control_block, possible_routing_block)
            end
          end
        end
      end
      false
    end

    def string_from_block(block)
      if block.respond_to? :get_type_id
        "#{block.get_type_id}:#{block.get_data}"
      else
        "#{block.get_item_type_id}:#{block.get_data}"
      end
    end


    def item_stacks_from_hash(hash)
      hash.map{|k,v| v}
    end

    # find the control (lapis) block, from the base
    # java: Block getRelative(int modX, int modY, int modZ)
    def find_and_return_control_block(type, block)
      case
      when block.get_relative(1, 0, 3).is?(type)
        block.get_relative(1, 0, 3)
      when block.get_relative(-1, 0, 3).is?(type)
        block.get_relative(-1, 0, 3)
      when block.get_relative(1, 0, -3).is?(type)
        block.get_relative(1, 0, -3)
      when block.get_relative(-1, 0, -3).is?(type)
        block.get_relative(-1, 0, -3)
      when block.get_relative(3, 0, 1).is?(type)
        block.get_relative(3, 0, 1)
      when block.get_relative(3, 0, -1).is?(type)
        block.get_relative(3, 0, -1)
      when block.get_relative(-3, 0, 1).is?(type)
        block.get_relative(-3, 0, 1)
      when block.get_relative(-3, 0, -1).is?(type)
        block.get_relative(-3, 0, -1)
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

    # Fired when a player types /skystone route
    def cmd(player, arguments)
      command = arguments.shift
      if all_destinations(:short).include?(command)
        destination_value = destination_value_for_short(command)
        player_route[player.name] = destination_value
        player.msg "Your new destination is #{destination_name(destination_value)}/'#{destination_name(destination_value, true)}'"
      end
    end

    private

    # Indexed with player.name
    def player_route
      @player_route ||= Hash.new(default_route)
    end

    # Indexed with [x, y, z] of control-block
    def switch
      @switch ||= Hash.new({:in_use_by => ''})
    end

    def plugin
      @plugin
    end

    def debug(text)
      plugin.server.broadcast_message "CartRoutes: #{text}"
    end

    def config
      plugin.config
    end

    def destination_name(destination, short = false)
      if short
        config.get!("carts.router.destinations.#{destination}.short", destination)
      else
        config.get!("carts.router.destinations.#{destination}.name", destination)
      end
    end

    def destination_value_for_short(short)
      all_destinations.select do |d|
        config.get!("carts.router.destinations.#{d}.short", d) == short
      end[0]
    end

    def all_destinations(how = :value)
      destinations = Array.new(config.get!('carts.router.destinations',{}).get_keys(false).to_array)
      case how
      when :value
        destinations
      when :short
        destinations.map do |d|
          config.get!("carts.router.destinations.#{d}.short", d)
        end
      when :name
        destinations.map do |d|
          config.get!("carts.router.destinations.#{d}.name", d)
        end
      end
    end

    def default_route
      config.get!('carts.router.home', '35:0')
    end

    # Check that we moved a whole block, this prevents multiple events fired for moving from the same X,Y,Z coordinates
    def moved_a_whole_block?(event)
      to = event.get_to
      from = event.get_from
      if to.get_x.to_i != from.get_x.to_i || to.get_y.to_i != from.get_y.to_i || to.get_z.to_i != from.get_z.to_i
        yield from, to
      end
    end
  end
end