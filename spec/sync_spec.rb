require 'spec_helper'

#@TODO: refactor/cleanup
# Keep stubs related to tests
# make force context for using/not using force
describe HeadChef::Sync do
  describe 'ClassMethods' do
    let(:berksfile) { double('Berkshelf::Berksfile') }
    let(:chef_environments) { double('Ridley::EnvironmentResource') }
    let(:environment) { 'test_env' }
    let(:branch) { 'test_branch' }
    let(:diff_hash) { {} }

    describe '::sync(environment, force)' do
      before(:each) do
        allow(berksfile).to receive(:apply).with(environment, {})
        allow(berksfile).to receive(:upload)

        allow(HeadChef).to receive(:berksfile).
          and_return(berksfile)
        HeadChef.stub_chain(:chef_server, :environment).
          and_return(chef_environments)

        allow(chef_environments).to receive(:find).with(environment)
        allow(chef_environments).to receive(:create).with(name: environment)

        allow(HeadChef::Diff).to receive(:diff).with(environment).
          and_return(HeadChef::CookbookDiff)

        allow(HeadChef::CookbookDiff).to receive(:conflicts?)
        allow(HeadChef::CookbookDiff).to receive(:conflicts)

        #@TODO: not being muted, despite it being in spec_helper
        # not sure why
        allow(HeadChef.ui).to receive(:say)
      end

      after(:each) do
        described_class.sync(environment, false)
      end

      it 'reads environment from Chef server' do
        expect(chef_environments).to receive(:find).with(environment)
      end

      context 'environment does not exist on Chef server' do
        before do
          allow(chef_environments).to receive(:find).
            with(environment).
            and_return(false)
        end

        it 'creates environment' do
          expect(chef_environments).to receive(:create).with(name: environment)
        end
      end

      it 'performs diff of Chef environment and lockfile' do
        expect(HeadChef::Diff).to receive(:diff).with(environment)
      end

      context 'with --force' do
        after(:each) do
          described_class.sync(environment, true)
        end

        it 'calls Berksfile#upload with force option' do
          expect(berksfile).to receive(:upload).with({force: true})
        end
      end

      it 'reads Berksfile from branch' do
        expect(HeadChef).to receive(:berksfile)
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
