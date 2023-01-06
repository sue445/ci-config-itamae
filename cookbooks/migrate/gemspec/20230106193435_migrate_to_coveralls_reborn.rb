gemspecs = Dir.glob("#{node[:repo]}/*.gemspec")

gemspecs.each do |gemspec|
  file "#{gemspec}" do
    action :edit

    block do |content|
      content.gsub!(%r{add_development_dependency(\s+)(["'])coveralls(["'])}) do
        %Q(add_development_dependency#{$1}#{$2}coveralls_reborn#{$3})
      end
    end

    only_if "ls #{gemspec}"
  end
end
