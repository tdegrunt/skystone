module SkyStone
  class Plugin
    include Singleton

    def setup(plugin)
      @plugin = plugin
    end

    def debug(text)
      broadcast "SkyStone: #{text}"
    end

    def event(*args)
      @plugin.event(*args)
    end

    def public_command(*args)
      @plugin.public_command(*args)
    end

    def broadcast(message, color = nil)
      message = case color
      when :red
        red(message)
      else
        message
      end

      @plugin.server.broadcast_message message
    end


    private

    def plugin
      @plugin
    end
  end
end