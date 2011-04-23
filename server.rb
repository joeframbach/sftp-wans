require 'socket'
require_relative 'data_connection'

module SFTP
  class Server
    require 'stringio'

    DEFAULT_PORT = 8080

    def initialize(config = nil, port = DEFAULT_PORT)
      @config = config
      @clients = []
      @directories = []
      @data_sockets = []
      @data_connections = []
      @listener = TCPServer.new('127.0.0.1', port)
      @data_listener = TCPServer.new('127.0.0.1', SFTP::DataConnection::DEFAULT_PORT)
    end

    def run
      while true do
        selected = select([@listener, @data_listener] + @clients + @data_sockets, nil, nil, 0)
        if selected.nil?
          # idle
          @data_sockets.each do |socket|
            @index = @data_sockets.index socket
            @data_socket = @data_sockets[@index]
            @data_connect = @data_connections[@index]

            @data_connect.idle
          end

          next
        else
          selected = selected.first
        end

        next if selected.nil?

        selected.each do |socket|
          if socket == @listener
            # The socket is the connection listener
            puts "New client #{@clients.count}"
            client = @listener.accept
            @clients << client
            @directories << Dir.new(Dir.pwd)
          elsif socket == @data_listener
            puts "New data connection #{@data_connections.count}"
            @data_socket = @data_listener.accept
            @data_sockets << @data_socket
            @data_connections << DataConnection.new({:socket => @data_socket}.merge(@config))
          elsif @clients.include? socket
            # The socket is a client

            @index = @clients.index socket
            @client = socket
            @directory = @directories[@index]
            if @data_connections.count > @index
              @data_connection = @data_connections[@index]
              @data_socket = @data_sockets[@index]
            end

            begin
              if socket.closed? || socket.eof?
                puts "Client #{@index} closed"
                @clients.delete_at @index
                @directories.delete_at @index
                socket.close
              else
                puts "Client #{@index} command"
                interpret_command socket.readline
              end
            #rescue
              # Just close the socket
             # puts "Client #{@index} closed"
             # @clients.delete_at @index
             # @directories.delete_at @index
             # socket.close
            end
          elsif @data_sockets.include? socket
            # data connection
            @index = @data_sockets.index socket
            @client = @clients[@index]
            @directory = @directories[@index]
            @data_socket = @data_sockets[@index]
            @data_connect = @data_connections[@index]

            begin
              if socket.closed? || socket.eof?
                puts "Data Connection #{@index} closed"
                @data_connections.delete_at @index
                @data_sockets.delete_at @index
                socket.close
              else
                puts "Data connection receiving..."
                @data_connect.ping
              end
            #rescue
            end
          end
        end
      end
    end

    def interpret_command(command)
      puts "Command: #{command}"
      command_str = nil
      command_args = []
      command.gsub /(.+?)(\s+|$)/ do |match|
        if command_str.nil?
          command_str = match.strip.downcase
        else
          command_args << match.strip
        end
      end

      # call the associated command_* method
      function = :"command_#{command_str}"
      if self.respond_to? function
        puts "Command #{command_str} #{command_args}}"
        self.send(:"command_#{command_str}", *command_args)
      else
        puts "Command #{command_str} not known"
      end
    end

    # Commands

    # OPEN
    def command_open port = nil
      # negotiate for a data connection
      # if port is nil, the server waits for a data connection from this client
      if port.nil?
        @client.puts "OK #{SFTP::DataConnection::DEFAULT_PORT}"
      else
        remote_host = @client.peeraddr(false).last
        @data_socket = TCPSocket.new(remote_host, port)
        @data_connections << DataConnection.new({:socket => @data_socket}.merge(@config))
        @data_sockets << @data_socket
        @client.puts "OK"
      end
    end

    # PWD
    # Responds: working directory: /home/foo/dir
    def command_pwd
      # Respond with absolute path for this client
      puts "Sending #{@directory.path}"
      @client.puts @directory.path
    end

    # RCD path
    # Responds: path exists: OK
    #           path doesn't exist: FAILURE
    def Server.sanitize path
      # remove . and ..

      while path.gsub! /\/\.(\/|$)/, "/"
      end

      while path.gsub! /(\/[^\/]*?|^)\/..(\/|$)/, "/"
      end

      if path != "/" and path[-1] == "/"
        path = path[0..-2]
      end

      path
    end

    def Server.absolute_path root_path, path
      new_path = path
      unless new_path.start_with?("/")
        new_path = root_path
        unless new_path.end_with?("/")
          new_path += "/"
        end
        new_path += path
      end

      new_path = Server.sanitize new_path
    end

    def command_rcd path
      # construct absolute path
      new_path = Server.absolute_path(@directory.path, path)

      puts "Change directory to #{new_path}"
      if Dir.exists?(new_path)
        @directories[@index] = Dir.new(new_path)
        @client.puts "OK"
      else
        @client.puts "FAILURE"
      end
    end

    # PUT filename filesize
    # Knows it will be retrieving the file over data connection
    def command_put filename, filesize
      filename = Server.absolute_path(@directory.path, filename)
      puts "Receiving #{filename}"

      @client.puts "OK"

      @data_connection.receive filename, filesize.to_i
    end

    # GET filename
    # Responds: OK filesize
    def command_get filename
      # construct absolute path
      filename = Server.absolute_path(@directory.path, filename)

      # Respond with "OK #{filesize}"
      # Start sending file over data connection
      if File.exists? filename and not File.directory? filename
        f = File.new(filename)
        @client.puts "OK #{f.size}"
        @data_connection.transfer f
      else
        @client.puts "FAILURE: File Not Found"
      end
    end

    # MPUT filename filesize [filename filesize]*
    # Knows it will be retrieving many files over data connection
    def command_mput files
    end

    # MGET filename [filename]*
    # Knows it will be sending many files over data connection
    def command_mget filenames
    end

    # RLS
    # Will send a newline delimited list over data connection
    def command_rls
      s = StringIO.new ""
      list = Dir.new(@directory).each do |entry|
        unless entry == "."
          s.puts entry
        end
      end

      @client.puts "OK #{s.size}"

      s.seek 0
      @data_connection.transfer s
    end
  end
end
