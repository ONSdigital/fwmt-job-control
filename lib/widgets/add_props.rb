# frozen_string_literal: true

class AddProps
  def self.form_config(form)
    form.selection :additional_properties, {}
  end

  def self.hash_props(props)
    hash = {}
    return hash if props == nil
    for p in props
      hash[p[:key]] = p[:value]
    end
    return hash
  end
end
