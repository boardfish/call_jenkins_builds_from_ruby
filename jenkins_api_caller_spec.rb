require 'jenkins_api_client'
require 'rspec'
require 'webmock/rspec'
require 'faraday'

WebMock.allow_net_connect!

describe 'JenkinsApiCaller' do
  context 'when correct credentials are provided' do
    before(:all) do
      @build_result = build_job
    end

    it 'makes a call to the Jenkins API' do
      assert_requested :post, build_url_for('hello-world')
    end

    it 'creates a run of the job' do
      expect(@build_result[:progress_tracked]).to be true
    end

    it 'returns the result of the job' do
      expect(@build_result[:completion_seen]).to be true
    end
  end
end

def build_job
  build_result = { progress_tracked: false, completion_seen: false }
  build_result[:build_id] = client.job.build(
    'hello-world',
    { 'foo' => 'bar' },
    'build_start_timeout' => 30,
    'progress_proc' => ->(*_args) { build_result[:progress_tracked] = true },
    'completion_proc' => ->(*_args) { build_result[:completion_seen] = true }
  )
  build_result
end

def client
  JenkinsApi::Client.new(server_ip: 'jenkins',
                         username: 'admin',
                         password: '8de21949451b4d6e86bc9d6b25be48ad')
end

def build_url_for(job_name)
  "http://jenkins:8080/job/#{job_name}/buildWithParameters"
end
