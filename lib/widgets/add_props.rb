# frozen_string_literal: true

class AddProps
  def self.form_config(form)
    form.selection :additional_properties, count: 0..Float::INFINITY
  end

  def self.hash_props(props)
    hash = {}
    for p in props
      hash[p[:key]] = p[:value]
    end
    return hash
  end
end
