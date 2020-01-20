require "shellwords"
require "tmpdir"
require "yaml"

class Cli
  include FileUtils

  # @param recipe [String]
  # @param repo [String]
  # @param commit_message [String]
  # @param dry_run [Boolean]
  # @param log_level [String]
  def initialize(recipe:, repo:, commit_message: , dry_run:, log_level:)
    @recipe = recipe
    @repo = repo
    @commit_message = commit_message
    @dry_run = dry_run
    @log_level = log_level
  end

  def run
    run_with_single_repo(@repo)
  end

  private

  # @param repo [String]
  def run_with_single_repo(repo)
    within_repo_dir(repo) do
      sh "git checkout master"
      sh "git pull --ff-only"
    end

    run_itamae(repo)

    within_repo_dir(repo) do
      if updated_repo?
        sh "git checkout -b #{branch_name}"
        sh "git commit -am '#{@commit_message.gsub("'", "\\\\'")}'"
        sh "git push origin #{branch_name}"
      end
    end
  end

  # @param repo [String]
  def run_itamae(repo)
    Dir.mktmpdir("ci-config-itamae") do |tmp_dir|
      node = { "repo" => repo_fullpath(repo) }
      node_yaml = File.join(tmp_dir, "node.yml")

      File.open(node_yaml, "wb") do |f|
        f.write(node.to_yaml)
      end

      args = [
        @recipe,
        "--node-yaml=#{node_yaml}",
        "--log-level=#{@log_level}"
      ]
      args << "--dry-run" if @dry_run

      sh "itamae local #{args.join(" ")}"
    end
  end

  # @param repo [String]
  def within_repo_dir(repo)
    Dir.chdir(repo_fullpath(repo)) do
      yield
    end
  end

  # @param repo [String]
  # @return [String]
  def repo_fullpath(repo)
    fullpath = `ghq list --full-path --exact #{repo}`.strip
    raise "NotFound: '#{repo}'" if fullpath.empty?
    fullpath
  end

  def sh(command)
    if debug_logging?
      puts command
    end
    system(command, exception: true)
  end

  def debug_logging?
    @log_level == "debug"
  end

  def branch_name
    @branch_name ||=
      [
        Time.now.strftime("%Y%m%d%H%M%S"),
        File.basename(@recipe, ".rb").gsub(/^(\d+)_/, ""),
      ].join("_")
  end

  def updated_repo?
    !`git status`.include?("nothing to commit, working tree clean")
  end
end
