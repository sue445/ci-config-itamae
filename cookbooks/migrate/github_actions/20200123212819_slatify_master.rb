[
  "test",
  "build",
  "release",
].each do |name|
  file "#{node[:repo]}/.github/workflows/#{name}.yml" do
    action :edit

    block do |content|
      content.gsub!(%r{uses:\s+homoluctus/slatify@.+$}, "uses: homoluctus/slatify@master")
    end

    only_if "ls #{node[:repo]}/.github/workflows/#{name}.yml"
  end
end
