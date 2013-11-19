require 'spec_helper'

#@TODO: cleanup
describe HeadChef::Env do
  shared_examples_for 'a HeadChef::Env command' do |klass, method|
    let(:environment) { 'option_environment' }
    let(:current_branch) { 'test_branch' }

    before(:each) do
      allow(HeadChef).to receive(:current_branch).and_return(current_branch)
      allow(HeadChef::Diff).to receive(:pretty_print_diff_hash)

      # Unfreeze Thor::CoreExt::HashWithIndifferentAccess
      subject.options = subject.options.dup
    end

    after(:each) do
      subject.send(method)
    end

    context 'with --environment' do
      before do
        subject.options[:environment] = environment
      end

      it 'uses option value' do
        expect(klass).to receive(method) do |*args|
          expect(args[0]).to eq(environment)
        end
      end
    end
  end

  describe 'commands' do
    describe '::sync' do
      let(:current_branch) { 'test_branch' }

      before(:each) do
        allow(HeadChef).to receive(:current_branch).and_return(current_branch)

        # Unfreeze Thor::CoreExt::HashWithIndifferentAccess
        subject.options = subject.options.dup
      end

      it 'uses false for force option by default' do
        expect(HeadChef::Sync).to receive(:sync) do |*args|
          expect(args[1]).to eq(false)
        end
        subject.sync
      end

      context 'with --force' do
        before do
          subject.options[:force] = true
        end

        it 'sets force option to true' do
          expect(HeadChef::Sync).to receive(:sync) do |*args|
            expect(args[1]).to eq(true)
          end
          subject.sync
        end
      end

      it_should_behave_like "a HeadChef::Env command", HeadChef::Sync, :sync
    end

    describe '::diff' do
      it_should_behave_like "a HeadChef::Env command", HeadChef::Diff, :diff
    end
  end
end
