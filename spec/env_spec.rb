require 'spec_helper'

describe HeadChef::Env do
  let(:current_branch) { 'test_branch' }
  let(:environment) { 'option_environment' }

  shared_examples_for "HeadChef::Env command" do |klass, method, return_value|

    context 'defaults' do
      it 'uses branch name for environment' do
        expect(klass).to receive(method) do |*args|
          args[0].should eq(current_branch)
        end.and_return(return_value)
      end
    end

    context 'with --environment' do
      it 'uses environment option value' do
        subject.options[:environment] = environment

        expect(klass).to receive(method) do |*args|
          args[0].should eq(environment)
        end.and_return(return_value)
      end
    end
  end

  describe 'commands' do

    before(:each) do
      allow(HeadChef).to receive(:current_branch).and_return(current_branch)

      # Unfreeze Thor::CoreExt::HashWithIndifferentAccess
      subject.options = subject.options.dup
    end


    describe '::diff' do
      let(:cookbook_diff) { HeadChef::CookbookDiff.new }

      after(:each) do
        subject.diff
      end

      it_should_behave_like 'HeadChef::Env command',
        HeadChef::Diff, :diff, HeadChef::CookbookDiff.new

      context 'defaults' do
        it 'outputs CookbookDiff' do
          allow(HeadChef::Diff).to receive(:diff).
            with(any_args).and_return(cookbook_diff)

          expect(cookbook_diff).to receive(:pretty_print)
        end
      end
    end

    describe '::list' do
      after(:each) do
        subject.list
      end

      it_should_behave_like 'HeadChef::Env command',
        HeadChef::List, :list, nil
    end

    describe '::sync' do
      after(:each) do
        subject.sync
      end

      it_should_behave_like 'HeadChef::Env command',
        HeadChef::Sync, :sync, nil

      context 'defaults' do
        it 'uses false for force option' do
          expect(HeadChef::Sync).to receive(:sync) do |*args|
            args[1].should eq(false)
          end
        end
      end

      context 'with --force' do
        it 'sets force option to true' do
          subject.options[:force] = true

          expect(HeadChef::Sync).to receive(:sync) do |*args|
            args[1].should eq(true)
          end
        end
      end
    end
  end
end
