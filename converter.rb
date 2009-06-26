def buildflaclist(cur,flist)
  if File::directory?(cur) and not (/\/\./.match(cur) or /\/\.\./.match(cur))
    Dir.foreach(cur) {|d| buildflaclist(cur+"/"+d , flist)}
  else
      flist << cur if cur =~ /\.flac$/
  end
  flist
end

def addtosorted(name,dir,options)
  artist = %x{metaflac --show-tag=artist "#{name}"}.gsub(/artist=/i,"").gsub(/\//, "-").gsub("\n","").gsub("\"","\'")
  album = %x{metaflac --show-tag=album "#{name}"}.gsub(/album=/i,"").gsub(/\//, "-").gsub("\n","").gsub("\"","\'")
  track = %x{metaflac --show-tag=tracknumber "#{name}"}.gsub(/tracknumber=/i,"").gsub(/\/[\d]*/, "").gsub("\n","")
  track = "0"+track if track =~ /^[\d]$/
  title = %x{metaflac --show-tag=title "#{name}"}.gsub(/title=/i,"").gsub(/\//, "-").gsub("\n","").gsub("\"","\'")
  year = %x{metaflac --show-tag=date "#{name}"}.gsub(/date=/i,"").gsub(/\//, "-").gsub("\n","")
  genre = %x{metaflac --show-tag=genre "#{name}"}.gsub(/genre=/i,"").gsub(/\//, "-").gsub("\n","").gsub("\"","\'")
  newfile = dir+"/Songs/"+title+" ("+artist+", "+album+" Track "+track+").mp3"
  artistlink = dir+"/Artists/"+artist+"/"+album+"/"+track+" - "+title+".mp3"
  allsongslink = dir+"/Artists/"+artist+"/All Songs/"+title+" ("+artist+", "+album+" Track "+track+").mp3"
  albumlink = dir+"/Albums/"+album+"/"+track+" - "+title+".mp3"
  %x{flac -dc "#{name}" | lame "#{options}" --tt "#{title}" --ta "#{artist}" --tl "#{album}" --ty "#{year}" --tn "#{track}" --tg "#{genre}" - "#{newfile}"} unless File::exists?(newfile)
  condmakedir(dir,"/Artists/"+artist)
  condmakedir(dir,"/Artists/"+artist+"/"+album)
  condmakedir(dir,"/Artists/"+artist+"/All Songs")
  condmakedir(dir,"/Albums/"+album)
  [artistlink, allsongslink, albumlink].each {|link| condmakelink(newfile,link)}
end

def condmakedir(dir, addition)
  Dir::mkdir(dir+addition) unless File::exists?(dir+addition)
end

def condmakelink(source, target)
  %x{ln -T "#{source}" "#{target}"} unless File::exists?(target)
end



puts "What directory is the lossless music in?"
indir = gets.chomp
puts "Where do you want the converted music to go?"
outdir = gets.chomp
puts "Any command-line options to pass to lame?"
options = gets.chomp
condmakedir(outdir,"/Songs")
condmakedir(outdir,"/Albums")
condmakedir(outdir,"/Artists")
flaclist=buildflaclist(indir,[])
count=0
total=flaclist.length
flaclist.each {|f| addtosorted(f,outdir,options); count+=1; puts count.to_s+"/"+total.to_s+" files completed" }

