require 'spec_helper'

describe HeadChef::Diff do
  describe 'ClassMethods' do
    let(:berksfile) { double('Berkshelf::Berksfile') }
    let(:lockfile) { double('Berkshelf::Lockfile') }
    let(:chef_environment) { double('Hashie::Mash') }
    let(:environment) { 'test_env' }
    let(:diff_hash) { {} }

    describe '::diff' do
      before(:each) do
        allow(HeadChef).to receive(:berksfile).and_return(berksfile)

        HeadChef.stub_chain(:chef_server, :environment, :find).with(environment).
          and_return(chef_environment)
        allow(chef_environment).to receive(:cookbook_versions).and_return({})

        allow(berksfile).to receive(:install)
        allow(berksfile).to receive(:lockfile).and_return(lockfile)

        allow(lockfile).to receive(:to_hash).and_return(diff_hash)
        allow(lockfile).to receive(:filepath).and_return('Berksfile.lock')

        allow(File).to receive(:exists?).with(lockfile.filepath)
        allow(File).to receive(:delete)


        allow(diff_hash).to receive(:[]).with(:sources).and_return({})
      end

      after(:each) do
        described_class.diff(environment)
      end

      it 'loads chef environment' do
        expect(chef_environment).to receive(:cookbook_versions)
      end

      it 'reads Berksfile' do
        expect(HeadChef).to receive(:berksfile)
      end

      it 'calls Berksfile#update to ensure correct lockfile' do
        expect(berksfile).to receive(:install)
      end

      it 'reads Berkshelf::Lockfile dependenceis' do
        expect(lockfile).to receive(:to_hash).and_return(diff_hash)
        expect(diff_hash).to receive(:[]).with(:sources)
      end

      it 'returns diff hash' do
        expect(described_class.diff(environment)).to be_a(Hash)
      end
    end
  end
end
