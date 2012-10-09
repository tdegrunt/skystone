require_relative 'orientation'
require_relative 'vehicle_move_event'
require_relative 'inventory'
require_relative 'block'

module SkyStone
  class CartPowerBooster

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

      if block.is?(:powered_rail) && block.normalize.is_powered
        base = block

        if org::bukkit::block::Block.fetch_from(base, :lapis_block)
          cart.set_slow_when_empty false
        end
      end
    end

    def plugin
      @plugin
    end

    def debug(text)
      plugin.server.broadcast_message "CartPowerBooster: #{text}"
    end

  end
end