file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    unless content.include?('- "1.20"')
      content.gsub!(<<YAML, <<YAML)
          - "1.19"
YAML
          - "1.19"
          - "1.20"
YAML
    end

    content.gsub!(/go-version: "[0-9.]+"/, 'go-version: "1.20"')
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
