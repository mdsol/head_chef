require 'spec_helper'

describe HeadChef::Sync do
  describe 'ClassMethods' do
    let(:berksfile) { double('Berkshelf::Berksfile') }
    let(:environment) { 'test_env' }
    let(:branch) { 'test_branch' }

    describe '::sync(branch, environment)' do
      before(:each) do
        allow(berksfile).to receive(:apply).with(environment, {})
        allow(HeadChef).to receive(:berksfile).
          with(branch).and_return(berksfile)
      end

      after(:each) do
        described_class.sync(branch, environment)
      end

      it 'reads Berksfile from branch' do
        expect(HeadChef).to receive(:berksfile).with(branch)
      end

      it 'applies Berksfile to environment' do
        expect(berksfile).to receive(:apply).with(environment, {})
      end

    end
  end
end
