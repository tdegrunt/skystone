require 'java'

class org::bukkit::inventory::ItemStack

  def to_string
    if self.respond_to? :get_type_id
      "#{get_type_id}:#{get_data.get_data}"
    else
      "#{get_item_type_id}:#{get_data.get_data}"
    end
  end

end