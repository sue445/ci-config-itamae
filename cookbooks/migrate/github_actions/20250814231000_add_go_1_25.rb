workflow_files = Dir.glob("#{node[:repo]}/.github/workflows/*.yml")

workflow_files.each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      unless content.include?('- "1.25"')
        content.gsub!(<<YAML, <<YAML)
          - "1.24"
YAML
          - "1.24"
          - "1.25"
YAML
      end

      content.gsub!(/go-version: "[0-9.]+"/, 'go-version: "1.25"')
      content.gsub!(/GOLANGCI_LINT_VERSION: v[0-9.]+/, "GOLANGCI_LINT_VERSION: v2.4")
    end

    only_if "ls #{workflow_file}"
  end
end
