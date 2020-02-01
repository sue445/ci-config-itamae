file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    next if content.include?("centos:8")

    content.gsub!(<<-YAML, <<-YAML)
          - centos:7
    YAML
          - centos:7
          - centos:8
    YAML
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
