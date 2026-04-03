workflow_files = Dir.glob("#{node[:repo]}/.github/workflows/*.yml")

workflow_files.each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      content.gsub!(%r{uses: act10ns/slack@.*$}, "uses: act10ns/slack@d96404edccc6d6467fc7f8134a420c851b1e9054 # v2.2.0")
    end

    only_if "ls #{workflow_file}"
  end
end
