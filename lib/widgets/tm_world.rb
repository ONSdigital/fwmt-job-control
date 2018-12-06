# frozen_string_literal: true

class TMWorld
  def self.form_config(form)
    form.field :tm_world,        present: true,  regexp: %r{^(Default|MOD WORLD|custom)$}, filters: :strip
    form.field :tm_world_custom, present: false, filters: :strip
    form.field :tm_world_type,   present: false, regexp: %r{^(manual|mendel)$}, filters: :strip
  end

  def self.world_from_form(form)
    case form[:tm_world]
    when 'custom'
      mendel = form[:tm_world_type] == 'mendel'
      return form[:tm_world_custom], mendel
    when 'Default'
      return 'Default', false
    when 'MOD WORLD'
      return 'MOD WORLD', true
    end
  end
end
