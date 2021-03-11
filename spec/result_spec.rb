# frozen_string_literal: true

require 'spec_helper'
require 'undercover'

describe Undercover::Result do
  let(:ast) { Imagen.from_local('spec/fixtures/class.rb') }
  let(:lcov) do
    Undercover::LcovParser.parse('spec/fixtures/fixtures.lcov')
  end
  let(:coverage) { lcov.source_files['class.rb'] }

  it 'computes class coverage as float' do
    node = ast.find_all(with_name('BaconClass')).first
    result = described_class.new(node, coverage, 'class.rb')

    expect(result.coverage_f).to eq(0.8333)
  end

  it 'computes method coverage as float' do
    node = ast.find_all(with_name('bar')).first
    result = described_class.new(node, coverage, 'class.rb')

    expect(result.coverage_f).to eq(1.0)
  end

  it 'computes coverage for a not covered method' do
    node = ast.find_all(with_name('foo')).first
    result = described_class.new(node, coverage, 'class.rb')

    expect(result.coverage_f).to eq(0.0)
  end

  context 'for an empty module def' do
    let(:ast) { Imagen.from_local('spec/fixtures/empty_class_def.rb') }
    let(:lcov) do
      Undercover::LcovParser.parse('spec/fixtures/empty_class_def.lcov')
    end
    let(:coverage) { lcov.source_files['empty_class_def.rb'] }

    it 'is not NaN' do
      node = ast.find_all(with_name('ApplicationJob')).first
      result = described_class.new(node, coverage, 'empty_class_def.rb')

      expect(result.coverage_f).to eq(1.0)
    end
  end
end
