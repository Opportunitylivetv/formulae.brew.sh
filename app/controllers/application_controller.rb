
# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2017, Sebastian Staudt

class ApplicationController < ActionController::Base

  class RepositoryUnavailable < StandardError; end

  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: :forbidden

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found
  rescue_from RepositoryUnavailable do
    error_page :service_unavailable
  end

  before_action :ensure_html

  def index
    main_page

    fresh_when etag: Repository.core.sha, public: true
  end

  def status
    fresh_when etag: Repository.core.sha, public: true
  end

  def error_page(status = :internal_server_error)
    view = 'application/%d'.format(Rack::Utils::SYMBOL_TO_STATUS_CODE[status])

    respond_to do |format|
      format.html { render view, status: status }
      format.any { render nothing: true, status: status }
    end

    headers.delete 'ETag'
    expires_in 5.minutes
  end

  def forbidden
    respond_to do |format|
      format.any { render nothing: true, status: :forbidden }
    end
  end

  def not_found
    flash.now[:error] = 'The page you requested does not exist.'
    main_page

    respond_to do |format|
      format.html { render 'application/index', status: :not_found }
      format.any { head :not_found }
    end

    headers.delete 'ETag'
    expires_in 5.minutes
  end

  def sitemap
    @repository = Repository.only(:_id, :sha, :updated_at).core

    respond_to do |format|
      format.xml
    end

    fresh_when etag: @repository.sha, public: true
  end

  protected

  def ensure_html
    head 406 unless request.format.html? || request.request_method == 'HEAD'
  end

  private

  def main_page
    @taps = Repository.only(%i[_id date letters name sha updated_at])
                      .current_taps.order_by(%i[name asc])
                      .sort_by { |r| r.core? ? 0 : 1 }

    top5 = Formula.limit(5).order_by(%i[date desc])
                  .only %i[_id name repository_id]
    linked_formulae = top5.where(removed: false)
                          .only %i[devel_version head_version stable_version]

    @added = linked_formulae.with_size revision_ids: 1
    @updated = linked_formulae.not.with_size revision_ids: 1
    @removed = top5.where removed: true
  end

end
