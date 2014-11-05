require 'spec_helper'

describe Manipulator do
  let(:node) { double('node', to_hash: { foo: 'bar' }) }

  let(:lines) do
    [
      "127.0.0.1  localhost",
      "1.2.3.4  example.com",
      "4.5.6.7  foo.example.com"
    ]
  end

  let(:entries) do
    [
      double('entry_1', ip_address: '127.0.0.1', hostname: 'localhost',       to_line: '127.0.0.1  localhost',     priority: 10),
      double('entry_2', ip_address: '1.2.3.4',   hostname: 'example.com',     to_line: '1.2.3.4  example.com',     priority: 20),
      double('entry_3', ip_address: '4.5.6.7',   hostname: 'foo.example.com', to_line: '4.5.6.7  foo.example.com', priority: 30)
    ]
  end

  let(:manipulator) { Manipulator.new(node) }

  before do
    File.stub(:exists?).and_return(true)
    File.stub(:readlines).and_return(lines)
    manipulator.instance_variable_set(:@entries, entries)
  end

  describe '.initialize' do
    it 'saves the given node to a hash' do
      node.should_receive(:to_hash).once
      Manipulator.new(node)
    end

    it 'saves the node hash to an instance variable' do
      manipulator = Manipulator.new(node)
      expect(manipulator.node).to eq(node.to_hash)
    end

    it 'raises a fatal error if the hostsfile does not exist' do
      File.stub(:exists?).and_return(false)
      Chef::Application.should_receive(:fatal!).once.and_raise(SystemExit)
      expect { Manipulator.new(node) }.to raise_error(SystemExit)
    end

    it 'sends the line to be parsed by the Entry class' do
      lines.each { |l| Entry.should_receive(:parse).with(l) }
      Manipulator.new(node)
    end
  end

  describe '#ip_addresses' do
    it 'returns a list of all the IP Addresses' do
      expect(manipulator.ip_addresses).to eq(entries.map(&:ip_address))
    end
  end

  describe '#add' do
    let(:entry) { double('entry') }

    let(:options) { { ip_address: '1.2.3.4', hostname: 'example.com', aliases: nil, comment: 'Some comment', priority: 5 } }

    before { Entry.stub(:new).and_return(entry) }

    it 'creates a new entry object' do
      Entry.should_receive(:new).with(options)
      manipulator.add(options)
    end

    it 'pushes the new entry onto the collection' do
      manipulator.add(options)
      expect(manipulator.instance_variable_get(:@entries)).to include(entry)
    end
  end

  describe '#update' do
    context 'when the entry does not exist' do
      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(nil)
      end

      it 'does nothing' do
        manipulator.update(ip_address: '5.4.3.2', hostname: 'seth.com')
        expect(manipulator.instance_variable_get(:@entries)).to eq(entries)
      end
    end

    context 'with the entry does exist' do
      let(:entry) { double('entry', :hostname= => nil, :aliases= => nil, :comment= => nil, :priority= => nil) }

      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(entry)
      end

      it 'updates the hostname' do
        entry.should_receive(:hostname=).with('seth.com')
        manipulator.update(ip_address: '1.2.3.4', hostname: 'seth.com')
      end
    end
  end

  describe '#append' do
    let(:options) { { ip_address: '1.2.3.4', hostname: 'example.com', aliases: nil, comment: 'Some comment', priority: 5 } }

    context 'when the record exists' do
      let(:entry) { double('entry', options.merge(:aliases= => nil, :comment= => nil)) }

      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(entry)
      end

      it 'updates the hostname' do
        entry.should_receive(:hostname=).with('example.com')
        manipulator.append(options)
      end

      it 'updates the aliases' do
        entry.should_receive(:aliases=).with(['www.example.com'])
        entry.should_receive(:hostname=).with('example.com')
        manipulator.append(options.merge(aliases: 'www.example.com'))
      end

      it 'updates the comment' do
        entry.should_receive(:comment=).with('Some comment, This is a new comment!')
        entry.should_receive(:hostname=).with('example.com')
        manipulator.append(options.merge(comment: 'This is a new comment!'))
      end
    end

    context 'when the record does not exist' do
      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(nil)
        manipulator.stub(:add)
      end

      it 'delegates to #add' do
        manipulator.should_receive(:add).with(options).once
        manipulator.append(options)
      end
    end
  end

  describe '#remove' do
    context 'when the entry does not exist' do
      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(nil)
      end

      it 'does nothing' do
        manipulator.remove('5.4.3.2')
        expect(manipulator.instance_variable_get(:@entries)).to eq(entries)
      end
    end

    context 'with the entry does exist' do
      let(:entry) { entries[0] }

      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(entry)
      end

      it 'removes the entry' do
        expect(manipulator.instance_variable_get(:@entries)).to include(entry)
        manipulator.remove('5.4.3.2')
        expect(manipulator.instance_variable_get(:@entries)).to_not include(entry)
      end
    end
  end

  describe '#save' do
    let(:file) { double('file', write: true) }

    before do
      File.stub(:open).and_yield(file)
      manipulator.stub(:unique_entries).and_return(entries)
    end

    context 'when the file has not changed' do
      it 'does not write out the file' do
        Digest::SHA512.stub(:hexdigest).and_return('abc123')
        File.should_not_receive(:open)
        manipulator.save
      end
    end

    context 'when the file has changed' do
      it 'writes out the new file' do
        File.should_receive(:open).with('/etc/hosts', 'w').once
        file.should_receive(:write).once
        manipulator.save
      end
    end
  end

  describe '#find_entry_by_ip_address' do
    it 'finds the associated entry' do
      expect(manipulator.find_entry_by_ip_address('127.0.0.1')).to eq(entries[0])
      expect(manipulator.find_entry_by_ip_address('1.2.3.4')).to eq(entries[1])
      expect(manipulator.find_entry_by_ip_address('4.5.6.7')).to eq(entries[2])
    end

    it 'returns nil if the entry does not exist' do
      expect(manipulator.find_entry_by_ip_address('77.77.77.77')).to be_nil
    end
  end
end
