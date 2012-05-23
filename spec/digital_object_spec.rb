describe PreAssembly::DigitalObject do

  before(:each) do
    @ps = {
      :apo_druid_id  => 'druid:qq333xx4444',
      :set_druid_id  => 'druid:mm111nn2222',
      :source_id     => 'SourceIDFoo',
      :project_name  => 'ProjectBar',
      :label         => 'LabelQuux',
      :publish_attr  => { :publish => 'no', :shelve => 'no', :preserve => 'yes' },
      :project_style => {},
      :bundle_dir    => 'spec/test_data/bundle_input_a',
    }
    @dobj         = PreAssembly::DigitalObject.new @ps
    @dru          = 'ab123cd4567'
    @pid          = "druid:#{@dru}"
    @druid        = Druid.new @pid
    @tmp_dir_args = [nil, 'tmp']
  end

  def add_object_files
    @dobj.object_files = []
    (1..2).each do |i|
      f = "image_#{i}.tif"
      @dobj.object_files.push PreAssembly::ObjectFile.new(
        :path                 => "#{@dobj.bundle_dir}/#{f}",
        :relative_path        => f,
        :exclude_from_content => false,
        :checksum             => "#{i}" * 4
      )
    end
  end


  ####################

  describe "initialization and other setup" do

    it "can initialize a digital object" do
      @dobj.should be_kind_of PreAssembly::DigitalObject
    end

  end

  ####################

  describe "determining druid: get_pid_from_container_barcode()" do

    before(:each) do
      @druids = %w(druid:aa00aaa0000 druid:cc11bbb1111 druid:dd22eee2222)
      apos = %w(druid:aa00aaa9999 druid:bb00bbb9999 druid:cc00ccc9999)
      apos = apos.map { |a| double('apo', :pid => a) }
      @barcode = '36105115575834'
      @dobj.stub(:container_basename).and_return @barcode
      @dobj.stub(:query_dor_by_barcode).and_return @druids
      @dobj.stub(:get_dor_item_apos).and_return apos
      @stubbed_return_vals = @druids.map { false }
    end

    it "should retun DruidMinter.next if use_druid_minter is true" do
      exp = PreAssembly::DruidMinter.current
      @dobj.project_style[:use_druid_minter] = true
      @dobj.should_not_receive :container_basename
      @dobj.get_pid_from_container_barcode.should == exp.next
    end

    it "should return nil whether there are no matches" do
      @dobj.stub(:apo_matches_exactly_one?).and_return *@stubbed_return_vals
      @dobj.get_pid_from_container_barcode.should == nil
    end

    it "should return the druid of the object with the matching APO" do
      @druids.each_with_index do |druid, i|
        @stubbed_return_vals[i] = true
        @dobj.stub(:apo_matches_exactly_one?).and_return *@stubbed_return_vals
        @dobj.get_pid_from_container_barcode.should == @druids[i]
        @stubbed_return_vals[i] = false
      end
    end

  end

  ####################

  describe "determining the druid: other" do

    it "determine_druid() should set correct values for @pid and @druid" do
      # Setup.
      dru = 'aa111bb2222'
      @dobj.project_style[:get_druid_from] = :container
      @dobj.container     = "foo/bar/#{dru}"
      # Before and after assertions.
      @dobj.pid.should   == ''
      @dobj.druid.should == nil
      @dobj.determine_druid
      @dobj.pid.should   == "druid:#{dru}"
      @dobj.druid.should be_kind_of Druid
    end

    it "get_pid_from_container() extracts druid from basename of object container" do
      d = 'xx111yy2222'
      @dobj.container = "foo/bar/#{d}"
      @dobj.get_pid_from_container.should == "druid:#{d}"
    end

    it "container_basename() should work" do
      d = 'xx111yy2222'
      @dobj.container = "foo/bar/#{d}"
      @dobj.container_basename.should == d
    end

    it "apo_matches_exactly_one?() should work" do
      z = 'zz00zzz0000'
      apos = %w(foo bar fubb)
      @dobj.apo_druid_id = z
      @dobj.apo_matches_exactly_one?(apos).should == false  # Too few.
      apos.push z
      @dobj.apo_matches_exactly_one?(apos).should == true   # One = just right.
      apos.push z
      @dobj.apo_matches_exactly_one?(apos).should == false  # Too many.
    end

  end

  ####################

  describe "register()" do

    it "should do nothing if should_register is false" do
      @dobj.project_style[:should_register] = false
      @dobj.should_not_receive :register_in_dor
      @dobj.register
    end

    it "can exercise method using stubbed exernal calls" do
      @dobj.project_style[:should_register] = true
      @dobj.stub(:register_in_dor).and_return(1234)
      @dobj.dor_object.should == nil
      @dobj.register
      @dobj.dor_object.should == 1234
    end

    it "can exercise registration_params() an get expected data structure" do
      @dobj.druid = @druid
      @dobj.label = "LabelQuux"
      rps = @dobj.registration_params
      rps.should             be_kind_of Hash
      rps[:source_id].should be_kind_of Hash
      rps[:tags].should      be_kind_of Array
      rps[:label].should == "LabelQuux"
    end

  end

  ####################

  describe "add_dor_object_to_set()" do

    it "should do nothing when @set_druid_id is false" do
      fake = double('dor_object', :add_relationship => 11, :save => 22)
      @dobj.dor_object = fake
      @dobj.set_druid_id = nil
      fake.should_not_receive :add_relationship
      @dobj.add_dor_object_to_set
    end

    it "can exercise method using stubbed exernal calls" do
      @dobj.dor_object = double('dor_object', :add_relationship => nil, :save => nil)
      @dobj.add_dor_object_to_set
    end

    it "add_relationship() returns expected data structure" do
      @dobj.druid = @druid
      exp = [:is_member_of, "info:fedora/druid:mm111nn2222"]
      arps = @dobj.add_relationship_params.should == exp
    end

  end

  ####################

  describe "unregister()" do

    before(:each) do
      @dobj.dor_object = 1234
      PreAssembly::Utils.stub :delete_from_dor
      PreAssembly::Utils.stub :set_workflow_step_to_error
    end

    it "should do nothing unless the digitial object was registered by pre-assembly" do
      @dobj.should_not_receive :delete_from_dor
      @dobj.reg_by_pre_assembly = false
      @dobj.unregister
    end

    it "can exercise unregister(), with external calls stubbed" do
      @dobj.reg_by_pre_assembly = true
      @dobj.unregister
      @dobj.dor_object.should == nil
      @dobj.reg_by_pre_assembly.should == false
    end

  end


  ####################

  describe "file staging" do

    it "should be able to copy stageable items successfully" do
      @dobj.druid = @druid

      Dir.mktmpdir(*@tmp_dir_args) do |tmp_area|
        # Add some stageable items to the digital object, and
        # create those files.
        files                 = [1,2,3].map { |n| "image#{n}.tif" }
        @dobj.bundle_dir      = tmp_area
        @dobj.staging_dir     = "#{tmp_area}/target"
        @dobj.stageable_items = files.map { |f| "#{tmp_area}/#{f}" }
        @dobj.stageable_items.each { |si| FileUtils.touch si }

        # Stage the files.
        FileUtils.mkdir @dobj.staging_dir
        @dobj.stage_files

        # Check outcome: both source and copy should exist.
        files.each_with_index do |f, i|
          src = @dobj.stageable_items[i]
          cpy = File.join @dobj.druid_tree_dir, f
          File.exists?(src).should == true
          File.exists?(cpy).should == true
        end
      end
    end

  end

  ####################

  describe "content metadata" do

    before(:each) do
      @dobj.druid = @druid
      add_object_files
      @dobj.create_content_metadata_xml
      @exp_xml = <<-END.gsub(/^ {8}/, '')
        <?xml version="1.0"?>
        <contentMetadata objectId="ab123cd4567">
          <resource sequence="1" id="ab123cd4567_1">
            <label>Item 1</label>
            <file preserve="yes" publish="no" shelve="no" id="image_1.tif">
              <checksum type="md5">1111</checksum>
            </file>
          </resource>
          <resource sequence="2" id="ab123cd4567_2">
            <label>Item 2</label>
            <file preserve="yes" publish="no" shelve="no" id="image_2.tif">
              <checksum type="md5">2222</checksum>
            </file>
          </resource>
        </contentMetadata>
      END
      @exp_xml = noko_doc @exp_xml
    end

    it "content_object_files() should filter @object_files correctly" do
      # Generate some object_files.
      files = %w(file5.tif file4.tif file3.tif file2.tif file1.tif file0.tif)
      n = files.size
      m = n / 2
      @dobj.object_files = files.map do |f|
        PreAssembly::ObjectFile.new(:exclude_from_content => false, :relative_path => f)
      end
      # All of them are included in content.
      @dobj.content_object_files.size.should == n
      # Now exclude some. Make sure we got correct N of items.
      (0 ... m).each { |i| @dobj.object_files[i].exclude_from_content = true }
      ofiles = @dobj.content_object_files
      ofiles.size.should == m
      # Also check their ordering.
      ofiles.map { |f| f.relative_path }.should == files[m .. -1].sort
    end

    it "should generate the expected xml text" do
      noko_doc(@dobj.content_md_xml).should be_equivalent_to @exp_xml
    end

    it "should be able to write the content_metadata XML to a file" do
      Dir.mktmpdir(*@tmp_dir_args) do |tmp_area|
        @dobj.druid_tree_dir = tmp_area
        file_name = File.join tmp_area, @dobj.content_md_file

        File.exists?(file_name).should == false
        @dobj.write_content_metadata
        noko_doc(File.read file_name).should be_equivalent_to @exp_xml
      end
    end

    it "node_attr_cm() should return correct value based on @content_structure" do
      base_exp = { :objectId => @dru }
      tests = {
        :simple_image => { :type => 'image' },
        :simple_book  => { :type => 'book' },
      }
      tests.each do |cs, other_attr|
        @dobj.content_structure = cs
        @dobj.node_attr_cm.should == base_exp.merge(other_attr)
      end
    end

    it "node_attr_cm_resource() should return correct value based on @content_structure" do
      seq = 123
      base_exp = { :sequence => seq, :id => "#{@dru}_#{seq}" }
      tests = {
        :simple_image => { :type => 'image' },
        :simple_book  => { :type => 'page' },
      }
      tests.each do |cs, other_attr|
        @dobj.content_structure = cs
        @dobj.node_attr_cm_resource(seq).should == base_exp.merge(other_attr)
      end
    end

    it "node_attr_cm_file() should return expected value" do
      p           = 'foo/bar.txt'
      object_file = double 'object_file', :relative_path => p
      exp         = {:id => p}.merge @dobj.publish_attr
      @dobj.node_attr_cm_file(object_file).should == exp
    end

    it "node_provider_checksum() should do nothing if given a nil checksum" do
      xml_builder = double('xml_builder')
      xml_builder.should_not_receive(:provider_checksum)
      @dobj.node_provider_checksum(xml_builder, nil)
    end

  end

  ####################

  describe "descriptive metadata" do

    before(:each) do
      @dobj.druid = @druid
      @dobj.manifest_row = {
        'sourceid'    => 'foo-1',
        'label'       => 'this is < a label with an & that will break XML unless it is escaped',
        'year'        => '2012',
        'description' => 'this is a description > another description < other stuff',
        'format'      => 'film',
        'foo'         =>  '123',
        'bar'         =>  '456',
      }
      @dobj.desc_md_template_xml = <<-END.gsub(/^ {8}/, '')
        <?xml version="1.0"?>
        <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
          <typeOfResource>still image</typeOfResource>
          <genre authority="att">digital image</genre>
          <subject authority="lcsh">
            <topic>Automobile</topic>
            <topic>History</topic>
          </subject>
          <relatedItem type="host">
            <titleInfo>
              <title>The Collier Collection of the Revs Institute for Automotive Research</title>
            </titleInfo>
            <typeOfResource collection="yes"/>
          </relatedItem>
          <relatedItem type="original">
            <physicalDescription>
              <form authority="att">[[format]]</form>
            </physicalDescription>
          </relatedItem>
          <originInfo>
            <dateCreated>[[year]]</dateCreated>
          </originInfo>
          <titleInfo>
            <title>'[[label]]' is the label!</title>
          </titleInfo>
          <note>[[description]]</note>
          <note>ERB Test: <%=manifest_row['description']%></note>
          <identifier type="local" displayLabel="Revs ID">[[sourceid]]</identifier>
          <note type="source note" ID="foo">[[foo]]</note>
          <note type="source note" ID="bar">[[bar]]</note>
        </mods>
      END
      @exp_xml = <<-END.gsub(/^ {8}/, '')
        <?xml version="1.0"?>
        <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
          <typeOfResource>still image</typeOfResource>
          <genre authority="att">digital image</genre>
          <subject authority="lcsh">
            <topic>Automobile</topic>
            <topic>History</topic>
          </subject>
          <relatedItem type="host">
            <titleInfo>
              <title>The Collier Collection of the Revs Institute for Automotive Research</title>
            </titleInfo>
            <typeOfResource collection="yes"/>
          </relatedItem>
          <relatedItem type="original">
            <physicalDescription>
              <form authority="att">film</form>
            </physicalDescription>
          </relatedItem>
          <originInfo>
            <dateCreated>2012</dateCreated>
          </originInfo>
          <titleInfo>
            <title>'this is &lt; a label with an &amp; that will break XML unless it is escaped' is the label!</title>
          </titleInfo>
          <note>this is a description &gt; another description &lt; other stuff</note>
          <identifier type="local" displayLabel="Revs ID">foo-1</identifier>
          <note>ERB Test: this is a description &gt; another description &lt; other stuff</note>
          <note type="source note" ID="foo">123</note>
          <note type="source note" ID="bar">456</note>
        </mods>
      END
      @exp_xml = noko_doc @exp_xml
    end

    it "generate_desc_metadata() should do nothing if there is no template" do
      @dobj.desc_md_template_xml = nil
      @dobj.should_not_receive :create_desc_metadata_xml
      @dobj.generate_desc_metadata
    end

    it "create_desc_metadata_xml() should generate the expected xml text" do
      @dobj.create_desc_metadata_xml
      noko_doc(@dobj.desc_md_xml).should be_equivalent_to @exp_xml
    end

    it "should be able to write the desc_metadata XML to a file" do
      @dobj.create_desc_metadata_xml
      Dir.mktmpdir(*@tmp_dir_args) do |tmp_area|
        @dobj.druid_tree_dir = tmp_area
        file_name = File.join tmp_area, @dobj.desc_md_file
        File.exists?(file_name).should == false
        @dobj.write_desc_metadata
        noko_doc(File.read file_name).should be_equivalent_to @exp_xml
      end
    end

  end

  ####################

  describe "initiate assembly workflow" do

    it "initialize_assembly_workflow() should do nothing if init_assembly_wf is false" do
      @dobj.init_assembly_wf = false
      @dobj.should_not_receive :assembly_workflow_url
      @dobj.initialize_assembly_workflow
    end

    it "assembly_workflow_url() should return expected value" do
      @dobj.pid = @pid
      url = @dobj.assembly_workflow_url
      url.should =~ /^http.+assemblyWF$/
      url.include?(@pid).should == true
    end

  end

end
