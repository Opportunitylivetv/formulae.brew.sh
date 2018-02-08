# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2018, Sebastian Staudt

require 'rails_helper'

describe Formula do

  let :formula do
    repo = Repository.new name: Repository::CORE, formula_path: 'Formula'
    Formula.new name: 'git', repository: repo
  end

  describe '#generate_history!' do
    it 'resets and regenerates the history of the formula' do
      formula.repository.stubs(:generate_formula_history).with formula
      formula.revisions = [ Revision.new, Revision.new, Revision.new ]

      formula.generate_history!

      expect(formula.revisions).to be_empty
    end
  end

  describe '#set_id' do
    it 'should update the formula’s id' do
      formula.set_id

      expect(formula.id).to eq "#{Repository::CORE}/git"
    end
  end

  describe '#update_metadata' do
    it 'updates the metadata of the formula' do
      formula_info = {
        'desc' => 'Example description',
        'build_dependencies' => %w[dep1],
        'optional_dependencies' => %w[dep4],
        'recommended_dependencies' => %w[dep2],
        'dependencies' => %w[dep1 dep2 dep3 dep4],
        'homepage' => 'http://example.com',
        'keg_only' => true,
        'versions' => {
          'stable' => '1.0.0',
          'devel' =>  '1.1.0.beta',
          'head' => 'HEAD'
        }
      }
      dep1 = mock
      Dependency.stubs(:build).returns dep1
      dep2 = mock
      Dependency.stubs(:recommended).returns dep2
      dep3 = mock
      Dependency.stubs(:runtime).returns dep3
      dep4 = mock
      Dependency.stubs(:optional).returns dep4
      formula.stubs(:deps=)
      formula.deps.stubs(:+)

      formula.update_metadata formula_info

      expect(formula.description).to eq 'Example description'
      expect(formula.homepage).to eq 'http://example.com'
      expect(formula.keg_only).to be_truthy
      expect(formula.stable_version).to eq '1.0.0'
      expect(formula.devel_version).to eq '1.1.0.beta'
      expect(formula.head_version).to eq 'HEAD'
    end
  end

  describe '#version' do
    it 'should return the stable version if it is available' do
      formula.stable_version = '1.0.0'
      formula.devel_version = '1.1.0.beta'
      formula.head_version = 'HEAD'

      expect(formula.version).to eq '1.0.0'
    end

    it 'should return the devel version if it is available and no stable version exists' do
      formula.devel_version = '1.1.0.beta'
      formula.head_version = 'HEAD'

      expect(formula.version).to eq '1.1.0.beta'
    end

    it 'should return the head version if no other version exists' do
      formula.head_version = 'HEAD'

      expect(formula.version).to eq 'HEAD'
    end
  end

  context 'for a formula in the core repository' do

    describe '#path' do
      it 'returns the relative path' do
        expect(formula.path).to eq('Formula/git.rb')
      end
    end

    describe '#raw_url' do
      it 'returns the GitHub URL of the raw formula file' do
        expect(formula.raw_url).to eq("https://raw.github.com/#{Repository::CORE}/HEAD/Formula/git.rb")
      end
    end

  end

  context 'for a formula in a tap repository' do

    let :formula do
      repo = Repository.new name: 'Homebrew/homebrew-php'
      Formula.new name: 'php', repository: repo
    end

    describe '#path' do
      it 'returns the relative path' do
        expect(formula.path).to eq('php.rb')
      end
    end

    describe '#raw_url' do
      it 'returns the GitHub URL of the raw formula file' do
        expect(formula.raw_url).to eq('https://raw.github.com/Homebrew/homebrew-php/HEAD/php.rb')
      end
    end

  end

end
