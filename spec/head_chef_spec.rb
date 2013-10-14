require 'spec_helper'

describe 'HeadChef' do
  subject { HeadChef }

  let(:berksfile) { Berkshelf::Berksfile }
  let(:branch) { 'curr_branch' }
  let(:repo) { Grit::Repo }

  before(:each) do
    allow(Grit::Repo).to receive(:new).with('.').and_return(repo)
  end

  describe 'ClassMethods' do
    describe '::ui' do
      it 'returns Thor shell' do
        expect(subject.ui).to be_an_instance_of(Thor::Base.shell)
      end
    end

    describe '::current_branch' do
      before do
        repo.stub_chain(:head, :name).and_return(branch)
      end

      it 'returns current branch' do
        expect(subject.current_branch).to eq(branch)
      end
    end

    describe '::berksfile(branch)' do
      before(:each) do
        allow(berksfile).to receive(:from_file).with(anything()).
          and_return(Berkshelf::Berksfile.new(''))
        allow(subject).to receive(:current_branch).and_return(branch)
      end

      context 'using current branch' do
        it 'reads Berksfile from pwd' do
          expect(berksfile).to receive(:from_file).with('Berksfile')
          subject.berksfile(branch)
        end

        it 'returns Berksfile' do
          expect(subject.berksfile(branch)).to be_a(Berkshelf::Berksfile)
        end
      end

      context 'not using current branch' do
        let(:file) { double('file') }

        before(:each) do
          allow(File).to receive(:open).and_yield(file)
          allow(file).to receive(:write)
          allow(file).to receive(:path).and_return('tmp/Berksfile')

          allow(Dir).to receive(:exists).with('tmp').and_return(true)

          subject.stub_chain(:master_cookbook, :git, :native).
            and_return('example Berksfile')
        end

        after(:each) do
          subject.berksfile('not_curr_branch')
        end

        it 'reads Berksfile from local branch' do
          expect(file).to receive(:write).with('example Berksfile')
        end

        it 'creates tmp dir if it does not exist' do
          allow(Dir).to receive(:exists?).with('tmp').and_return(false)

          expect(Dir).to receive(:mkdir).with('tmp')
        end

        it 'writes Berksfile to tmp dir' do
          expect(File).to receive(:open).with('tmp/Berksfile', 'w')
          expect(file).to receive(:write).with('example Berksfile')
        end

        it 'reads Berksfile from tmp dir' do
          expect(berksfile).to receive(:from_file).with('tmp/Berksfile')
        end

        it 'returns Berksfile' do
          expect(subject.berksfile('not_curr_branch')).to be_a(Berkshelf::Berksfile)
        end

      end
    end

    describe '::cleanup' do
      after(:each) do
        subject.cleanup
      end

      it 'removes tmp dir when present' do
        allow(Dir).to receive(:exists?).with('tmp').and_return(true)
        expect(FileUtils).to receive(:rm_rf).with('tmp')
      end

      it 'does nothing when tmp dir is not present' do 
        allow(Dir).to receive(:exists?).with('tmp').and_return(false)
        expect(FileUtils).not_to receive(:rm_rf).with('tmp')
      end
    end
  end
end
