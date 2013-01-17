require 'open-uri'
require 'progressbar'

class ArchiveDownloader

  # Downloads a remote file and outputs progress using block
  def self.download_with_progress(remote_file, local_file)
    puts "Downloading #{remote_file} to #{local_file}"

    if File.exists?(local_file)
      puts "File exists, skipping"
      return false
    end
    
    unless FileTest::directory?(File.dirname(local_file))
      Dir::mkdir(File.dirname(local_file))
    end
    progress_bar = nil
    remote_file = open(remote_file,
                      :content_length_proc => lambda {|content_length|
                        if content_length && (content_length > 0)
                          progress_bar = ProgressBar.new "...", content_length
                          progress_bar.file_transfer_mode
                        end
                      },
                      :progress_proc => lambda{|size|
                        progress_bar.set size if progress_bar
                      })
    File.open(local_file, 'w') {|file| file.write remote_file.read}
    
  end

  def initialize(identifier, format, directory)
    @identifier = identifier
    @format = format || "vbr"
    @directory = directory || "/home/steve/Music/"
  end

  def run
    songs = urls_of_songs
    
    if songs.empty?
      puts "No songs found"
      return
    end
    
    dir = File.join(@directory, @identifier)
    
    songs.each do |remote_song_path|
      local_file_path = File.join(dir, File.basename(remote_song_path))
      self.class.download_with_progress(remote_song_path, local_file_path)
    end
  end

  private

    # Returns array  of all files in a specific directory for a given identifier & type
    def urls_of_songs
      download_directory = "http://www.archive.org/download/#{@identifier}/"
      file_extension = determine_file_extension

      song_urls = []

      open(download_directory) do |file|
        line_regex = Regexp.new('<a href="(.*' + file_extension +
                                ')">.*<\/a>.*([0-9]{2}-[A-Za-z]*-[0-9]{4}).*([0-9]{2}:[0-9]{2})(.*)')
        file.each_line do |line|
          regex_match = line.match(line_regex)
          if regex_match
            song_urls.push("#{download_directory}#{regex_match.to_a[1]}") 
          end
        end
      end

      song_urls
    end

    # Gets end of file extension for format
    def determine_file_extension
      if @format == "64kb" || @format == "vbr"
        return "_#{@format}.mp3"
      end

      return ".#{@format}"
    end


end