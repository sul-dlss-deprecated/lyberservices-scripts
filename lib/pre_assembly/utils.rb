# encoding: UTF-8

module PreAssembly

  class Utils

    # Read in a list of druids from a pre-assembly progress load file and load into an array.
    #
    # @param [string] progress_log_file filename
    # @param [boolean] completed if true, returns druids that have completed, if false, returns druids that failed (defaults to true)
    #
    # @return [array] list of druids
    #
    # Example:
    #   druids = PreAssembly::Utils.get_druids_from_log '/dor/preassembly/sohp_accession_log.yaml'
    #   puts druids
    #   > ['aa000aa0001', 'aa000aa0002']
    def self.get_druids_from_log(progress_log_file, completed = true)
      druids = []
       docs = YAML.load_stream(IO.read(progress_log_file))
       docs = docs.documents if docs.respond_to? :documents
       docs.each { |obj| druids << obj[:pid] if obj[:pre_assem_finished] == completed}
       druids
    end

    # Get a list of druids that match the given array of source IDs.
    # This method only works when this gem is used in a project that is configured to connect to DOR
    #
    # @param [String] source_ids array of source ids to lookup
    # @return [array] druids
    # Example:
    #   puts PreAssembly::Utils.get_druids_by_sourceid(['revs-01','revs-02'])
    #   > ['druid:aa000aa0001','druid:aa000aa0002']
    def self.get_druids_by_sourceid(source_ids)
      druids = []
      source_ids.each {|sid| druids << Dor::SearchService.query_by_id(sid)}
      druids.flatten
    end

  end

end
