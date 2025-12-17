workflow_files = Dir.glob("#{node[:repo]}/.github/workflows/*.yml")

workflow_files.each do |workflow_file|
  file workflow_file do
    action :edit

    block do |content|
      content.gsub!(<<-YAML, <<-YAML)
  notify:
    needs:
      YAML
  all-pass:
    if: always()

    needs:
      YAML

      content.gsub!(/    runs-on: ubuntu-latest\n+    steps:\n      - name: Slack Notification \(success\).+webhook-url: \${{ secrets\.SLACK_WEBHOOK }}\n/m, <<-YAML)
    runs-on: ubuntu-slim

    steps:
      - name: check dependent jobs
        uses: re-actors/alls-green@05ac9388f0aebcb5727afa17fcccfecd6f8ec5fe # v1.2.2
        with:
          jobs: ${{ toJSON(needs) }}
      YAML
    end

    only_if "ls #{workflow_file}"
  end
end
