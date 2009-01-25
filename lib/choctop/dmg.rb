module ChocTop::Dmg
  def make_dmg
    FileUtils.rm_rf pkg
    sh "hdiutil create -quiet -volname '#{name}' -srcfolder 'build/Release/#{target}' '#{pkg}'"
  end
  
  def make_design_dmg
    FileUtils.mkdir_p design_path
    FileUtils.rm_rf design_pkg
    detach_dmg
    sh "hdiutil create -format UDRW -volname '#{name}' -srcfolder 'build/Release/#{target}' '#{design_pkg}' -quiet"
    sh "hdiutil attach '#{design_pkg}' -mountpoint '#{volume_path}' -noautoopen -quiet"
    sh "ln -s /Applications '#{volume_path}/Applications'"
  end
  
  def store_dmg_design
    FileUtils.cp "#{volume_path}/.DS_Store", "#{design_path}/ds_store" rescue nil
    files = Dir["#{volume_path}/*"] - ["#{volume_path}/.DS_Store"]
    files.reject! {|file| File.directory? file}
    files.each { |file| FileUtils.cp(file, "#{design_path}/") }
    true
  end
  
  def detach_dmg
    mounted_paths = `hdiutil info | grep '#{volume_path}' | grep "Apple_HFS"`.split("\n").map { |e| e.split(" ").first }
    mounted_paths.each do |path|
      sh "hdiutil detach '#{path}' -quiet -force"
    end
  end
  
end
ChocTop.send(:include, ChocTop::Dmg)
