require_relative "item_stack"

module SkyStone
  class Inventory
    class << self

      def move_items(from, to, materials = :all)
        overflow = []
        from.get_contents.each do |item_stack|
          if is_one_of_these_materials?(item_stack, materials)
            from.remove_item(item_stack)
            overflow += item_stacks_from_hash(to.add_item(item_stack))
          end
        end
        overflow.each { |item_stack| inventory.add_item(item_stack) }
      end

      private

      def is_one_of_these_materials?(item_stack, materials = :all)

        if item_stack.respond_to?(:get_type)
          if materials == :all
            return true
          end

          [*materials].each do |material|
            return true if item_stack.to_string == material
          end
        end
        false
      end

      def item_stacks_from_hash(hash)
        hash.map{|k,v| v}
      end
    end
  end
end