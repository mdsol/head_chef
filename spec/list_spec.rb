require 'spec_helper'

describe HeadChef::List do
  describe 'ClassMethods' do
    let(:environment_name) { 'environment' }
    let(:environment_resource) { double('Ridley::EnvironmentResouce') }
    let(:environment) { double('Ridley::EnvironmentObject') }

    before(:each) do
      HeadChef.stub_chain(:chef_server, :environment).and_return(environment_resource)

      allow(environment_resource).to receive(:find).and_return(environment)
      allow(environment).to receive(:cookbook_versions).and_return([])
    end

    after(:each) do
      described_class.list(environment)
    end

    describe '::list' do
      it 'reads chef environment' do
        expect(environment_resource).to receive(:find).with(environment)
      end
    end
  end
end
