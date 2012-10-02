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

    public_command('skystone', 'Skystone', '/skystone ...') do |me, *args|
      player_command(me, args)
    end

    @storage_cart_system = SkyStone::StorageCartSystem.new(self)
    @cart_routes = SkyStone::CartRoutes.new(self)
  end

  def player_command(player, arguments)

    if arguments.length > 0
      subcommand = arguments.shift

      case subcommand.to_sym
      when :route
        @cart_routes.player_command(player, arguments)
      when :storage
        @storage_cart_system.player_command(player, arguments)
      end
    end
  end

end