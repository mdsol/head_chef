require 'spec_helper'

describe HeadChef::Env do
  describe 'commands' do
    let(:current_branch) { 'test_branch' }
    let(:environment) { 'option_environment' }

    before(:each) do
      allow(HeadChef).to receive(:current_branch).and_return(current_branch)

      subject.options = subject.options.dup
    end

    describe '::sync' do
      after(:each) do
        subject.sync
      end

      context 'defaults' do
        it 'uses false for force option' do
          expect(HeadChef::Sync).to receive(:sync) do |*args|
            expect(args[1]).to eq(false)
          end
        end

        it 'uses branch name for environment' do
          expect(HeadChef::Sync).to receive(:sync) do |*args|
            puts args
            expect(args[0]).to eq(current_branch)
          end
        end
      end

      context 'with --force' do
        it 'sets force option to true' do
          subject.options[:force] = true

          expect(HeadChef::Sync).to receive(:sync) do |*args|
            expect(args[1]).to eq(true)
          end
        end
      end

      context 'with --environment' do
        it 'uses --enviroment option value' do
          subject.options[:environment] = environment

          expect(HeadChef::Sync).to receive(:sync) do |*args|
            expect(args[0]).to eq(environment)
          end
        end
      end
    end

    describe '::diff' do
      before(:each) do
        allow(HeadChef::Diff).to receive(:diff).and_return(HeadChef::CookbookDiff)
        allow(HeadChef::CookbookDiff).to receive(:pretty_print)
      end

      after(:each) do
        subject.diff
      end

      context 'defaults' do
        it 'uses branch name for environment' do
          expect(HeadChef::Diff).to receive(:diff).with(current_branch)
        end

        it 'outputs CookbookDiff' do
          expect(HeadChef::CookbookDiff).to receive(:pretty_print)
        end
      end

      context 'with --environment' do
        it 'uses --enviroment option value' do
          subject.options[:environment] = environment

          expect(HeadChef::Diff).to receive(:diff).with(environment)
        end
      end
    end

  end
end
