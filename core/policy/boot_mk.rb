require 'policy/base'

module ProjectHanlon
  module PolicyTemplate
    # ProjectHanlon Policy Default class
    # Used for default booting of Hanlon MK
    class BootMK < ProjectHanlon::PolicyTemplate::Base
      include(ProjectHanlon::Logging)

      # @param hash [Hash]
      def initialize(hash)
        super(nil)

        @hidden = :true
        @template = :hidden
        @description = "Default MK boot object. Hidden"

        @data = ProjectHanlon::Data.instance
        @data.check_init
        @config = ProjectHanlon.config
      end

      # TODO - add logging ability from iPXE back to Hanlon for detecting node errors

      def get_boot_script(default_mk)
        image_svc_uri = "http://#{@config.hanlon_server}:#{@config.api_port}#{@config.websvc_root}/image/mk/#{default_mk.uuid}"
        rz_mk_boot_debug_level = @config.rz_mk_boot_debug_level
        rz_mk_boot_kernel_args = @config.rz_mk_boot_kernel_args
        # only allow values of 'quiet' or 'debug' for this parameter; if it's anything else set it
        # to an empty string
        rz_mk_boot_debug_level = '' unless ['quiet','debug'].include? rz_mk_boot_debug_level
        boot_script = ""
        boot_script << "#!ipxe\n"
        boot_script << "kernel #{image_svc_uri}/#{default_mk.kernel} maxcpus=1"
        boot_script << " #{rz_mk_boot_debug_level}" if rz_mk_boot_debug_level && !rz_mk_boot_debug_level.empty?
        boot_script << " #{rz_mk_boot_kernel_args}" if rz_mk_boot_kernel_args && !rz_mk_boot_kernel_args.empty?
        boot_script << " || goto error\n"
        boot_script << "initrd #{image_svc_uri}/#{default_mk.initrd} || goto error\n"
        boot_script << "boot || goto error\n"
        boot_script << "\n\n\n"
        boot_script << ":error\necho ERROR, will reboot in #{@config.mk_checkin_interval}\nsleep #{@config.mk_checkin_interval}\nreboot\n"
        boot_script
      end
    end
  end
end
