# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2018, Sebastian Staudt

# Represents a single dependency of a formula to another formula
class Dependency

  include Mongoid::Document

  embedded_in :formula

  field :type, type: Integer

  BUILD = 0
  RUNTIME = 1
  RECOMMENDED = 2
  OPTIONAL = 3

  TYPES = %i[build runtime recommended optional].freeze

  def self.build(name)
    Dependency.new id: find_formula(name).id, type: BUILD
  end

  def self.find_formula(name)
    if name.include? '/'
      id = name.capitalize.sub '/', '/homebrew-'
    else
      id = "#{Repository::CORE}/#{name.downcase}"
    end
    Formula.find(id) ||
      Formula.find_by(name: name) ||
      raise("Could not find formula #{name}")
  end

  def self.optional(name)
    Dependency.new id: find_formula(name).id, type: OPTIONAL
  end

  def self.recommended(name)
    Dependency.new id: find_formula(name).id, type: RECOMMENDED
  end

  def self.runtime(name)
    Dependency.new id: find_formula(name).id, type: RUNTIME
  end

  def formula
    Formula.find id
  end

  def type
    TYPES[self[:type]]
  end

end
