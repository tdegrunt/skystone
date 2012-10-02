module SkyStone

  class StorageCartSystem
    def initialize(plugin)
      @plugin = plugin

      plugin.event(:vehicle_move) do |event|
        to = event.get_to
        from = event.get_from
        if to.get_x.to_i != from.get_x.to_i || to.get_y.to_i != from.get_y.to_i || to.get_z.to_i != from.get_z.to_i
          check(to.get_block, event.get_vehicle)
        end
      end

    end

    def check(block, cart)
      base = block.block_at(:down)

      if base.is?(:lapis_block)
        chest = find_and_return(:chest,base)
        sign = find_and_return(:wall_sign,base)
        if chest && sign
          if cart.respond_to?(:get_inventory)

            item = sign.get_state.get_line(0).to_sym

            debug "looking for #{item}"

            inventory = cart.get_inventory
            contents = inventory.get_contents
            overflow = []
            contents.each do |item_stack|
              if item_stack.respond_to?(:get_type) && item_stack.get_type.is?(item)
                debug "#{item} detected"
                inventory.remove_item item_stack
                overflow += item_stacks_from_hash(chest.get_state.get_inventory.add_item(item_stack))
              end
            end
            overflow.each { |item_stack| inventory.add_item(item_stack) }
          end
        end
      end
    end



    def item_stacks_from_hash(hash)
      hash.map{|k,v| v}
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

    def debug(text)
      @plugin.server.broadcast_message "StorageCartSystem: #{text}"
    end
  end

end