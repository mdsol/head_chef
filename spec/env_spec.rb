require 'spec_helper'

describe HeadChef::Env do
  shared_examples_for 'a HeadChef::Env command' do |klass, method|
    let(:branch) { 'option_branch' }
    let(:environment) { 'option_environment' }
    let(:current_branch) { 'test_branch' }

    before(:each) do
      allow(HeadChef).to receive(:current_branch).and_return(current_branch)

      # Unfreeze Thor::CoreExt::HashWithIndifferentAccess
      subject.options = subject.options.dup
    end

    after(:each) do
      subject.send(method)
    end

    context 'with --branch' do
      before do
        subject.options[:branch] = branch
      end

      it 'uses option value' do
        expect(klass).to receive(method).with(branch, branch)
      end
    end

    context 'with --environment' do
      before do
        subject.options[:environment] = environment
      end

      it 'uses option value' do
        expect(klass).to receive(method).with(current_branch, environment)
      end
    end

    context 'with both --branch and --environment' do
      before do
        subject.options[:branch] = branch
        subject.options[:environment] = environment
      end

      it 'uses both option values' do
        expect(klass).to receive(method).with(branch, environment)
      end
    end

    it 'uses current branch' do
      expect(klass).to receive(method).with(current_branch, current_branch)
    end
  end

  describe 'commands' do
    describe '::sync' do
      it_should_behave_like "a HeadChef::Env command", HeadChef::Sync, :sync
    end

    describe '::diff' do
      it_should_behave_like "a HeadChef::Env command", HeadChef::Diff, :diff
    end
  end
end
