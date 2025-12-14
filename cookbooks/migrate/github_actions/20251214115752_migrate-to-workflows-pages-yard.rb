def default_branch
  Dir.chdir(node[:repo]) do
    `git remote show origin | grep 'HEAD branch:' | cut -d : -f 2 | tr -d '[[:space:]]'`.strip
  end
end

WORKFLOW_YAML = <<-YAML
name: Deploy yard to Pages

on:
  push:
    branches:
      - #{default_branch}
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    uses: sue445/workflows/.github/workflows/pages-yard.yml@main
    secrets:
      slack-webhook: ${{ secrets.SLACK_WEBHOOK }}
YAML

file "#{node[:repo]}/.github/workflows/pages.yml" do
  action :edit

  block do |content|
    unless content.include?("sue445/workflows/.github/workflows/pages-yard.yml")
      workflow_yaml = WORKFLOW_YAML
      if content.include?("apt-get install")
        workflow_yaml << <<-YAML
    with:
      before-command: |
        TODO
        YAML
      end
      content.replace(workflow_yaml)
    end
  end

  only_if "ls #{node[:repo]}/.github/workflows/pages.yml"
end
