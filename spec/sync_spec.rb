require 'spec_helper'

describe HeadChef::Sync do
  describe 'ClassMethods' do
    let(:berksfile) { double('Berkshelf::Berksfile') }
    let(:environment) { 'test_env' }
    let(:branch) { 'test_branch' }

    describe '::sync(branch, environment)' do
      before(:each) do
        allow(berksfile).to receive(:apply).with(environment, {})
        allow(berksfile).to receive(:update)
        allow(berksfile).to receive(:upload)

        allow(HeadChef).to receive(:berksfile).
          with(branch).and_return(berksfile)
      end

      after(:each) do
        described_class.sync(branch, environment)
      end

      it 'reads Berksfile from branch' do
        expect(HeadChef).to receive(:berksfile).with(branch)
      end

      it 'calls Berksfile#update to ensure correct lockfile' do
        expect(berksfile).to receive(:update)
      end

      it 'calls Berksfile#upload to push cookbooks to server' do
        expect(berksfile).to receive(:upload)
      end

      it 'applies Berksfile to environment' do
        expect(berksfile).to receive(:apply).with(environment, {})
      end

    end
  end
end
