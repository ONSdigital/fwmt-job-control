# frozen_string_literal: true

class IDGenerator
  def self.form_config(form)
    form.field :id_kind,       present: true, regexp: %r{^(single|list|incr|rand)$}
    # use one ID (single job only)
    form.field :id_single,     present: false, filters: :strip
    # provide a list of IDs
    form.field :id_list,       present: false, filters: :strip
    # pick IDs above the start
    form.field :id_incr_start, present: false, filters: :strip
    # or, randomly generate IDs
  end

  def initialize(kind, id_single = nil, id_list = nil, id_incr_start = nil)
    raise ArgumentError, 'invalid kind' unless %w[single list incr rand].include?(kind)

    @last_id = 0
    case kind
    when 'single'
      @kind = :single
      @last_id = id_single
    when 'list'
      @kind = :list
      raise ArgumentError, 'id list not set' if id_list.nil?
      raise ArgumentError, 'id list not a list' unless id_list.is_a?(Array)

      @id_list = id_list
      @index = 0
    when 'incr'
      @kind = :incr
      raise ArgumentError, 'id start point is not set' if id_incr_start.nil?
      raise ArgumentError, 'id start point is not a string' unless id_incr_start.is_a?(String)
      raise ArgumentError, 'id start point is not a numeric string' unless %r{/[0-9]+/} =~ Integer(id_incr_start)

      @last_id = id_incr_start
    when 'rand'
      @kind = :rand
    end
  end

  def self.from_form(form)
    return IDGenerator.new(form[:id_kind], form[:id_single], form[:id_list], form[:id_incr_start])
  end

  def generate
    case @kind
    when :single
      id = @last_id
    when :list
      id = @id_list[@index]
      @index += 1
    when :incr
      id = (@last_id.to_i + 1).to_s
    when :rand
      id = SecureRandom.hex(4)
    end
    @last_id = id
    id
  end
end
