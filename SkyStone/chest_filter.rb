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
        debug "Detector rail detected - chest moving #{moving_direction}"
        base = block

        if control_block = find_and_return(:lapis_block, base)
          debug "Controlblock detected - chest moving #{moving_direction}"

          if chest_block = find_and_return(:chest, base)
            chest = chest_block.get_state
            debug "Chest detected - we have a filter"

            inventory = chest.get_inventory
            move_what = inventory.get_item(0).get_type.to_string.downcase.to_sym
            debug "Chest content #{move_what}"

            Inventory.move_items(cart.get_inventory, inventory, move_what)

          end
        end
      end
    end

    def plugin
      @plugin
    end

    def debug(text)
      plugin.server.broadcast_message "CartRoutes: #{text}"
    end

  end
end