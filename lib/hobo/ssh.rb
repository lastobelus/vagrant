module Hobo
  class SSH
    SCRIPT = File.join(File.dirname(__FILE__), '..', '..', 'script', 'hobo-ssh-expect.sh')

    class << self
      def connect(opts={})
        options = {}
        [:host, :password, :username].each do |param|
          options[param] = opts[param] || Hobo.config.ssh.send(param)
        end

        # The port is special
        options[:port] = opts[:port] || Hobo.config.vm.forwarded_ports[Hobo.config.ssh.forwarded_port_key][:hostport]

        Kernel.exec "#{SCRIPT} #{options[:username]} #{options[:password]} #{options[:host]} #{options[:port]}".strip
      end

      def execute
        port = Hobo.config.vm.forwarded_ports[Hobo.config.ssh.forwarded_port_key][:hostport]
        Net::SSH.start(Hobo.config.ssh.host, Hobo.config[:ssh][:username], :port => port, :password => Hobo.config[:ssh][:password]) do |ssh|
          yield ssh
        end
      end

      def up?
        port = Hobo.config.vm.forwarded_ports[Hobo.config.ssh.forwarded_port_key][:hostport]
        Ping.pingecho Hobo.config.ssh.host, 1, port
      end
    end
  end
end