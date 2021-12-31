require "tmpdir"
require "yaml"

class Cli
  # @param recipe [String]
  # @param repo [String]
  # @param commit_message [String]
  # @param dry_run [Boolean]
  # @param log_level [String]
  # @param include_tags [Array<String>]
  # @param exclude_tags [Array<String>]
  # @param config_file [String]
  def initialize(recipe:, repo:, commit_message: , dry_run:, log_level:, include_tags:, exclude_tags:, config_file:)
    @recipe = recipe
    @repo = repo
    @commit_message = commit_message
    @dry_run = dry_run
    @log_level = log_level
    @include_tags = include_tags
    @exclude_tags = exclude_tags
    @config = YAML.load_file(config_file)
  end

  def run
    if @repo
      run_with_single_repo(@repo)
      return
    end

    repos = @config.select { |_repo, params| target_tag?(params["tags"]) }.keys

    repos.each do |repo|
      run_with_single_repo(repo)
    end
  end

  private

  def target_tag?(tags)
    if @include_tags.empty? && @exclude_tags.empty?
      return true
    end

    unless @exclude_tags.empty?
      return false if @exclude_tags.any? { |exclude_tag| tags.include?(exclude_tag) }
    end

    unless @include_tags.empty?
      return false if @include_tags.any? { |include_tag| !tags.include?(include_tag) }
    end

    true
  end

  # @param repo [String]
  def run_with_single_repo(repo)
    puts "[START] #{repo}"

    within_repo_dir(repo) do
      sh "git checkout master"
      sh "git pull --ff-only"
    end

    run_itamae(repo)

    within_repo_dir(repo) do
      if !@dry_run && updated_repo?
        escaped_commit_message = @commit_message.gsub("'", "'\\\\''")

        sh "git checkout -b #{branch_name}"
        sh "git commit -am '#{escaped_commit_message}'"
        sh "git push origin #{branch_name}"
        sh "gh pr create --fill --title '#{escaped_commit_message}'"
      end
    end

    puts "[END] #{repo}"
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

    if fullpath.empty?
      sh "ghq get #{repo}"
      fullpath = `ghq list --full-path --exact #{repo}`.strip
    end

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
    return @branch_name if @branch_name

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    recipe_name = File.basename(@recipe, ".rb").gsub(/^(\d+)_/, "")
    @branch_name = "migrator/#{timestamp}_#{recipe_name}"
  end

  def updated_repo?
    !`git status`.include?("nothing to commit, working tree clean")
  end
end
