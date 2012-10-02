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
      command(me, args)
    end

    @storage_cart_system = SkyStone::StorageCartSystem.new(self)
    @cart_routes = SkyStone::CartRoutes.new(self)
  end

  def command(player, arguments)

    subcommand = arguments.shift

    case subcommand.to_sym
    when :route
      @cart_routes.command(player, arguments)
    when :storage
      @storage_cart_system.command(player, arguments)
    end
  end

end