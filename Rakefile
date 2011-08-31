desc "Run Cukes and Specs"
task :default => ["spec", "cucumber"]

task :cucumber do
  sh "cucumber"
end

task :spec do
  sh "rspec spec"
end

task :doc do
  ENV['ARUBA_REPORT_DIR'] = 'doc'
  sh "cucumber"
end

task :examples do
  Dir["examples/*"].each do |example|
    cd example
    sh "../../bin/cuke exec cukes/features/*"
  end
end

task :smoke => [:spec, :cucumber, :examples]
