require 'spec_helper'

describe HeadChef::Diff do
  describe 'ClassMethods' do
    let(:berksfile) { double('Berkshelf::Berksfile') }
    let(:lockfile) { double('Berkshelf::Lockfile') }
    let(:chef_environment) { double('Hashie::Mash') }
    let(:environment) { 'test_env' }
    let(:branch) { 'test_branch' }
    let(:dependency_hash) { {} }

    describe '::diff' do
      before(:each) do
        allow(HeadChef).to receive(:berksfile).with(branch).
          and_return(berksfile)

        HeadChef.stub_chain(:chef_server, :environment, :find).with(environment).
          and_return(chef_environment)
        allow(chef_environment).to receive(:cookbook_versions).and_return({})

        allow(berksfile).to receive(:update)
        allow(berksfile).to receive(:lockfile).and_return(lockfile)

        allow(lockfile).to receive(:to_hash).and_return(dependency_hash)
        allow(dependency_hash).to receive(:[]).with(:sources).and_return({})
      end

      after(:each) do
        described_class.diff(branch, environment)
      end

      it 'reads Berksfile from branch' do
        expect(HeadChef).to receive(:berksfile).with(branch)
      end

      it 'calls Berksfile#update to ensure correct lockfile' do
        expect(berksfile).to receive(:update)
      end

      it 'reads Berkshelf::Lockfile dependenceis' do
        expect(lockfile).to receive(:to_hash).and_return(dependency_hash)
        expect(dependency_hash).to receive(:[]).with(:sources)
      end

      it 'loads chef env' do
        expect(chef_environment).to receive(:cookbook_versions)
      end

      it 'outputs correct diff' do
        expect(described_class).to receive(:pretty_print_diff_hash)
      end
    end
  end
end
