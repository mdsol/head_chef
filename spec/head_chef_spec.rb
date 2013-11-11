require 'spec_helper'

describe HeadChef do
  let(:berksfile) { Berkshelf::Berksfile }
  let(:branch) { 'curr_branch' }
  let(:repo) { double('Grit::Repo') }

  before(:each) do
    allow(Grit::Repo).to receive(:new).with('.').and_return(repo)

    stub_const("HeadChef::BERKSFILE_COOKBOOK_DIR", '.head_chef')
  end

  describe 'ClassMethods' do
    describe '::ui' do
      it 'returns Thor shell' do
        expect(subject.ui).to be_an_instance_of(Thor::Base.shell)
      end
    end

    describe '::chef_server' do
      it 'creates Ridley::Client' do
        expect(Ridley).to receive(:from_chef_config).with(no_args)
        subject.chef_server
      end
    end

    describe '::master_cookbook' do
      it 'returns Grit repo' do
        expect(subject.master_cookbook).to eq(repo)
      end
    end

    describe '::current_branch' do
      before do
        allow(subject).to receive(:master_cookbook).and_return(repo)
        repo.stub_chain(:head, :name).and_return(branch)
      end

      it 'returns current branch' do
        expect(subject.current_branch).to eq(branch)
      end
    end

    describe '::berksfile' do
      before(:each) do
        allow(berksfile).to receive(:from_file).with(anything()).
          and_return(Berkshelf::Berksfile.new(''))
      end

      it 'returns Berksfile' do
        expect(subject.berksfile).to be_a(Berkshelf::Berksfile)
      end
    end

    describe '::cleanup' do
      after(:each) do
        subject.cleanup
      end

      it 'removes .head_chef when present' do
        allow(Dir).to receive(:exists?).
          with(HeadChef::BERKSFILE_COOKBOOK_DIR).and_return(true)

        expect(FileUtils).to receive(:rm_rf).
          with(HeadChef::BERKSFILE_COOKBOOK_DIR)
      end
    end
  end
end
