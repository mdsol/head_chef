require 'spec_helper'

describe HeadChef::Cookbook do
  let(:cookbook_resource) { double('Ridley::CookbookResouce') }
  let(:cached_cookbooks) { [] }
  let(:cached_cookbook) { double('Berkshelf::CachedCookbook') }

  subject { HeadChef::Cookbook.new('test', '0.0.1', '0.0.2') }

  describe 'ClassMethods' do
    describe '::new' do
      it 'reads name' do
        expect(subject.name).to eq('test')
      end

      it 'reads berkshelf version' do
        expect(subject.berkshelf_version).to eq('0.0.1')
      end

      it 'reads chef version' do
        expect(subject.chef_version).to eq('0.0.2')
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#diff' do
      before(:each) do
        HeadChef.stub_chain(:chef_server, :cookbook).
          and_return(cookbook_resource)

        allow(cookbook_resource).to receive(:find).
          with(subject.name, subject.berkshelf_version).
          and_return(cookbook_resource)
        allow(cookbook_resource).to receive(:manifest).and_return([])

        HeadChef.stub_chain(:berksfile, :cached_cookbooks).
          and_return(cached_cookbooks)
        allow(cached_cookbooks).to receive(:find).and_return(cached_cookbook)

        allow(cached_cookbook).to receive(:path)
        allow(subject).to receive(:remove_ignored_files).and_return([])
      end

      after(:each) do
        subject.diff
      end

      it 'retrieves cookbook checksums from chef server' do
        expect(cookbook_resource).to receive(:find).
          with(subject.name, subject.berkshelf_version)
      end

      it 'loads cookbook from berkshelf cache' do
        expect(cached_cookbooks).to receive(:find)
      end
    end
  end

end
