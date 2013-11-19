require 'spec_helper'

describe HeadChef::Diff do
  describe 'ClassMethods' do
    let(:berksfile) { double('Berkshelf::Berksfile') }
    let(:chef_environment) { double('Hashie::Mash') }
    let(:environment) { 'test_env' }

    describe '::diff' do
      before(:each) do
        HeadChef.stub_chain(:chef_server, :environment, :find).
          with(environment).
          and_return(chef_environment)

        allow(chef_environment).to receive(:cookbook_versions).and_return({})

        allow(HeadChef).to receive(:berksfile).and_return(berksfile)
        allow(berksfile).to receive(:install).and_return([])
      end

      after(:each) do
        described_class.diff(environment)
      end

      it 'loads chef environment' do
        expect(chef_environment).to receive(:cookbook_versions)
      end

      it 'calls Berksfile#install to load berkshelf cookbooks into cache' do
        expect(berksfile).to receive(:install)
      end

      it 'returns CookbookDiff' do
        expect(described_class.diff(environment)).to be_an_instance_of(HeadChef::CookbookDiff)
      end
    end
  end
end
