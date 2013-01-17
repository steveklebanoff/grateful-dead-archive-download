require './classes/archive_downloader.rb'

downloader = ArchiveDownloader.new(ARGV[0], ARGV[1], ARGV[2])
downloader.run