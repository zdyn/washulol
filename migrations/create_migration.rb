name = ARGV[0]

unless name
  exit 1
end

timestamp = Time.now.strftime("%Y%m%d%H%M%S")
File.rename(name, "#{timestamp}_#{name}")