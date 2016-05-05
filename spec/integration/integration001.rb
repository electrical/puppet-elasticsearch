require 'spec_helper_acceptance'

describe 'Integration testing' do
  shell("mkdir -p #{default['distmoduledir']}/another/files")
  shell("echo '#{test_settings['good_json']}' >> #{default['distmoduledir']}/another/files/good.json")
  shell("echo '#{test_settings['bad_json']}' >> #{default['distmoduledir']}/another/files/bad.json")

  describe 'Setup Elasticsearch', :main => true do
    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, java_install => true, package_url => '#{test_settings['snapshot_package']}' }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe 'Elasticsearch serves requests on' do
      it {
        curl_with_retries("check ES on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch001' }
    end

    describe file('/usr/share/elasticsearch/templates_import') do
      it { should be_directory }
    end
  end

  describe 'Template tests', :template => true do
    describe 'Insert a template with valid json content' do
      it 'should run successfully' do
        pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, java_install => true, package_url => '#{test_settings['snapshot_package']}' }
              elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
              elasticsearch::template { 'foo': ensure => 'present', file => 'puppet:///modules/another/good.json' }"

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      end

      it 'should report as existing in Elasticsearch' do
        curl_with_retries('validate template as installed', default, "http://localhost:#{test_settings['port_a']}/_template/foo | grep logstash", 0)
      end
    end

    if fact('puppetversion') =~ /3\.[2-9]\./
      describe 'Insert a template with bad json content' do
        it 'run should fail' do
          pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, java_install => true, package_url => '#{test_settings['snapshot_package']}' }
                elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
                elasticsearch::template { 'foo': ensure => 'present', file => 'puppet:///modules/another/bad.json' }"

          apply_manifest(pp, :expect_failures => true)
        end
      end

    end
  end

  describe 'Plugin tests', :plugin => true do
    describe 'Install a plugin from official repository' do
      it 'should run successfully' do
        pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, java_install => true, package_url => '#{test_settings['snapshot_package']}' }
              elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
              elasticsearch::plugin { 'lmenezes/elasticsearch-kopf': instances => 'es-01' }
             "

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      end

      describe service(test_settings['service_name_a']) do
        it { should be_enabled }
        it { should be_running }
      end

      describe package(test_settings['package_name']) do
        it { should be_installed }
      end

      describe file(test_settings['pid_file_a']) do
        it { should be_file }
        its(:content) { should match /[0-9]+/ }
      end

      it 'make sure the directory exists' do
        shell('ls /usr/share/elasticsearch/plugins/kopf/', :acceptable_exit_codes => 0)
      end

      it 'make sure elasticsearch reports it as existing' do
        curl_with_retries('validated plugin as installed', default, "http://localhost:#{test_settings['port_a']}/_nodes/?plugin | grep kopf", 0)
      end
    end

    if fact('puppetversion') =~ /3\.[2-9]\./

      describe 'Install a non existing plugin' do
        it 'should run successfully' do
          pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, java_install => true, package_url => '#{test_settings['snapshot_package']}' }
                elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
                elasticsearch::plugin{'elasticsearch/non-existing': module_dir => 'non-existing', instances => 'es-01' }
               "
          apply_manifest(pp, :expect_failures => true)
        end
      end

    end
  end
end
