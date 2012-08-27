# Used to transform Monterey Jazz Festival METs and MODs to contentMetadata.xml and descriptiveMetadata.xml files to prepare for pre-assembly
# August 2012
# Peter Mangiafico

# run with 'ruby devel/mjf_transform.rb'

current_path = File.dirname(File.expand_path(__FILE__))

require 'rubygems'
require 'csv'
require 'nokogiri'
require 'assembly-objectfile'
require 'csv-mapper'

content_path="/sdr-ingest/mjf-tape-all" # TODO replace with actual mounted input folder
output_path=content_path # TODO replace with actual output folder

csv_filename=File.join(current_path,'mjf_list.csv') # TODO replace with actual input spreadsheet defining the files to find (latest version of CSV from Geoff)
content_xml_filename = "contentMetadata.xml" 
descriptive_xml_filename = "descriptiveMetadata.xml"

# for output content metadata
content_type_description="file"
resource_type_description="file"

puts "Input spreadsheet: #{csv_filename}"
puts "Input folder: #{content_path}"
puts "Output folder: #{output_path}"
puts ""

Dir.chdir(content_path)

# read CSV
@items=CsvMapper.import(csv_filename) do read_attributes_from_file end
  
@items.each do |row|
  
  pid=row.druid
  folder=row.folder
  
  puts "Operating on #{folder}"
  
  # dig into data subfolder
  data_folder=File.join(content_path,folder,"data")  
  Dir.chdir(data_folder)
  
  # there should be one folder in there starting with "library_stanford_edu", go to it
  sub_folder=Dir.glob("library_stanford_edu*")
  
  if sub_folder.size == 1 # ok, we found one folder, go to it

    content_sub_folder=File.join(data_folder,sub_folder.first)  
    Dir.chdir(content_sub_folder)
    
    # now find the XML file 
    xml_file=Dir.glob("*.xml")
    
    if xml_file.size == 1 # ok we found one, grab a handle to it

      input_xml_file=File.join(content_sub_folder,xml_file.first)

      puts "...Reading #{input_xml_file}"
               
      f = File.open(input_xml_file)
      doc = Nokogiri::XML(f)
      f.close
          
      # get mods element
      mods=doc.search('//mods:mods')
      
      # lop off any <mods:relatedItem type="constituent"> nodes
      mods.search('//mods:relatedItem[@type="constituent"]').each {|related_item_node| related_item_node.remove}
      
      # find file elements we need to create contentMetadata
      filesec=doc.search('fileSec')
      filegroups=filesec.search('fileGrp')

      resource_label=filesec[0].attributes['ID'].value.gsub('_',' ')
  
      builder = Nokogiri::XML::Builder.new do |xml|
  
        xml.contentMetadata(:objectId => pid,:type => content_type_description) {

          xml.resource(:id => "#{pid}-1",:sequence => "1",:type => resource_type_description) {
        
            xml.label resource_label
        
            filegroups.each do |filegroup|

              file_type=filegroup.attributes['USE'].value.strip.downcase
          
              files=filegroup.search('file')
          
              files.each do |file|
            
                xml_file_params={:id=>file.attributes['ID'].value.gsub("FILE_",""),:mimetype=>file.attributes['MIMETYPE'].value,:size=>file.attributes['SIZE'].value}
                  case file_type
                    when 'archive masters'
                      xml_file_params.merge!({:preserve => 'yes',:publish  => 'no',:shelve   => 'no'})
                    when 'auxiliary application'
                      xml_file_params.merge!({:preserve => 'yes',:publish  => 'no',:shelve   => 'no'})      
                    when 'service high'
                      xml_file_params.merge!({:preserve => 'yes',:publish  => 'yes',:shelve   => 'yes'})      
                  end # end case file_type
            
                  xml.file(xml_file_params) {
                      xml.checksum(file.attributes['CHECKSUM'].value, :type => 'md5')                                
                    } # end builder file node
                
               end # loop over all files in a filegroup
           
             end # end loop over all filegroups in a filesec node
      
          } # end builder resource node
      
        } # end builder contentMetadata node
      
      end # end builder for output content metadata

      output_xml_directory=File.join(output_path,folder)
      Dir.mkdir(output_xml_directory) unless File.directory? output_xml_directory      

      # write output contentMetadata     
      File.open(File.join(output_xml_directory, content_xml_filename),'w') { |fh| fh.puts builder.to_xml }
      puts "...Writing #{content_xml_filename}"

      # write output descriptiveMetadata, removing blank lines
      File.open(File.join(output_xml_directory, descriptive_xml_filename),'w') { |fh| fh.puts mods.to_xml.gsub(/^\s*\n/, "")  }
      puts "...Writing #{descriptive_xml_filename}"
      
    end # end finding XML file
  
  else
    
    puts "**** ERROR: Could not locate content folder within the '#{folder}/data' folder"

  end # end check for content subfolder

end # end loop over all input rows in spreadsheet