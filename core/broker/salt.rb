# The salt plugin which installs salt and hands off to a salt master

# TODO - Make broker properties open rather than rigid
require "erb"
require "net/ssh"

# Root namespace for ProjectHanlon
module ProjectHanlon::BrokerPlugin

  # Root namespace for Salt Broker plugin defined in ProjectHanlon for node handoff
  class Salt < ProjectHanlon::BrokerPlugin::Base
    include(ProjectHanlon::Logging)

    def initialize(hash)
      super(hash)

      @plugin = :salt
      @description = "SaltStack Salt Master"
      @hidden = false
      from_hash(hash) if hash
      # backwards compat with old @servers array
      if !@server && defined?(@servers) && !@servers.empty?
        @server = @servers.first
      end
      @req_metadata_hash = {
        "@server" => {
          :default      => "",
          :example      => "salt.example.com",
          :validation   => '(^$|^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$)',
          :required     => false,
          :description  => "Hostname of Salt Master; optional"
        },
        "@broker_version" => {
          :default      => "stable",
          :example      => "stable [VERSION], daily, testing, git [TAG/BRANCH/COMMIT_ID]",
          :validation   => '(^$|^stable(?:\s+[\d\.]+)?$|^daily$|^testing$|^git(?:\s+\w+)?$)',
          :required     => false,
          :description  => "Salt Version; blank for stable"
        },
        "@environment" => {
          :default     => "",
          :example     => "prod",
          :validation  => '(^.*$)',
          :required    => false,
          :description => "Salt environment that the minion targets"
        }
      }
    end
    
    def print_item_header
      if @is_template
        return "Plugin", "Description"
      else
        return "Name", "Description", "Plugin", "UUID", "Server", "Broker Version"
      end
    end

    def print_item
      if @is_template
        return @plugin.to_s, @description.to_s
      else
        return @name, @user_description, @plugin.to_s, @uuid, @server, @broker_version
      end
    end

    def agent_hand_off(options = {})
      @options = options
      @options[:server] = @server
      @options[:version] = @broker_version
      @options[:environment] = @environment
      @options[:salt_id] ||= @options[:uuid].base62_decode.to_s(16)
      return false unless validate_options(@options, [:username, :password, :server, :environment, :salt_id, :ipaddress])
      @salt_script = compile_template
      logger.debug("salt_script = #{@salt_script}")
      logger.debug("options = #{options.inspect}")
      init_minion(options)
    end

    def proxy_hand_off(options = {})
      # This seems to only be used by ESXi. Not sure salt will run under ESXi.
      # For now until there is a need, commenting out. 
      #
      # res = "
      # @@vc_host { '#{options[:ipaddress]}':
      #   ensure   => 'present',
      #   username => '#{options[:username]}',
      #   password => '#{options[:password]}',
      #   tag      => '#{options[:vcenter_name]}',
      # }
      # "
      # system("puppet apply --certname=#{options[:hostname]} --report -e \"#{res}\"")
      # :broker_success
    end

    # Method call for validating that a Broker instance successfully received the node
    def validate_hand_off(options = {})
      # Return true until we add validation
      true
    end

    def init_minion(options={})
      @run_script_str = ""
      begin
        Net::SSH.start(options[:ipaddress], options[:username], { :password => options[:password], :user_known_hosts_file => '/dev/null'} ) do |session|
          logger.debug "Copy: #{session.exec! "echo \"#{@salt_script}\" > /root/salt_init.sh" }"
          logger.debug "Chmod: #{session.exec! "chmod +x /root/salt_init.sh"}"
          @run_script_str << session.exec!("bash /root/salt_init.sh 2>&1 | tee /root/salt_init.out")
          @run_script_str.split("\n").each do |line|
            logger.debug "salt script: #{line}"
          end
        end
      rescue => e
        logger.error "salt minion error: #{e}"
        return :broker_fail
      end
      # set return to fail by default
      ret = :broker_fail
      # set to wait
      ret = :broker_wait if @run_script_str.include?("has the minion key been accepted")
      # set to success (this meant autosign was likely on)
      ret = :broker_success if @run_script_str.include?("Salt installation finished")
      ret
    end


    def compile_template
      logger.debug "Compiling template"
      install_script = File.join(File.dirname(__FILE__), "salt/minion_install.erb")
      contents = ERB.new(File.read(install_script)).result(binding)
      logger.debug("Compiled installation script:")
      logger.error install_script
      contents.split("\n").each {|x| logger.error x}
      contents
    end

    def validate_options(options, req_list)
      missing_opts = req_list.select do |opt|
        options[opt] == nil
      end
      unless missing_opts.empty?
        false
      end
      true
    end
  end
end
