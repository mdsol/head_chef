require 'spec_helper'

describe HeadChef::CookbookDiff do
  let(:empty_diff_hash) do
    { add: [],
      update: [],
      remove: [],
      revert: [],
      conflict: [] }
  end

  shared_examples_for 'correct add to CookbookDiff' do |cookbook, method|
    it "appends #{cookbook.name} cookbook to :#{method} list" do
        subject.add(cookbook)
        expect(subject.diff_hash[method]).to include(cookbook)
    end
  end

  describe 'ClassMethods' do
    describe '#new' do
      it 'initializes hash' do
        expect(subject.diff_hash).to eq(empty_diff_hash)
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#add(HeadChef::Cookbook)' do

      context 'with cookbook content conflict' do
        before(:each) do
          HeadChef::Cookbook.any_instance.stub(:diff).and_return(false)
        end

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('add_test', '0.0.1', nil), :conflict

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('update_test', '0.0.2', '0.0.1'), :conflict

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('remove_test', nil, '0.0.1'), :remove

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('revert_test', '0.0.1', '0.0.2'), :conflict

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('conflict_test', '0.0.1', '0.0.1'), :conflict
      end

      context 'without cookbook content conflict' do
        before(:each) do
          HeadChef::Cookbook.any_instance.stub(:diff).and_return(true)
        end

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('add_test', '0.0.1', nil), :add

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('update_test', '0.0.2', '0.0.1'), :update

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('remove_test', nil, '0.0.1'), :remove

        it_should_behave_like 'correct add to CookbookDiff',
          HeadChef::Cookbook.new('revert_test', '0.0.1', '0.0.2'), :revert

        it 'does nothing when berkshelf version == chef version' do
          cookbook = HeadChef::Cookbook.new('conflict_test', '0.0.1', '0.0.1')
          subject.add(cookbook)
          expect(subject.diff_hash).to eq(empty_diff_hash)
        end

      end
    end
  end
end
