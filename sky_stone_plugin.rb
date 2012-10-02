require 'singleton'

require_relative 'skystone/plugin'
require_relative 'skystone/storage_cart_system'
require_relative 'skystone/cart_routes'

class SkyStonePlugin
  include Purugin::Plugin, Purugin::Colors
  description 'SkyStone', 0.1

  def on_enable
    @plugin = SkyStone::Plugin.instance
    @plugin.setup self
    @plugin.broadcast "Loaded 'SkyStone' plugin"

    player_command('skystone', 'Skystone') do |me, *args|
      player_command(me, args)
    end

    @storage_cart_system = SkyStone::StorageCartSystem.new(self)
    @cart_routes = SkyStone::CartRoutes.new(self)
  end

  def cmd(player, *arguments)

    if arguments.length > 0
      subcommand = arguments.shift

      case subcommand.to_sym
      when :route
        @cart_routes.cmd(player, arguments)
      when :storage
        @storage_cart_system.cmd(player, arguments)
      end
    end
  end

end