require_relative 'orientation'
require_relative 'vehicle_move_event'
require_relative 'inventory'

module SkyStone
  class ChestFilter

    include Orientation

    def initialize(plugin)
      @plugin = plugin

      plugin.event(:vehicle_move) do |event|
        event.moved_a_whole_block? do |from, to|
          check(to.get_block, event.get_vehicle, from.get_block, get_direction(from, to))
        end
      end

    end

    def check(block, cart, from, moving_direction)
      # base is event's base block (likely a powered rails)
      # for balancing it could be better to have a detector rails in front of the powered and have that trigger it?

      if cart.respond_to?(:get_inventory) && block.is?(:detector_rail)
        #debug "Detector rail detected - chest moving #{moving_direction}"
        base = block

        if control_block = find_and_return(:lapis_block, base)
          #debug "Controlblock detected - chest moving #{moving_direction}"

          if first_chest_block = find_and_return(:chest, base)
            debug "Chest detected - we have a filter"

            (0..10).each do |pos|
              chest_block = first_chest_block.block_at_real(:up, pos)
              check_and_move(chest_block, cart, pos)
            end

          end
        end
      end
    end

    def check_and_move(chest_block, cart, pos)
      if chest_block.is?(:chest)
        chest = chest_block.get_state
        inventory = chest.get_inventory
        if first_item = inventory.get_item(0)
          move_what = first_item.get_type.to_string.downcase.to_sym
          debug "moving #{move_what}"
          Inventory.move_items(cart.get_inventory, inventory, move_what)
        end
      end
    end

    def plugin
      @plugin
    end

    def debug(text)
      plugin.server.broadcast_message "ChestFilter: #{text}"
    end

  end
end