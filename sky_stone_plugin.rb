require 'singleton'
#$:.unshift(File.expand_path(File.dirname(__FILE__))) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require_relative 'skystone/plugin'
require_relative 'skystone/storage_cart_system'
require_relative 'skystone/cart_routes'

class SkyStonePlugin
  include Purugin::Plugin, Purugin::Colors
  description 'SkyStone', 0.1

  def on_enable
    force_reload!

    @plugin = SkyStone::Plugin.instance
    @plugin.setup self
    @plugin.broadcast "Loaded 'SkyStone' plugin"

    public_player_command('skystone', 'Skystone', "/skystone ...") do |me, *args|
      cmd(me, args)
    end

    @storage_cart_system = SkyStone::StorageCartSystem.new(self)
    @cart_routes = SkyStone::CartRoutes.new(self)
  end

  private

  def cmd(player, arguments)
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

  def force_reload!
    load './skystone/plugin'
    load './skystone/storage_cart_system'
    load './skystone/cart_routes'
  end
end