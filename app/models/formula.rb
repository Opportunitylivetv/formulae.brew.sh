# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2018, Sebastian Staudt

class Formula

  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :_id, type: String, overwrite: true
  field :aliases, type: Array
  field :date, type: Time
  field :description, type: String
  field :devel_version, type: String
  field :head_version, type: String
  field :keg_only, type: Boolean, default: false
  field :removed, type: Boolean, default: false
  field :name, type: String
  field :homepage, type: String
  field :revision, type: Integer
  field :stable_version, type: String

  after_build :set_id

  alias to_param name

  belongs_to :repository, validate: false
  has_and_belongs_to_many :revisions, inverse_of: nil, validate: false,
                                      index: true

  embeds_many :deps, class_name: Dependency.to_s, validate: false

  scope :letter, ->(letter) { where(name: /^#{letter}/) }

  index({ repository_id: 1 }, unique: false)
  index({ name: 1 }, unique: false)

  def best_spec
    if stable_version
      :stable
    elsif devel_version
      :devel
    elsif head_version
      :head
    end
  end

  def dupe?
    self.class.where(name: name).size > 1
  end

  def path
    (repository.formula_path.nil? ? name : File.join(repository.formula_path, name)) + '.rb'
  end

  def raw_url
    "https://raw.github.com/#{repository.name}/HEAD/#{path}"
  end

  def generate_history!
    revisions.clear
    repository.generate_formula_history self
  end

  def update_dependencies(formula_info)
    deps = formula_info['dependencies']
    return if deps.empty?

    build_deps = formula_info['build_dependencies']
    optional_deps = formula_info['optional_dependencies']
    recommended_deps = formula_info['recommended_dependencies']
    runtime_deps = deps - optional_deps - recommended_deps - build_deps

    self.deps = build_deps.map { |dep| Dependency.build dep }
    self.deps += optional_deps.map { |dep| Dependency.optional dep }
    self.deps += recommended_deps.map { |dep| Dependency.recommended dep }
    self.deps += runtime_deps.map { |dep| Dependency.runtime dep }
  end

  def update_metadata(formula_info)
    self.description = formula_info['desc']
    self.homepage = formula_info['homepage']
    self.keg_only = formula_info['keg_only']
    self.stable_version = formula_info['versions']['stable']
    self.devel_version = formula_info['versions']['devel']
    self.head_version = formula_info['versions']['head']
    self.revision = formula_info['revision']

    update_dependencies formula_info
  end

  def version
    stable_version || devel_version || head_version
  end

  def versions
    [stable_version, devel_version, head_version].compact
  end

  def set_id
    self._id = "#{repository.name}/#{name}"
  end

end
