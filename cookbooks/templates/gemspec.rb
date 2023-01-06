gemspecs = Dir.glob("#{node[:repo]}/*.gemspec")

gemspecs.each do |gemspec|
  file "#{gemspec}" do
    action :edit

    block do |content|
    end

    only_if "ls #{gemspec}"
  end
end
