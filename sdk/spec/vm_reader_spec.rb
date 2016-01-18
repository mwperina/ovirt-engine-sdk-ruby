#
# Copyright (c) 2015 Red Hat, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe SDK::VmReader do

  describe ".read_one" do

    context "when given an empty XML" do

      it "creates an empty VM" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm/>')
        }) 
        result = SDK::VmReader.read_one(reader)
        reader.close
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::Vm)
      end

    end

    context "when given a VM with an id" do

      it "creates a VM with that id" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm id="123"/>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::Vm)
        expect(result.id).to eql('123')
      end

    end

    context "when given a VM with a name" do

      it "creates a VM with that name" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm><name>myvm</name></vm>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::Vm)
        expect(result.name).to eql('myvm')
      end

    end

    context "when given a VM with id and name" do

      it "creates a VM with that id and name" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm id="123"><name>myvm</name></vm>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::Vm)
        expect(result.id).to eql('123')
        expect(result.name).to eql('myvm')
      end

    end

    context "when given an alternative tag" do

      it "ignores it and reads the attributes correctly" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<alternative id="123"><name>myvm</name></alternative>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::Vm)
        expect(result.id).to eql('123')
        expect(result.name).to eql('myvm')
      end

    end

    context "when the href attribute has a value" do

      it "the href getter returns its value" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm href="myhref"></vm>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::Vm)
        expect(result.href).to eql('myhref')
      end

    end

    context "when the a nested CPU is passed" do

      it "it isn't marked as a link" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm><cpu/></vm>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result.cpu.is_link?).to be(false)
      end

    end

    context "when the a nested cluster is passed" do

      it "it is marked as a link" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm><cluster/></vm>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result.cluster.is_link?).to be(true)
      end

    end

    context "when the a nested list of payloads is passed" do

      it "it isn't marked as a link" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm><payloads><payload/></payloads></vm>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result.payloads.is_link?).to be(false)
      end

    end

    context "when the a nested list of disks is passed" do

      it "it is marked as a link" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm><disks><disk/></disks></vm>')
        })
        result = SDK::VmReader.read_one(reader)
        expect(result.disks.is_link?).to be(true)
      end

    end

    context "when a connection is passed" do

      it "it is copied to the created object" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm/>')
        })
        connection = Object.new
        result = SDK::VmReader.read_one(reader, connection)
        expect(result.connection).to be(connection)
      end

      it "it is copied to nested objects" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vm><disks><disk/><disk/></disks></vm>')
        })
        connection = Object.new
        result = SDK::VmReader.read_one(reader, connection)
        expect(result.connection).to be(connection)
        expect(result.disks.connection).to be(connection)
        expect(result.disks[0].connection).to be(connection)
        expect(result.disks[1].connection).to be(connection)
      end

    end

  end

  describe ".read_many" do

    context "when given an empty XML" do

      it "creates an empty list" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vms/>')
        })
        result = SDK::VmReader.read_many(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::List)
        expect(result.size).to eql(0)
      end

    end

    context "when given one VM" do

      it "creates an a list with one element" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vms><vm/></vms>')
        })
        result = SDK::VmReader.read_many(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::List)
        expect(result.size).to eql(1)
        expect(result[0]).to_not be_nil
        expect(result[0]).to be_a(SDK::Vm)
      end

    end

    context "when given two VMs" do

      it "creates an a list with two element" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vms><vm/><vm/></vms>')
        })
        result = SDK::VmReader.read_many(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::List)
        expect(result.size).to eql(2)
        expect(result[0]).to_not be_nil
        expect(result[0]).to be_a(SDK::Vm)
        expect(result[1]).to_not be_nil
        expect(result[1]).to be_a(SDK::Vm)
      end

    end

    context "when given alternative tags" do

      it "reads the elements of the list correctly" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<myvms><myvm/><myvm/></myvms>')
        })
        result = SDK::VmReader.read_many(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::List)
        expect(result.size).to eql(2)
        expect(result[0]).to_not be_nil
        expect(result[0]).to be_a(Ovirt::SDK::V4::Vm)
        expect(result[1]).to_not be_nil
        expect(result[1]).to be_a(Ovirt::SDK::V4::Vm)
      end

    end

    context "when the href attribute has a value" do

      it "the href getter returns its value" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vms href="myhref"></vms>')
        })
        result = SDK::VmReader.read_many(reader)
        expect(result).to_not be_nil
        expect(result).to be_a(SDK::List)
        expect(result.href).to eql('myhref')
      end

    end

    context "when a connection is passed" do

      it "it is copied to the created list" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vms/>')
        })
        connection = Object.new
        result = SDK::VmReader.read_many(reader, connection)
        expect(result.connection).to be(connection)
      end

      it "it is copied to the the elements of the list" do
        reader = SDK::XmlReader.new({
          :io => StringIO.new('<vms><vm/><vm/></vms>')
        })
        connection = Object.new
        result = SDK::VmReader.read_many(reader, connection)
        expect(result.connection).to be(connection)
        expect(result[0].connection).to be(connection)
        expect(result[1].connection).to be(connection)
      end

    end

  end

end
