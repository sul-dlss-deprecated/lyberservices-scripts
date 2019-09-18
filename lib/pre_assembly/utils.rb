# encoding: UTF-8

module PreAssembly

  class Utils

    def self.get_druids_from_log(progress_log_file, completed = true)
      druids = []
       docs = YAML.load_stream(IO.read(progress_log_file))
       docs = docs.documents if docs.respond_to? :documents
       docs.each { |obj| druids << obj[:pid] if obj[:pre_assem_finished] == completed}
       druids
    end

  end

end
