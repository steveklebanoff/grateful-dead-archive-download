require 'open-uri'
require 'progressbar'

# Downloads a remote file and outputs progress using block
def download_with_progress(remote_file, local_file)
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
end

download_with_progress("http://ia700201.us.archive.org/19/items/gd78-04-24.sbd.mattman.20605.sbeok.shnf/gd1978-04-24d1t10_vbr.mp3",
                       "files/test.html")