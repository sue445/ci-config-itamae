workflow_files = Dir.glob("#{node[:repo]}/.github/workflows/*.yml")

workflow_files.each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      unless content.include?('- "1.23"')
        content.gsub!(<<YAML, <<YAML)
          - "1.22"
YAML
          - "1.22"
          - "1.23"
YAML
      end

      content.gsub!(/go-version: "[0-9.]+"/, 'go-version: "1.23"')
    end

    only_if "ls #{workflow_file}"
  end
end
