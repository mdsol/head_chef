require 'spec_helper'

describe HeadChef::Sync do
  describe 'ClassMethods' do
    let(:berksfile) { double('Berkshelf::Berksfile') }
    let(:chef_environments) { double('Ridley::EnvironmentResource') }
    let(:environment) { 'test_env' }
    let(:branch) { 'test_branch' }

    describe '::sync(branch, environment)' do
      before(:each) do
        allow(berksfile).to receive(:apply).with(environment, {})
        allow(berksfile).to receive(:update)
        allow(berksfile).to receive(:upload)

        allow(HeadChef).to receive(:berksfile).
          with(branch).and_return(berksfile)
        HeadChef.stub_chain(:chef_server, :environment).
          and_return(chef_environments)

        allow(chef_environments).to receive(:find).with(environment)
        allow(chef_environments).to receive(:create).with(name: environment)
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

      it 'checks environment exists on Chef server' do
        expect(chef_environments).to receive(:find).with(environment)
      end

      context 'environment does not exist on Chef server' do
        it 'creates environment' do
          expect(chef_environments).to receive(:create).with(name: environment)
        end
      end

      it 'applies Berksfile to environment' do
        expect(berksfile).to receive(:apply).with(environment, {})
      end

    end
  end
end
