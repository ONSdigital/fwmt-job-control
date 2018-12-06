# frozen_string_literal: true

class TMServer
  def self.form_config(form)
    form.field :server,   present: false, filters: :strip
    form.field :username, present: false, filters: :strip
    form.field :password, present: false, filters: :strip
    form.field :vhost,    present: false, filters: :strip
  end
end
