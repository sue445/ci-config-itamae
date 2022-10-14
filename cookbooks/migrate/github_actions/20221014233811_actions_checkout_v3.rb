workflow_files = Dir.glob("#{node[:repo]}/.github/workflows/*.yml")

workflow_files.each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      content.gsub!(%r(actions/checkout@v[0-9]+), "actions/checkout@v3")
    end

    only_if "ls #{workflow_file}"
  end
end
