module SkyStone
  class SystemBlock
    class << self
      def me?(block)
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

      def plugin
        @plugin ||= Plugin.new
      end
    end
  end
end