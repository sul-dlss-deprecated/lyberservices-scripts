module PreAssembly

  module Remediation

    class Item
      REPO = 'dor'

      attr_accessor :pid,:fobj,:message,:object_type,:success,:description,:data

      def initialize(pid,data=nil)
        @pid=(pid.include?("druid:")) ? pid : "druid:#{pid}"
        @data=data
      end

      def self.get_druids(progress_log_file,completed=true)
        druids=[]
        if File.readable? progress_log_file
          docs = YAML.load_stream(IO.read(progress_log_file))
          docs = docs.documents if docs.respond_to? :documents
          docs.each { |yd| druids << yd[:pid] if yd[:remediate_completed] == completed }
        end
        druids.uniq
      end

      # Ensure the log file exists
      # @param
      # @return
      def ensureLogFile(filename)
        begin
          File.open(filename, 'a') {|f|
          }
        rescue => e
          raise "Unable to open log file #{filename}: #{e.message}"
        end
      end

      # Log to a CSV file
      # @param String csv_out
      # @return
      def log_to_csv(csv_out)
        ensureLogFile(csv_out)
        CSV.open(csv_out, 'a') {|f|
          output_row=[pid,success,message,Time.now]
          f << output_row
        }
      end

      def log_to_progress_file(progress_log_file)
        ensureLogFile(progress_log_file)
        File.open(progress_log_file, 'a') { |f|
          f.puts log_info.to_yaml
        } # complete log to output file
      end

      # gets and caches the Dor Item
      def get_object
        @fobj = Dor.find(@pid)
        @object_type=@fobj.class.to_s.gsub('Dor::','').downcase.to_sym  # returns :collection, :set, :item or :adminpolicyobject
      end

      # remediate the object using versioning or not depending on its current state;
      # returns true or false depending on if all steps were successful
      def remediate

        begin

          DruidTools::Druid.new(@pid) # this will confirm the druid is valid, if not, we get an exception which is caught below and logged
          get_object

          if should_remediate? # should_remediate? == true

            if openable?
              update_object_with_versioning
              @message='remediated with versioning' if @success
            else
              @success=false
              @message='currently in accessioning, cannot remediate'
            end

           else # should_remediate? == false, no remediation required

             @success=true
             @message='remediation not needed'

           end

        rescue Exception => e

          @success=false
          @message="#{e.message}"
          Honeybadger.notify(e)

        end

        @success

      end

      # run the update logic but with versioning
      def update_object_with_versioning
        open_version
        update_object if @success # only continue the process if everything is still good
        close_version if @success # this will save the object too
      end

      def update_object
        begin
          @success=remediate_logic # this method must be defined for your specific remediation passed in
          # note: the object is now saved when the version is closed
        rescue Exception => e
          @success=false
          @message="Updating object failed: #{e.message}"
        end
      end

     def open_version
       begin # try and open the version
         Dor::Services::Client.object(@fobj.id).version.open(
           significance: 'admin',
           description: "pre-assembly remediation #{@description}"
         )
         @success=true
       rescue Exception => e
         @success=false
         @message="Opening object failed: #{e.message}"
       end
     end

     def close_version
       begin # try and close the version
         Dor::Services::Client.object(@fobj.id).version.close
         @success=true
       rescue Exception => e
         @success=false
         @message="Closing object failed: #{e.message}"
       end
     end

     def log_info
       {
         :pid                  => @pid,
         :remediate_completed  => @success,
         :message              => @message,
         :timestamp            => Time.now
       }
     end

     def run_assembly_robot(name)
      `BUNDLE_GEMFILE=~/assembly/current/Gemfile ROBOT_ENVIRONMENT=#{ENV['ROBOT_ENVIRONMENT']} bundle exec ~/assembly/current/bin/run_robot dor:assemblyWF:#{name} -e #{ENV['ROBOT_ENVIRONMENT']} -d #{@pid}`
     end

     def openable?
       Dor::Services::Client.object(@fobj.id).version.openable?
     end

    end

  end

end
