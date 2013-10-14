require 'spec_helper'

describe HeadChef::Env do
  describe 'commands' do
    let(:sync) { HeadChef::Sync }
    let(:current_branch) { 'test_branch' }

    before(:each) do
      allow(HeadChef).to receive(:current_branch).and_return(current_branch)
    end

    describe '::sync' do
      let(:branch) { 'option_branch' }
      let(:environment) { 'option_environment' }

      before(:each) do
        # Unfreeze Thor::CoreExt::HashWithIndifferentAccess
        subject.options = subject.options.dup
      end

      after(:each) do
        subject.sync
      end

      context 'with --branch' do
        before do
          subject.options[:branch] = branch
        end

        it 'uses option value' do
          expect(sync).to receive(:sync).with(branch, branch)
        end
      end

      context 'with --environment' do
        before do
          subject.options[:environment] = environment
        end

        it 'uses option value' do
          expect(sync).to receive(:sync).with(current_branch, environment)
        end
      end

      context 'with both --branch and --environment' do
        before do
          subject.options[:branch] = branch
          subject.options[:environment] = environment
        end

        it 'uses both option values' do
          expect(sync).to receive(:sync).with(branch, environment)
        end
      end

      it 'uses current branch' do
        expect(sync).to receive(:sync).with(current_branch, current_branch)
      end
    end

    describe '::diff' do
      it 'performs diff'
    end
  end
end
