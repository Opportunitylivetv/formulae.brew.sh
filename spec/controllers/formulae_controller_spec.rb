# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2018, Sebastian Staudt

require 'rails_helper'

describe FormulaeController do

  describe '#select_repository' do
    it 'sets the repository' do
      repo = mock
      repo.expects(:name).returns 'Homebrew/homebrew-versions'
      criteria = mock
      Repository.expects(:where).with(_id: /^Homebrew\/homebrew-versions$/i).returns criteria
      criteria.expects(:only).with(:_id, :letters, :name, :sha, :updated_at).returns [ repo ]
      controller.expects(:params).returns({ repository_id: 'Homebrew/homebrew-versions' })

      controller.send :select_repository

      expect(controller.instance_variable_get(:@repository)).to eq(repo)
    end

    it 'the repository defaults to nil' do
      controller.send :select_repository

      expect(controller.instance_variable_get(:@repository)).to be_nil
    end

    it 'redirects to the correct repository if capitalization is incorrect' do
      request = mock
      request.expects(:url).returns 'http://formulae.brew.sh/repos/Homebrew/Homebrew-versions/browse'
      controller.expects(:request).returns request

      repo = mock
      repo.expects(:name).twice.returns 'Homebrew/homebrew-versions'
      criteria = mock
      Repository.expects(:where).with(_id: /^Homebrew\/Homebrew-versions$/i).returns criteria
      criteria.expects(:only).with(:_id, :letters, :name, :sha, :updated_at).returns [ repo ]
      controller.expects(:params).returns({ repository_id: 'Homebrew/Homebrew-versions' })
      controller.expects(:redirect_to).with 'http://formulae.brew.sh/repos/Homebrew/homebrew-versions/browse'

      controller.send :select_repository
    end

    it 'raises Mongoid::Errors::DocumentNotFound if no repository is found' do
      criteria = mock
      Repository.expects(:where).with(_id: /^Homebrew\/unknown$/i).returns criteria
      criteria.expects(:only).with(:_id, :letters, :name, :sha, :updated_at).returns []
      controller.expects(:params).returns({ repository_id: 'Homebrew/unknown' })

      expect { controller.send :select_repository }.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end

  describe '#show' do
    context 'when formula is not found' do
      before do
        formulae = mock
        formulae.expects(:all_in).returns []
        formulae.expects(:where).returns []
        repo = mock
        repo.expects(:formulae).twice.returns formulae

        controller.stubs :select_repository
        controller.instance_variable_set :@repository, repo
        bypass_rescue
      end

      it 'should raise an error' do
        expect(-> { get :show, params: { repository_id: 'Homebrew/homebrew-versions', id: 'git' }}).
          to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
  end

end
