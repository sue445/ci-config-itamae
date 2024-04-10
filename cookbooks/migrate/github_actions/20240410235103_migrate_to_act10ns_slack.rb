workflow_files = Dir.glob("#{node[:repo]}/.github/workflows/*.yml")

workflow_files.each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      if content.include?("lazy-actions/slatify")
        content.gsub!(%r{lazy-actions/slatify@.+}, "act10ns/slack@v2")

        content.gsub!(%r{          job_name:.*matrix.*\n          type:.+\n          icon_emoji:.+\n          url:.+\n          token:.+\n}, <<YML)
          status: ${{ job.status }}
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          matrix: ${{ toJson(matrix) }}
YML

        content.gsub!(%r{          job_name:.+\n          type:.+\n          icon_emoji:.+\n          url:.+\n          token:.+\n}, <<YML)
          status: ${{ job.status }}
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
YML
      end
    end

    only_if "ls #{workflow_file}"
  end
end
