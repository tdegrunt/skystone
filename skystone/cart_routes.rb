module SkyStone
  class CartRoutes
    def initialize
      plugin.event(:vehicle_move) do |event|
        to = event.get_to
        from = event.get_from

        if to.get_x.to_i != from.get_x.to_i || to.get_y.to_i != from.get_y.to_i || to.get_z.to_i != from.get_z.to_i
          check(to.get_block, event.get_vehicle, from.get_block, get_direction(from, to))
        end
      end

      plugin.event(:player_interact) do |event|
        if event.respond_to?(:get_clicked_block)
          if event.get_clicked_block.is?(:stone_button)
            event.player.msg "You clicked a stone button!"
          end
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
        base = block.block_at(:down)

        # find the control block - the block of lapis
        if control_block = find_and_return_control_block(:lapis_block, base)
          #debug "Controlblock detected"

          if player = cart.get_passenger
            player_holds_item = string_from_block(player.get_item_in_hand.get_data)
            #debug "Player detected, holding: #{player_holds_item} and moving #{moving_direction}"

            direction_hint = find_and_return_direction(control_block, player_holds_item)

            # Array locations are:
            # 32
            # 41

            # x y z
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

    def find_and_return_direction(control_block, destination_item)
      #control_block.
      [:south, :west, :north, :east].each do |wind|
        (2..10).each do |pos|
          control_item = string_from_block(control_block.block_at(wind, pos))
          #debug "Checking #{pos}: #{destination_item} == #{control_item}: #{wind}" unless control_item == "2:0"
          if control_item == destination_item
            debug "I guess i want to go: #{get_direction(control_block, control_block.block_at(wind, pos))}"
            return get_direction(control_block, control_block.block_at(wind, pos))
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

    # Theoretically a flexible find_and_return
    # FUK: THis calls for unit tests
    #
    # if distance = 2 && edges = true => only X && * will be found
    # if distance = 2 && edges = false => all will be found
    #
    # if distance = 2 && corners = true => only c will be found
    # if distance = 2 && corners = false => all will be found
    #
    #  cX*Xc
    #  X0+0X
    #  *+++*
    #  X0+0X
    #  cX*Xc
    #
    def find_and_return_flex(type, block, options)
      distance = options[:distance] ||= 1
      height = options[:height] ||= 0
      depth = options[:depth] ||= 0
      plane = options[:plane] ||= :all # :corners, :edges, :plus

      (-distance..distance).each do |x|
        (-depth..height).each do |y|
          (-distance..distance).each do |z|
            if ((plane == :all) ||
              (plane == :edges && (x.abs == distance || z.abs == distance)) ||
              (plane == :plus && (x == 0 || z == 0)) ||
              (plane == :corners && (x.abs == distance && y.abs == distance)))
              #debug "Checking #{x} #{y} #{z}: #{block.get_relative(x, y, z).is?(type)}"
              return block.get_relative(x, y, z) if block.get_relative(x, y, z).is?(type)
            end
          end
        end
      end
      false
    end

    def find_and_return(type, block)
      case
      when block.block_at(:north).is?(type)
        block.block_at(:north)
      when block.block_at(:east).is?(type)
        block.block_at(:east)
      when block.block_at(:south).is?(type)
        block.block_at(:south)
      when block.block_at(:west).is?(type)
        block.block_at(:west)
      end
    end

    # Fired when a player types /skystone route
    def cmd(player, arguments)
      plugin.broadcast "Look ma! #{player.name} sent me command #{arguments.first}"
    end

    private

    def plugin
      @plugin ||= Plugin.new
    end

    def debug(text)
      plugin.server.broadcast_message "CartRoutes: #{text}"
    end
  end
end