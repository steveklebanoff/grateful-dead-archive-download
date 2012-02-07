require 'open-uri'
require 'progressbar'

# Downloads a remote file and outputs progress using block
def download_with_progress(remote_file, local_file)
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

# Gets end of file extension for format
def get_end_of_file_name(type)
  if type == "ogg" || type == "shn"
    return ".#{type}"
  elsif type == "64kb" or type == "vbr"
    return "_#{type}.mp3"
  end
  raise ArgumentError, "Incorrect Argument"
end

# Returns array  of all files in a specific directory for a given identifier & type
def urls_of_songs(show_id, type)
  download_directory = "http://www.archive.org/download/#{show_id}/"
  song_urls = []
  open(download_directory) do |file|
    line_regex = Regexp.new('<a href="(.*' + get_end_of_file_name(type) +
                            ')">.*<\/a>.*([0-9]{2}-[A-Za-z]*-[0-9]{4}).*([0-9]{2}:[0-9]{2})(.*)')
    file.each_line do |line|
      regex_match = line.match(line_regex)
      if !regex_match.nil?
        song_urls.push("#{download_directory}#{regex_match.to_a[1]}") # TODO: add file size gotten from list?
      end
    end
  end

  song_urls
end

# Downloads all songs given a show identifier, type, and directory
def download_songs(show_id, type, base_directory)
  songs = urls_of_songs(show_id, type)
  
  if songs.empty?
    puts "No songs found"
    return
  end
  
  # WARN: Assumes that all files in list are in same directory
  dir = "#{base_directory}/#{File.split(File.dirname(songs.first))[1]}/"
  
  songs.each do |remote_song_path|
    local_file_path = "#{dir}#{File.basename(remote_song_path)}"
    puts "Downloading #{remote_song_path} to #{local_file_path}"
    download_with_progress(remote_song_path, local_file_path)
  end
end

download_songs('gd78-04-24.sbd.mattman.20605.sbeok.shnf', 'vbr', 'files')