# frozen_string_literal: true

class SurveyType
  def self.form_config(form)
    form.field :survey_type, present: true, regexp: %r{^(CCS|HH|GFF|CE|LFS|OHS)$}, filters: :strip
  end
end
