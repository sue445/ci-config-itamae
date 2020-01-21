file "#{node[:repo]}/.github/workflows/test.yml" do
  action :edit

  block do |content|
    # Update jobs.test.runs-on
    content.gsub!(<<-YAML, <<-YAML)
jobs:
  test:
    runs-on: ${{ matrix.runner }}

    strategy:
YAML
jobs:
  test:
    runs-on: ubuntu-latest

    container: ${{ matrix.ruby }}

    strategy:
YAML

    # Update jobs.test.strategy.matrix.ruby
    content.gsub!(/- (\d+)\.(\d+)\.(\d+)$/) { "- ruby:#{$1}.#{$2}" }
    content.gsub!("2.8.0-dev", "rubylang/ruby:master-nightly-bionic")

    # Update jobs.test.strategy.matrix.include
    content.gsub!(/^        include:\n.+?\n\n/m, <<-YAML)
        include:
          - ruby: rubylang/ruby:master-nightly-bionic
            allow_failures: "true"

    YAML

    # Remove setup-rbenv
    content.gsub!(/^\s+- name: Set up rbenv.+?\n\n/m, "")
    content.gsub!(/^\s+- name: Cache RBENV_ROOT.+?\n\n/m, "")
    content.gsub!(/^\s+- name: Reinstall libssl-dev.+?\n\n/m, "")
    content.gsub!(/^\s+- name: Install Ruby.+?env:.+?\n\n/m, "")

    content.gsub!(<<-YAML, <<-YAML)
          set -xe
          eval "$(rbenv init -)"
    YAML
          set -xe
    YAML

    content.gsub!(<<-YAML, "")
        env:
          RBENV_VERSION: ${{ matrix.ruby }}
    YAML

    # Update Code Climate Test Reporter
    content.gsub!(<<-YAML, <<-YAML)
      - name: Setup Code Climate Test Reporter
        uses: aktions/codeclimate-test-reporter@v1
        with:
          codeclimate-test-reporter-id: ${{ secrets.CC_TEST_REPORTER_ID }}
          command: before-build
        continue-on-error: ${{ endsWith(matrix.ruby, '-dev') }}
    YAML
      - name: Setup Code Climate Test Reporter
        uses: aktions/codeclimate-test-reporter@v1
        with:
          codeclimate-test-reporter-id: ${{ secrets.CC_TEST_REPORTER_ID }}
          command: before-build
        if: matrix.ruby >= 'ruby:2.4'
        continue-on-error: ${{ matrix.allow_failures == 'true' }}
    YAML

    content.gsub!(<<-YAML, <<-YAML)
      - name: Teardown Code Climate Test Reporter
        uses: aktions/codeclimate-test-reporter@v1
        with:
          codeclimate-test-reporter-id: ${{ secrets.CC_TEST_REPORTER_ID }}
          command: after-build
        if: always()
        continue-on-error: ${{ endsWith(matrix.ruby, '-dev') }}
    YAML
      - name: Teardown Code Climate Test Reporter
        uses: aktions/codeclimate-test-reporter@v1
        with:
          codeclimate-test-reporter-id: ${{ secrets.CC_TEST_REPORTER_ID }}
          command: after-build
        if: matrix.ruby >= 'ruby:2.4' && always()
        continue-on-error: ${{ matrix.allow_failures == 'true' }}
    YAML

    # Update continue-on-error:
    content.gsub!("continue-on-error: ${{ endsWith(matrix.ruby, '-dev') }}", "continue-on-error: ${{ matrix.allow_failures == 'true' }}")
  end

  only_if "ls #{node[:repo]}/.github/workflows/test.yml"
end
