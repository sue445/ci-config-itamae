file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    # Add on.pull_request
    if content.include?("schedule:")
      content.gsub!(<<YAML, <<-YAML)
on:
  push:
  schedule:
YAML
on:
  push:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened
  schedule:
      YAML
    else
      content.gsub!(<<YAML, <<-YAML)
on:
  push:

YAML
on:
  push:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened

      YAML
    end

    # Add continue-on-error to homoluctus/slatify@master
    unless content.match?(%r{        uses: homoluctus/slatify@master\n(.+?)\n        continue-on-error: true\n        with:\n}m)
      content.gsub!(%r{        uses: homoluctus/slatify@master\n(.+?)\n        with:\n}m) do
        <<-YAML
        uses: homoluctus/slatify@master
#{$1}
        continue-on-error: true
        with:
        YAML
      end
    end
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
