# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2017, Sebastian Staudt

require 'text'

class FormulaeController < ApplicationController

  before_action :ensure_html, except: :feed
  before_action :select_repository

  def browse
    letter = params[:letter]
    @title = "Browse formulae – #{letter.upcase}"
    @title << " – #{helpers.name}" unless all?

    @formulae = formulae.letter(letter)
                        .where(removed: false).order_by(%i[name asc])
                        .page(params[:page]).per 30

    fresh_when etag: etag, public: true
  end

  def feed
    revisions = all? ? Revision : @repository.revisions
    @revisions = revisions.without_bot
                          .includes(:author, :added_formulae, :updated_formulae, :removed_formulae)
                          .order_by(%i[date desc]).limit 50

    respond_to do |format|
      format.atom
    end

    fresh_when etag: etag, public: true
  end

  def search
    return not_found if params[:search].nil?

    term = params[:search].force_encoding('UTF-8').delete "\u0000"
    @title = "Search for: #{term}"
    @title << " in #{helpers.name}" unless all?
    search_term = /#{Regexp.escape term}/i
    @formulae = formulae.and removed: false, :$or =>
      [
        { aliases: search_term },
        { description: search_term },
        { name: search_term }
      ]

    if @formulae.size == 1 && term == @formulae.first.name
      redirect_to @formulae.first
      return
    end

    @formulae = @formulae.sort_by! do |formula|
      Text::Levenshtein.distance(formula.name[0..term.size - 1], term) * 10 +
        Text::Levenshtein.distance(formula.name, term)
    end
    @formulae = Kaminari.paginate_array(@formulae).page(params[:page]).per 30

    respond_to do |format|
      format.html { render 'formulae/browse' }
    end

    fresh_when etag: etag, public: true
  end

  def show
    @formulae = formulae.where(name: params[:id]).to_a
    if @formulae.empty?
      formula = formulae.all_in(aliases: [params[:id]]).first
      unless formula.nil?
        redirect_to formula
        return
      end
      raise Mongoid::Errors::DocumentNotFound.new(Formula, [], params[:id])
    elsif @formulae.size > 1
      @formulae = Kaminari.paginate_array @formulae, limit: @formulae.size, offset: 0

      respond_to do |format|
        format.html { render 'formulae/browse' }
      end

      return
    end
    @formula = @formulae.first
    @title = @formula.name.dup
    @title << " – #{helpers.name}" unless all?
    @revisions = @formula.revisions.limit(5).without_bot.includes(:author)
                         .order_by(%i[date desc]).to_a

    fresh_when etag: etag, public: true
  end

  protected

  def all?
    @repository.nil?
  end
  helper_method :all?

  def etag
    if all? && Revision.last
      Revision.last.sha
    elsif @repository
      @repository.sha
    end
  end

  def formulae
    if all?
      Formula
    elsif @repository
      @repository.formulae
    end
  end

  def select_repository
    repository_id = params[:repository_id]
    return if repository_id.nil?

    @repository = Repository.where(_id: /^#{repository_id}$/i)
                            .only(:_id, :letters, :name, :sha, :updated_at).first
    if @repository.nil?
      raise Mongoid::Errors::DocumentNotFound.new Repository, [], repository_id
    end

    if @repository.name != repository_id
      redirect_to request.url.sub "/repos/#{repository_id}", "/repos/#{@repository.name}"
    end
  end

end
