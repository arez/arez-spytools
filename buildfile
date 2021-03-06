require 'buildr/git_auto_version'
require 'buildr/gpg'
require 'buildr/gwt'

Buildr::MavenCentral.define_publish_tasks(:profile_name => 'org.realityforge', :username => 'realityforge')

desc 'Arez-SpyTools: Arez utilities that enhance the spy capabilities'
define 'arez-spytools' do
  project.group = 'org.realityforge.arez.spytools'
  compile.options.source = '1.8'
  compile.options.target = '1.8'
  compile.options.lint = 'all,-processing,-serial'
  project.compile.options.warnings = true
  project.compile.options.other = %w(-Werror -Xmaxerrs 10000 -Xmaxwarns 10000)

  project.version = ENV['PRODUCT_VERSION'] if ENV['PRODUCT_VERSION']

  pom.add_apache_v2_license
  pom.add_github_project('arez/arez-spytools')
  pom.add_developer('realityforge', 'Peter Donald')

  deps = artifacts(:jetbrains_annotations, :arez_core, :akasha, :jsinterop_base, :braincheck_core, :javax_annotation)
  pom.include_transitive_dependencies += deps
  pom.dependency_filter = Proc.new { |dep| deps.include?(dep[:artifact]) }

  compile.with :javax_annotation,
               :braincheck_core,
               :grim_annotations,
               :jetbrains_annotations,
               :jsinterop_base,
               :jsinterop_annotations,
               :akasha,
               :arez_core

  compile.options[:processor_path] << [:arez_processor]

  gwt_enhance(project)

  package(:jar)
  package(:sources)
  package(:javadoc)

  test.options[:properties] = { 'braincheck.environment' => 'development', 'arez.environment' => 'development' }
  test.options[:java_args] = ['-ea']

  test.using :testng
  test.compile.with [:guiceyloops]

  Buildr::BazelJ2cl.define_bazel_j2cl_test(project,
                                           [project],
                                           'arez.spytools.SpyToolsCompileTest',
                                           _(:source, :test, :js, 'arez/spytools/SpyToolsCompileTest.js'),
                                           :javax_annotation => true)

  doc.
    using(:javadoc,
          :windowtitle => 'Arez SpyTools API Documentation',
          :linksource => true,
          :timestamp => false,
          :link => %w(https://arez.github.io/api https://docs.oracle.com/javase/8/docs/api http://www.gwtproject.org/javadoc/latest/)
    )

  iml.excluded_directories << project._('tmp')

  ipr.add_default_testng_configuration(:jvm_args => '-ea -Darez.environment=development')

  ipr.add_component_from_artifact(:idea_codestyle)
  ipr.add_code_insight_settings
  ipr.add_nullable_manager
  ipr.add_javac_settings('-Xlint:all,-processing,-serial -Werror -Xmaxerrs 10000 -Xmaxwarns 10000')
end
