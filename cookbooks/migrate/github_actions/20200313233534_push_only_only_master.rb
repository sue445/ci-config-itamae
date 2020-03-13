%w(test build).each do |name|
  file "#{node[:repo]}/.github/workflows/#{name}.yml" do
    action :edit

    block do |content|
      content.gsub!(/on:\n  push:\n(.?)  pull_request:\n/m, <<-YAML)
on:
  push:
    branches:
      - master
  pull_request:
      YAML
    end

    only_if "ls #{node[:repo]}/.github/workflows/#{name}.yml"
  end
end
