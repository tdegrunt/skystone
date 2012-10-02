module SkyStone
  class Transceiver < SystemBlock
    class << self
      def initialize(options)
        @base = options[:base] || raise "Base required"
        @chest = options[:chest] || raise "Chest required"
        materials = options[:materials] || raise "Materials required"
        @materials = materials.downcase.gsub(/[^a-z_]/, " ").split(" ").uniq.compact.map(&:to_sym)
      end

      def process_vehicle_move(event)
        vehicle = event.get_vehicle
        if vehicle.respond_to?(:get_inventory)
          if @base.is_block_powered?
            Inventory.move_items(vehicle.get_inventory, chest.get_state.get_inventory, @materials)
          else
            Inventory.move_items(chest.get_state.get_inventory, vehicle.get_inventory, @materials)
          end
        end
      end

      def me?(block)
        base = block.block_at(:down)  
        if base.is?(:iron_block)
          chest = find_and_return(:chest, base)
          sign = find_and_return(:wall_sign, base)

          if chest && sign && sign.get_state_get_line(0).downcase == "[transceiver]"
            new {base: base, chest: chest, materials: [sign.get_state.get_line(1),sign.get_state.get_line(2),sign.get_state.get_line(3)].join(" ")}
          end
        end
        false
      end
    end
  end
end
