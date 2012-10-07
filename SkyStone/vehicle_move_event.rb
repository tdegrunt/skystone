require 'java'

class org::bukkit::event::vehicle::VehicleMoveEvent

  def moved_a_whole_block?
    to = self.get_to
    from = self.get_from
    if to.get_x.to_i != from.get_x.to_i || to.get_y.to_i != from.get_y.to_i || to.get_z.to_i != from.get_z.to_i
      yield from, to
    end
  end

end
