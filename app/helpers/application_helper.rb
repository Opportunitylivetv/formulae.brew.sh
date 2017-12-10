# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2017, Sebastian Staudt

module ApplicationHelper

  def formula_link(formula, options = {})
    options = { class: 'formula' }.merge options
    url_options = formula.dupe? ? [formula.repository, formula] : formula
    link_to formula.name, url_for(url_options), options
  end

  def timestamp(time)
    options = {
      class: 'timeago',
      datetime: time.getutc.iso8601
    }
    content_tag :time, l(time, format: :long), options
  end

  def title
    title = 'Homebrew Formulae'
    title = "#{@title} – #{title}" unless @title.nil?
    title
  end

end
